# Dr Serv - Doctor Consultation App

A production-ready Flutter application for doctors to manage patient appointments, conduct WebRTC video consultations, and maintain session notes.

## Features

### 1. Authentication
- **Doctor Login** - Email + password with form validations
- **Register** - Create account with full name, email, password
- **Forgot Password** - Password reset via Firebase email link
- **Route Guards** - Protected routes redirect unauthenticated users to login
- **Doctor Profile** - Saved to Firestore on registration

### 2. Doctor Dashboard
- Personalized greeting with doctor name
- Today's appointments (live from Firestore)
- Appointment status chips (Confirmed / Unconfirmed / Cancelled)
- Quick actions: Appointments, Session Notes, Video Call, Logout
- Confirm / Cancel pending appointments directly from dashboard

### 3. Appointments
- Full patient details: name, patient ID, age, phone, appointment date/time
- Status: Confirmed / Unconfirmed / Cancelled
- **Start Video Call** button (for Confirmed appointments)
- **Cancel Appointment** button with confirmation dialog (for Unconfirmed)
- View session notes for each appointment

### 4. WebRTC Video Call
- **Local video** (picture-in-picture) and **remote video** (full screen)
- **Mic on/off** toggle
- **Camera on/off** toggle
- **Switch front/back camera**
- **End call** button
- Create call / join call via shared Call ID (works between two app instances/devices)
- Firestore-based signaling: offers, answers, ICE candidates
- STUN + TURN servers for NAT traversal
- ICE candidate queue to handle candidates arriving before remote description
- Automatic permission requests (camera/microphone)

### 5. Session Notes
- Add session note
- View session notes (per appointment)
- Edit note
- Delete note (with confirmation)
- Timestamps formatted nicely

## Tech Stack
- **Flutter** (Material 3)
- **Provider** state management (MVVM architecture)
- **Firebase Authentication** (email/password)
- **Cloud Firestore** (appointments, doctors, session_notes, call signaling)
- **flutter_webrtc** (WebRTC video/audio calls)
- **go_router** (declarative routing)
- **permission_handler** (camera/mic permissions)
- **google_fonts** (Poppins typography)

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

To test the video call between two app instances:
1. Launch the app on two devices (or two emulators).
2. Log in on both with different doctor accounts.
3. On device A, go to **Video Call** and tap **Create Call**. Note the Call ID.
4. On device B, go to **Video Call**, enter the Call ID, and tap **Join Call**.
5. The video call connects both ways with full controls.

## Platform Permissions
- **Android**: Camera, microphone, and internet permissions configured in `AndroidManifest.xml`.
- **iOS**: Camera and microphone usage descriptions configured in `Info.plist`.
Doctor Consultation App-

**Overview**
Doctor Consultation is a Flutter application that enables patients and doctors to connect through real-time video consultations. Patients can book appointments, doctors can manage appointment requests, and both users can communicate using WebRTC-based video calling.

Features:-

Client (Patient)-
    1 Register/Login using Firebase Authentication
    2 View doctor list
    3 Book appointments
    4 Cancel pending appointments
    5 Receive real-time appointment status updates
    6 Join video consultation after appointment acceptance
    7 View consultation history
    8 Edit profile
    9 Receive notifications
Doctor-
    1 Register/Login
    2 View appointment requests
    3 Accept/Reject appointments
    4 Complete consultation
    5 Start video consultation
    6 Add/Edit/Delete consultation notes
    7 View patient details

Tech Stack:-
Technology-               Used-
Flutter	                  UI Framework
Dart	                    Programming Language
Firebase Authentication 	User Authentication
Cloud Firestore	          Database
Firebase Cloud            Messaging	Notifications
GetX	                    State Management & Routing
flutter_webrtc	          Video Calling
Cloud Firestore           Streams

WebRTC SDK Used:-
The project uses:  flutter_webrtc
It is responsible for:
    1 Video Streaming
    2 Audio Streaming
    3 Camera Access
    4 Microphone Access
    5 ICE Candidate Exchange
    6 Peer Connection
    7 SDP Offer/Answer

**Folder Structure**
lib/
 ├── app/
 │    ├── bindings/
 │    ├── routes/
 │
 ├── core/
 │    ├── services/
 │    ├── widgets/
 │    ├── constants/
 │
 ├── data/
 │    ├── models/
 │    ├── repositories/
 │
 ├── features/
 │    ├── auth/
 │    ├── client/
 │    ├── dashboard/
 │    ├── appointment/
 │    ├── notes/
 │    ├── call/
 │
 └── main.dart

**How to Run the App**
1. Clone Repository
   git clone <repository_url>
   cd doctor_consultation
2. Install Flutter Packages
   flutter pub get
3. Configure Firebase
   Create a Firebase project and enable:
    1 Authentication
    2 Firestore Database
    3 Firebase Storage
    4 Firebase Cloud Messaging

**Video Calling Flow**
Doctor:-
    1 Login
    2 Accept Appointment
    3 Open Appointment
    4 Tap Start Video Call
    5 Offer generated
    6 Firestore signaling starts
Client:-
    1 Login
    2 Appointment Accepted
    3 Join Video Call button appears
    4 Tap Join
    5 Answer generated
    6 Video consultation starts

**How to Test Video Calling**
Device 1
Login as Doctor.

Device 2
Login as Client.

Steps:-
    1 Client books appointment.
    2 Doctor receives appointment in real time.
    3 Doctor accepts the appointment.
    4 Client sees status change to Accepted.
    5 Client taps Join Video Call.
    6 Doctor taps Start Video Call.
    7 Verify:
        1 Audio
        2 Video
        3 Camera switching
        4 Microphone toggle
        5 Speaker toggle
    8 End the call.
    9 Verify appointment status changes to Completed and call history is saved.

    
**Future Improvements**
    1 Add TURN server support for reliable WebRTC connectivity behind NAT/firewalls.
    2 Implement incoming call screen with ringtone and accept/decline actions.
    3 Integrate full Firebase Cloud Messaging for foreground, background, and terminated           notifications.
    4 Add payment gateway integration (Razorpay/Stripe).
    5 Add appointment reminders and calendar sync.
    6 Enable file sharing and in-call chat.
    7 Support group consultations.
    8 Add call recording (where legally permitted).
    9 Improve offline handling and synchronization.
    10 Add comprehensive unit, widget, and integration tests.
    11 Enhance security with stricter Firestore rules and role-based validation.
    12 Optimize UI/UX for tablets and web.

Dependencies:-
    flutter_webrtc
    firebase_core
    firebase_auth
    cloud_firestore
    firebase_storage
    firebase_messaging
    get
    intl
