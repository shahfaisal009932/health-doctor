# Dr Serv - Doctor Consultation App

Dr Serv is a Flutter-based Doctor Consultation application that allows doctors and patients to communicate through real-time video consultations. Patients can book appointments, doctors can manage appointment requests, and both users can connect using WebRTC video calling.


## Project Structure
```
lib/
├── app/            # Router & route constants
├── core/           # Constants, theme, services, utils, widgets
├── models/         # Data models
├── providers/      # Provider registration
├── repositories/   # Firebase data access layer
├── viewmodels/     # Business logic (ChangeNotifier)
└── views/          # UI screens
```

## Firebase Setup

The app uses Firebase project `doctor-consultation-1684c`.

### Firestore Collections

| Collection | Purpose |
|---|---|
| `doctors` | Doctor profiles (doc ID = auth UID) |
| `appointments` | Patient appointments (doctorId = auth UID) |
| `session_notes` | Notes linked to appointments |
| `calls` | WebRTC signaling (offer/answer/ICE) |
| `calls/{callId}/callerCandidates` | Caller ICE candidates |
| `calls/{callId}/calleeCandidates` | Callee ICE candidates |

### Firestore Security Rules (recommended for production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }
    match /doctors/{uid} {
      allow read, write: if signedIn() && request.auth.uid == uid;
    }
    match /appointments/{id} {
      allow read, write: if signedIn();
    }
    match /session_notes/{id} {
      allow read, write: if signedIn();
    }
    match /calls/{callId} {
      allow read, write: if signedIn();
      match /{sub=**} {
        allow read, write: if signedIn();
      }
    }
  }
}
```

## Running the App

```bash
flutter pub get
flutter run
```

# ✨ Features

## 🔐 Authentication

- Firebase Authentication
- Login & Register
- Forgot Password
- Role-based Login (Doctor / Client)

---

## 👤 Client (Patient)

- Register/Login using Firebase Authentication
- View Doctor List
- Book Appointments
- Cancel Pending Appointments
- Receive Real-time Appointment Status Updates
- Join Video Consultation after Appointment Acceptance
- View Consultation History
- Edit Profile
- Receive Notifications

---

## 👨‍⚕️ Doctor

- Register/Login
- View Appointment Requests
- Accept/Reject Appointments
- Complete Consultation
- Start Video Consultation
- Add/Edit/Delete Consultation Notes
- View Patient Details

---

# 🛠 Tech Stack

| Technology | Purpose |
|------------|----------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Firebase Authentication | User Authentication |
| Cloud Firestore | Database |
| Firebase Cloud Messaging | Push Notifications |
| GetX | State Management & Routing |
| flutter_webrtc | Video Calling |
| Cloud Firestore Streams | Real-time Data Synchronization |

---

# 📹 WebRTC SDK Used

This project uses:

```yaml
flutter_webrtc
```

### Features

- Video Streaming
- Audio Streaming
- Camera Access
- Microphone Access
- ICE Candidate Exchange
- Peer Connection
- SDP Offer/Answer

---

# 📂 Folder Structure

```text
lib/
│
├── app/
│   ├── bindings/
│   └── routes/
│
├── core/
│   ├── services/
│   ├── widgets/
│   └── constants/
│
├── data/
│   ├── models/
│   └── repositories/
│
├── features/
│   ├── auth/
│   ├── client/
│   ├── dashboard/
│   ├── appointment/
│   ├── notes/
│   └── call/
│
└── main.dart
```

---

# 🚀 How to Run the App

## 1. Clone the Repository

```bash
git clone <repository_url>
cd doctor_consultation
```

## 2. Install Dependencies

```bash
flutter pub get
```

## 3. Configure Firebase

Create a Firebase project and enable:

- Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

## 4. Run the Application

```bash
flutter run
```

## Build Release APK

```bash
flutter build apk --release
```

---

# 📞 Video Calling Flow

## Doctor

1. Login
2. Accept Appointment
3. Open Appointment
4. Tap **Start Video Call**
5. Offer Generated
6. Firestore Signaling Starts

---

## Client

1. Login
2. Appointment Accepted
3. **Join Video Call** button appears
4. Tap **Join**
5. Answer Generated
6. Video Consultation Starts

---

# 🧪 How to Test Video Calling

Use **two physical devices** or **two emulators**.

## Device 1

Login as **Doctor**

## Device 2

Login as **Client**

### Steps

1. Client books an appointment.
2. Doctor receives the appointment in real time.
3. Doctor accepts the appointment.
4. Client sees the appointment status change to **Accepted**.
5. Client taps **Join Video Call**.
6. Doctor taps **Start Video Call**.
7. Verify:
   - ✅ Audio
   - ✅ Video
   - ✅ Camera Switching
   - ✅ Microphone Toggle
   - ✅ Speaker Toggle
8. End the call.
9. Verify that:
   - Appointment status changes to **Completed**
   - Call history is saved successfully

---

# 🚀 Future Improvements

- Add TURN server support for reliable WebRTC connectivity behind NAT/Firewalls.
- Implement Incoming Call Screen with ringtone and Accept/Decline actions.
- Integrate Firebase Cloud Messaging for Foreground, Background, and Terminated notifications.
- Add Payment Gateway Integration (Razorpay/Stripe).
- Add Appointment Reminders and Calendar Sync.
- Enable In-call Chat and File Sharing.
- Support Group Video Consultations.
- Add Call Recording (where legally permitted).
- Improve Offline Handling and Synchronization.
- Add Unit, Widget, and Integration Tests.
- Enhance Firestore Security Rules with Role-based Validation.
- Optimize UI/UX for Tablets and Web.

---

# 📦 Dependencies

```yaml
dependencies:
  flutter_webrtc:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  firebase_storage:
  firebase_messaging:
  get:
  intl:
```

---
