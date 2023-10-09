// https://book.flutterchina.club/chapter8/eventbus.html
// Subscriber callback signature
// https://dart.dev/language/typedefs
// typedef void EventCallback(arg);
// recommended syntax
typedef EventCallback<T> = void Function(T arg);

class EventBus {
// Private constructor
  EventBus._internal();

// Singleton instance
  static final EventBus _singleton = EventBus._internal();

// Factory constructor
  factory EventBus() => _singleton;

// Map to store event subscribers, key: event name (id), value: corresponding event subscriber list
  final _emap = <Object, List<EventCallback>?>{};

// Add a subscriber
  void on(eventName, EventCallback f) {
    _emap[eventName] ??= <EventCallback>[];
    _emap[eventName]!.add(f);
  }

// Remove a subscriber
  void off(eventName, [EventCallback? f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

// Trigger an event, all subscribers of the event will be called
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
// Traverse in reverse order to prevent index mismatch caused by a subscriber removing itself during the callback
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}

// Define a top-level (global) variable, after importing this file, the page can directly use bus
var bus = EventBus();
