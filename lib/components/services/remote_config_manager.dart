import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigManager {
  // Fetch Remote Config values
  Future<void> fetchRemoteConfig() async {
    try {
      // Initialize RemoteConfig
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Fetch and activate Remote Config values
      await remoteConfig.fetch();
      await remoteConfig.activate();

      // Example: Fetch parameters
      String encryptionKey = remoteConfig.getString('encryption_key');
      bool isMaintenanceMode = remoteConfig.getBool('maintenance_mode');
      int minSupportedVersion = remoteConfig.getInt('min_supported_version');

      // Log or use these values
      print('Encryption Key: $encryptionKey');
      print('Maintenance Mode: $isMaintenanceMode');
      print('Min Supported Version: $minSupportedVersion');

    } catch (e) {
      print("Error fetching remote config: $e");
    }
  }
}
