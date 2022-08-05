import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class DevicesChanged {
  const DevicesChanged();
}

class PreferencesTrigger {}

class PreferencesChanged {
  final String fileTypeFilter;
  const PreferencesChanged(this.fileTypeFilter);
}

class RescanDevice {
  final int index;

  const RescanDevice(this.index);
}
