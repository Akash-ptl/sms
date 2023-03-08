import 'dart:async';

class EventsBroadcast {
  EventsBroadcast._private()
      : _streamController = StreamController.broadcast(
          sync: false,
        );

  static EventsBroadcast _eventsBroadcast = EventsBroadcast._private();

  static EventsBroadcast get() {
    return _eventsBroadcast;
  }

  StreamController _streamController;

  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  void send(event) {
    _streamController.add(event);
  }
}

class SmsStatusEvent {
  SmsStatusEvent({required this.smsSent});

  final bool smsSent;
}
