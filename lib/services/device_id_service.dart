import 'package:uuid/uuid.dart';

import 'preference_service.dart';

class DeviceIdService {
  static const Uuid _uuid = Uuid();

  static Future<String> getOrCreateDeviceId() async {
    final existingId =
    await PreferenceService.getDeviceImei();

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final deviceId = _uuid.v4();

    await PreferenceService.saveDeviceImei(deviceId);

    return deviceId;
  }
}