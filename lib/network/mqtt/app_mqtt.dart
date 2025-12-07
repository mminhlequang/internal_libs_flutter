// // ignore_for_file: avoid_print

// import 'dart:async';

// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:internal_network/options.dart';

// // Import the main interface
// import 'i_mqtt_client_wrapper.dart';

// // Conditionally import the correct wrapper implementation
// import 'mqtt_v3_client_wrapper.dart'
//     if (dart.library.html) 'mqtt_v3_client_wrapper_web.dart';
// import 'mqtt_v5_client_wrapper.dart'
//     if (dart.library.html) 'mqtt_v5_client_wrapper_web.dart';

// /// Main application Mqtt class acting as a facade over different Mqtt versions.
// class AppMqttClient {
//   // The underlying client wrapper instance (type remains the interface)
//   IMqttClientWrapper? _clientWrapper;

//   // Keep identifier and logging flag at this level
//   final String _identifier;
//   final bool _allowPrintLog;

//   // Public callbacks to be set by the user
//   Function(String topic, String payload)? onMqttMessage;
//   Function(bool isReconnect)? onMqttConnected;
//   Function()? onMqttDisconnected;

//   // Constructor
//   // ignore: sort_constructors_first
//   AppMqttClient({
//     bool allowPrintLog = false,
//     required String identifier,
//   })  : _identifier = identifier,
//         _allowPrintLog = allowPrintLog;

//   /// Initializes the Mqtt client based on the specified version and configuration.
//   ///
//   /// [version]: The Mqtt version to use.
//   /// [hostConfig]: The host configuration.
//   /// [portConfig]: The port configuration.
//   /// [useWebSocket]: Whether to use WebSocket.
//   /// [keepAlivePeriod]: The keep alive period.
//   /// [autoReconnect]: Whether to auto reconnect.
//   ///
//   /// You should call this method after setting the callbacks.
//   void initialize({
//     required MqttVersion version, // Require specifying the version
//     String? hostConfig,
//     int? portConfig,
//     bool useWebSocket =
//         true, // This might still be relevant for non-web host config
//     int keepAlivePeriod = 200,
//     bool autoReconnect = true,
//   }) {
//     // Determine host and port using defaults if not provided
//     final String host =
//         hostConfig ?? (appMqttUrl != null ? 'wss://$appMqttUrl/mqtt' : '');
//     final int port = portConfig ?? appMqttPort ?? 80;

//     if (host.isEmpty) {
//       if (_allowPrintLog) print('Mqtt:: Error: Mqtt host is not configured.');
//       return;
//     }

//     // Instantiate the appropriate wrapper based on the version.
//     // The correct class (web or io) is instantiated automatically due to conditional imports.
//     switch (version) {
//       case MqttVersion.v311:
//       case MqttVersion.v31:
//         _clientWrapper = MqttV3ClientWrapper();
//         break;
//       case MqttVersion.v5:
//         _clientWrapper = MqttV5ClientWrapper();
//         break;
//     }

//     // Assign callbacks
//     _clientWrapper?.onMessage = onMqttMessage;
//     _clientWrapper?.onConnected = onMqttConnected;
//     _clientWrapper?.onDisconnected = onMqttDisconnected;

//     // Initialize the selected wrapper (it will use the correct client internally)
//     _clientWrapper?.initialize(
//       host: host,
//       port: port,
//       identifier: _identifier,
//       useWebSocket:
//           useWebSocket, // Passed for potential non-web ServerClient config
//       keepAlivePeriod: keepAlivePeriod,
//       autoReconnect: autoReconnect,
//       allowPrintLog: _allowPrintLog,
//       version: version,
//     );

//     if (_allowPrintLog)
//       print(
//           'Mqtt:: Initialized wrapper for version: $version (Platform specific implementation loaded)');
//   }

//   // Connect - Delegate to wrapper
//   Future<void> connect([String? username, String? password]) async {
//     assert(_clientWrapper != null,
//         'Mqtt Client not initialized. Call initializeMqttClient first.');
//     if (_allowPrintLog) print('Mqtt:: Calling connect on wrapper...');
//     await _clientWrapper!.connect(username, password);
//   }

//   // Disconnect - Delegate to wrapper
//   void disconnect() {
//     assert(_clientWrapper != null, 'Mqtt Client not initialized.');
//     if (_allowPrintLog) print('Mqtt:: Calling disconnect on wrapper...');
//     _clientWrapper!.disconnect();
//   }

//   // Subscribe - Delegate to wrapper
//   void subscribeTo(String channel, {MqttQos mqttQos = MqttQos.atLeastOnce}) {
//     assert(_clientWrapper != null, 'Mqtt Client not initialized.');
//     if (_allowPrintLog)
//       print('Mqtt:: Calling subscribe on wrapper for topic: $channel');
//     _clientWrapper!.subscribe(channel, qos: mqttQos);
//   }

//   // Unsubscribe - Delegate to wrapper
//   void unsubscribeTo(String channel, {bool expectAcknowledge = false}) {
//     assert(_clientWrapper != null, 'Mqtt Client not initialized.');
//     if (_allowPrintLog)
//       print('Mqtt:: Calling unsubscribe on wrapper for topic: $channel');
//     _clientWrapper!.unsubscribe(channel, expectAcknowledge: expectAcknowledge);
//   }

//   /// Publishes a message - Delegate to wrapper
//   void publish(String topic, String payload,
//       {MqttQos qos = MqttQos.atLeastOnce, bool retain = false}) {
//     assert(_clientWrapper != null, 'Mqtt Client not initialized.');
//     if (_allowPrintLog)
//       print('Mqtt:: Calling publish on wrapper for topic: $topic');
//     _clientWrapper!.publish(topic, payload, qos: qos, retain: retain);
//   }

//   /// Gets the current connection state - Delegate to wrapper
//   MqttConnectionState? getConnectionState() {
//     assert(_clientWrapper != null, 'Mqtt Client not initialized.');
//     return _clientWrapper!.getConnectionState();
//   }
// }
