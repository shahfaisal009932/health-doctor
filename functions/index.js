const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

// Call document lifecycle statuses written by the mobile app.
const CALL_STATUS = {
  ringing: 'ringing', // doctor created the call, waiting for the client
  active: 'active', // client answered (SDP answer saved)
  rejected: 'rejected', // client declined the call
  missed: 'missed', // client did not answer in time
  ended: 'ended', // doctor cancelled an unanswered call
};

/** Resolve the stored FCM registration token for a user profile. */
async function getFcmToken(collection, uid) {
  if (!uid) return null;
  const doc = await db.collection(collection).doc(uid).get();
  if (!doc.exists) return null;
  const token = doc.data().fcmToken;
  return token && typeof token === 'string' ? token : null;
}

/** Resolve a doctor's display name from their profile. */
async function getDoctorName(doctorId) {
  if (!doctorId) return 'Doctor';
  const doc = await db.collection('doctors').doc(doctorId).get();
  const name = doc.exists ? doc.data().name : null;
  return (name && typeof name === 'string' && name.trim()) || 'Doctor';
}

/**
 * Pushes an FCM notification to the client whenever the status of one of
 * their appointments changes (Accepted / Rejected / Completed / Cancelled).
 */
exports.onAppointmentStatusChanged = functions.firestore
  .document('appointments/{appointmentId}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    if (!after) return;

    const before = change.before.exists ? change.before.data() : null;
    const status = after.status;
    if (before && before.status === status) return;

    const clientId = after.clientId;
    const doctorName = after.doctorName || 'Doctor';

    let title;
    let body;
    switch (status) {
      case 'Accepted':
        title = 'Appointment Accepted';
        body = `Dr. ${doctorName} accepted your appointment. You can now join the video call.`;
        break;
      case 'Rejected':
        title = 'Appointment Rejected';
        body = `Unfortunately, Dr. ${doctorName} rejected your appointment.`;
        break;
      case 'Completed':
        title = 'Consultation Completed';
        body = `Your consultation with Dr. ${doctorName} has been completed.`;
        break;
      case 'Cancelled':
        title = 'Appointment Cancelled';
        body = 'Your appointment has been cancelled.';
        break;
      default:
        return;
    }

    const token = await getFcmToken('clients', clientId);
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: { title, body },
      data: {
        title,
        body,
        type: status.toLowerCase(),
        appointmentId: context.params.appointmentId,
      },
    });
  });

/**
 * Incoming video call: whenever the doctor creates an appointment-linked
 * call document, ring the client's device.
 */
exports.onCallCreated = functions.firestore
  .document('calls/{callId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const appointmentId = data.appointmentId;
    const doctorId = data.doctorId;
    const clientId = data.clientId;

    // Adhoc calls (no appointment / no assigned client) cannot ring a
    // specific patient, so they are skipped.
    if (!appointmentId || !doctorId || !clientId) return;

    const doctorName = await getDoctorName(doctorId);
    const token = await getFcmToken('clients', clientId);
    if (!token) return;

    const title = 'Incoming Video Call';
    const body = `Dr. ${doctorName} is calling you.`;

    await admin.messaging().send({
      token,
      notification: { title, body },
      data: {
        title,
        body,
        type: 'incoming_call',
        appointmentId: appointmentId,
        callId: context.params.callId,
        doctorName: doctorName,
      },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  });

/**
 * Call outcome: when the client rejects or misses a call, tell the doctor.
 */
exports.onCallUpdated = functions.firestore
  .document('calls/{callId}')
  .onUpdate(async (change, context) => {
    const before = change.before.exists ? change.before.data() : {};
    const after = change.after.exists ? change.after.data() : {};
    const status = after.status;
    if (before.status === status) return;

    const appointmentId = after.appointmentId;
    const doctorId = after.doctorId;
    const clientId = after.clientId;
    if (!appointmentId || !doctorId || !clientId) return;

    let title;
    let body;
    let type;
    if (status === CALL_STATUS.rejected) {
      title = 'Call Declined';
      body = 'The patient declined your consultation call.';
      type = 'call_rejected';
    } else if (status === CALL_STATUS.missed) {
      title = 'Call Missed';
      body = 'The patient did not answer your consultation call.';
      type = 'call_missed';
    } else {
      return;
    }

    const token = await getFcmToken('doctors', doctorId);
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: { title, body },
      data: {
        title,
        body,
        type,
        appointmentId: appointmentId,
        callId: context.params.callId,
      },
      android: { priority: 'high' },
    });
  });

/**
 * Doctor cancelled before answer: if a ringing call is deleted (the doctor
 * ended the call without the client answering), let the client know so they
 * stop waiting.
 */
exports.onCallDeleted = functions.firestore
  .document('calls/{callId}')
  .onDelete(async (snap, context) => {
    const data = snap.data() || {};
    // Only unanswered calls warrant a "call ended" push; completed calls are
    // torn down after a normal consultation.
    if (data.status !== CALL_STATUS.ringing) return;

    const appointmentId = data.appointmentId;
    const clientId = data.clientId;
    if (!appointmentId || !clientId) return;

    const token = await getFcmToken('clients', clientId);
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: { title: 'Call Ended', body: 'The doctor ended the call.' },
      data: {
        title: 'Call Ended',
        body: 'The doctor ended the call.',
        type: 'call_ended',
        appointmentId: appointmentId,
        callId: context.params.callId,
      },
      android: { priority: 'high' },
    });
  });
