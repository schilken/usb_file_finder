import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class DevicesChanged {
  const DevicesChanged();
}

class SettingsChanged {
  final String fileTypeFilter;
  const SettingsChanged(this.fileTypeFilter);
}

class RescanDevice {
  final int index;

  const RescanDevice(this.index);
}
