import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/call_repository.dart';

/// A single lifecycle event observed on a ringing call document.
class CallStateEvent {
  const CallStateEvent({this.status});

  /// Marks a call document that was removed (doctor ended before answer).
  const CallStateEvent.deleted() : status = null;

  /// The call document's `status` field, or null when the document was
  /// deleted (see [CallStateEvent.deleted]).
  final String? status;
}

/// Watches a call document and forwards lifecycle changes to the incoming
/// call flow, so a ringing client reacts to the call being answered, missed,
/// rejected or cancelled by the doctor without polling.
class CallStateListener {
  CallStateListener(this._repository);

  final CallRepository _repository;

  StreamSubscription<DocumentSnapshot>? _subscription;

  /// Invoked on every meaningful call-document change while listening.
  void Function(CallStateEvent event)? onState;

  /// Start watching [callId]. Replaces any previous subscription.
  void listen(String callId) {
    cancel();
    _subscription = _repository.listenCall(callId).listen(
          (snapshot) {
            final callback = onState;
            if (callback == null) return;
            if (!snapshot.exists) {
              callback(const CallStateEvent.deleted());
              return;
            }
            final data = snapshot.data() as Map<String, dynamic>? ?? {};
            final status = data['status']?.toString();
            if (status == CallStatus.active ||
                status == CallStatus.rejected ||
                status == CallStatus.missed ||
                status == CallStatus.ended) {
              callback(CallStateEvent(status: status));
            }
          },
          onError: (Object error) {
            debugPrint('CallStateListener error: $error');
          },
        );
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
