import 'dart:async';

/// Decoupled event bus for session lifecycle events (e.g. 401 Unauthorized, Token Expired).
/// Ensures network interceptors communicate with domain/state layers without coupling to UI or Cubits.
abstract class SessionEventBus {
  Stream<void> get onUnauthorized;
  void notifyUnauthorized();
  void dispose();
}

class SessionEventBusImpl implements SessionEventBus {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  @override
  Stream<void> get onUnauthorized => _controller.stream;

  @override
  void notifyUnauthorized() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
