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
