// // ignore_for_file: avoid_print

// // Web-specific implementation for MqttV3ClientWrapper

// import 'dart:async';
// import 'dart:typed_data';

// // Import necessary MqttClient types
// import 'package:mqtt_client/mqtt_client.dart';
// // Import MqttBrowserClient specifically
// import 'package:mqtt_client/mqtt_browser_client.dart';

// import 'i_mqtt_client_wrapper.dart';

// /// Web implementation of IMqttClientWrapper using MqttBrowserClient (MQTT v3.1.1).
// class MqttV3ClientWrapper implements IMqttClientWrapper {
//   // Use MqttBrowserClient specifically, but variable typed as MqttClient
//   MqttClient? _client;
//   String? _host;
//   int? _port;
//   String? _identifier;
//   bool _allowPrintLog = false;
//   bool _autoReconnect = true;
//   int _keepAlivePeriod = 200;

//   StreamSubscription? _subscription;

//   @override
//   Function(String topic, String payload)? onMessage;

//   @override
//   Function(bool isReconnect)? onConnected;

//   @override
//   Function()? onDisconnected;

//   @override
//   void initialize({
//     required String host,
//     required int port,
//     required String identifier,
//     // useWebSocket is ignored on web, BrowserClient always uses WebSockets
//     bool useWebSocket = true,
//     int keepAlivePeriod = 200,
//     bool autoReconnect = true,
//     bool allowPrintLog = false,
//     MqttVersion? version, // Added version param for consistency
//   }) {
//     _host = host;
//     _port = port;
//     _identifier = identifier;
//     _keepAlivePeriod = keepAlivePeriod;
//     _autoReconnect = autoReconnect;
//     _allowPrintLog = allowPrintLog;

//     if (_allowPrintLog)
//       print('MQTT V3 (Web): Initializing MqttBrowserClient...');

//     // Instantiate MqttBrowserClient for web
//     _client = MqttBrowserClient(_host!, _identifier!)
//       ..port = _port!
//       ..logging(on: allowPrintLog) // Corrected: Use allowPrintLog passed in
//       ..keepAlivePeriod = _keepAlivePeriod
//       ..autoReconnect = _autoReconnect
//       // Assign callbacks
//       ..onConnected = _onConnectedCallback
//       ..onDisconnected = _onDisconnectedCallback
//       ..onAutoReconnected = _onReconnectedCallback
//       ..onSubscribed = _onSubscribedCallback;
//     // No need to set useWebSocket or websocketProtocols for BrowserClient

//     // Set protocol (assuming MqttBrowserClient supports this)
//     if (version == MqttVersion.v311 || version == null) {
//       _client!.setProtocolV311();
//     } else if (version == MqttVersion.v31) {
//       _client!.setProtocolV31();
//     }

//     final connMess = MqttConnectMessage()
//         .withClientIdentifier(_identifier!)
//         .withWillQos(MqttQos.atMostOnce);

//     _client!.connectionMessage = connMess;
//   }

//   // --- Other methods remain largely the same as they use the MqttClient interface ---

//   @override
//   Future<void> connect([String? username, String? password]) async {
//     assert(_client != null, 'Client must be initialized before connecting.');
//     try {
//       if (_allowPrintLog) {
//         print('MQTT V3 (Web): Connecting...');
//       }
//       await _client!.connect(username, password);
//     } on Exception catch (e) {
//       if (_allowPrintLog) print('MQTT V3 (Web): Connect exception - $e');
//       disconnect();
//       throw e;
//     }
//   }

//   @override
//   void disconnect() {
//     if (_allowPrintLog) print('MQTT V3 (Web): Disconnecting...');
//     _client?.autoReconnect = false;
//     _client?.disconnect();
//     _cleanUpSubscription();
//   }

//   @override
//   void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
//     assert(_client != null, 'Client not initialized');
//     if (_allowPrintLog) print('MQTT V3 (Web): Subscribing to $topic');
//     _client!.subscribe(topic, qos);
//   }

//   @override
//   void unsubscribe(String topic, {bool expectAcknowledge = false}) {
//     assert(_client != null, 'Client not initialized');
//     if (_allowPrintLog) print('MQTT V3 (Web): Unsubscribing from $topic');
//     _client!.unsubscribe(topic, expectAcknowledge: expectAcknowledge);
//   }

//   @override
//   void publish(String topic, String payload,
//       {MqttQos qos = MqttQos.atLeastOnce, bool retain = false}) {
//     assert(_client != null, 'Client not initialized');
//     // MqttBrowserClient should provide MqttClientPayloadBuilder or similar
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(payload);
//     if (_allowPrintLog) {
//       print('MQTT V3 (Web): Publishing to $topic');
//     }
//     _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
//   }

//   @override
//   MqttConnectionState? getConnectionState() {
//     if (_client?.connectionStatus == null)
//       return MqttConnectionState.disconnected;
//     switch (_client!.connectionStatus!.state) {
//       case MqttConnectionState.connecting:
//         return MqttConnectionState.connecting;
//       case MqttConnectionState.connected:
//         return MqttConnectionState.connected;
//       case MqttConnectionState.disconnecting:
//       case MqttConnectionState.disconnected:
//       case MqttConnectionState.faulted:
//         return MqttConnectionState.disconnected;
//     }
//   }

//   // --- Internal Callbacks ---

//   void _onSubscribedCallback(String topic) {
//     if (_allowPrintLog) print('MQTT V3 (Web): Subscribed to $topic');
//   }

//   void _onDisconnectedCallback() {
//     _cleanUpSubscription();
//     if (_allowPrintLog) {
//       print('MQTT V3 (Web): Disconnected.');
//       // Browser client might not have returnCode
//       // if (_client?.connectionStatus?.returnCode == MqttConnectReturnCode.noneSpecified) { ... }
//     }
//     onDisconnected?.call();
//   }

//   void _onConnectedCallback() {
//     if (_allowPrintLog) print('MQTT V3 (Web): Connected.');
//     _setupMessageListener();
//     onConnected?.call(false);
//   }

//   void _onReconnectedCallback() {
//     if (_allowPrintLog) print('MQTT V3 (Web): Reconnected.');
//     _setupMessageListener();
//     onConnected?.call(true);
//   }

//   void _setupMessageListener() {
//     _subscription?.cancel();
//     _subscription =
//         _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       if (c != null && c.isNotEmpty) {
//         final MqttReceivedMessage<MqttMessage?> recMess = c[0];
//         if (recMess.payload is MqttPublishMessage) {
//           final MqttPublishMessage pubMess =
//               recMess.payload as MqttPublishMessage;
//           final messageBytes = pubMess.payload.message;
//           if (messageBytes != null) {
//             final String payload =
//                 MqttPublishPayload.bytesToStringAsString(messageBytes);
//             final String topic = recMess.topic;
//             if (_allowPrintLog) {
//               print('MQTT V3 (Web): Received <$topic>: $payload');
//             }
//             onMessage?.call(topic, payload);
//           } else {
//             if (_allowPrintLog) {
//               print(
//                   'MQTT V3 (Web): Received publish message with null payload on topic ${recMess.topic}');
//             }
//           }
//         } else {
//           if (_allowPrintLog) {
//             print(
//                 'MQTT V3 (Web): Received non-publish message: ${recMess.payload?.toString()}');
//           }
//         }
//       }
//     });
//   }

//   void _cleanUpSubscription() {
//     _subscription?.cancel();
//     _subscription = null;
//   }
// }
