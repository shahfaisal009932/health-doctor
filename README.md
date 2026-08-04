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
