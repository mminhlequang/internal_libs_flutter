// // ignore_for_file: avoid_print

// // Web-specific implementation for MqttV5ClientWrapper

// import 'dart:async';
// import 'dart:convert'; // Import for utf8.decode

// // Import the Mqtt v5 client library types with alias
// import 'package:mqtt5_client/mqtt5_client.dart' as mqtt5;
// // Import the Mqtt v5 browser client specifically
// import 'package:mqtt5_client/mqtt5_browser_client.dart' as mqtt5_browser;

// // Import only MqttQos and MqttConnectionState from mqtt_client for interface compatibility
// import 'package:mqtt_client/mqtt_client.dart' show MqttQos, MqttConnectionState;

// // Import interface definition
// import 'i_mqtt_client_wrapper.dart';

// // Helper function to convert MqttQos (mqtt_client) to MqttQos (mqtt5_client)
// // (Keep this helper as it's used in publish/subscribe methods)
// mqtt5.MqttQos _toMqtt5Qos(MqttQos qos) {
//   switch (qos) {
//     case MqttQos.atMostOnce:
//       return mqtt5.MqttQos.atMostOnce;
//     case MqttQos.atLeastOnce:
//       return mqtt5.MqttQos.atLeastOnce;
//     case MqttQos.exactlyOnce:
//       return mqtt5.MqttQos.exactlyOnce;
//     default:
//       return mqtt5.MqttQos.atMostOnce;
//   }
// }

// /// Web implementation of IMqttClientWrapper using mqtt5_browser.MqttBrowserClient.
// class MqttV5ClientWrapper implements IMqttClientWrapper {
//   // Use MqttBrowserClient specifically, but variable typed as MqttClient
//   mqtt5.MqttClient? _client;
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
//     // useWebSocket is ignored on web
//     bool useWebSocket = true,
//     int keepAlivePeriod = 200,
//     bool autoReconnect = true,
//     bool allowPrintLog = false,
//     MqttVersion? version, // Keep for consistency
//   }) {
//     _host = host;
//     _port = port;
//     _identifier = identifier;
//     _keepAlivePeriod = keepAlivePeriod;
//     _autoReconnect = autoReconnect;
//     _allowPrintLog = allowPrintLog;

//     if (_allowPrintLog)
//       print('MQTT V5 (Web): Initializing MqttBrowserClient...');

//     // Instantiate mqtt5_browser.MqttBrowserClient for web
//     _client = mqtt5_browser.MqttBrowserClient(_host!, _identifier!)
//       ..port = _port!
//       ..logging(on: allowPrintLog) // Use the passed flag
//       ..keepAlivePeriod = _keepAlivePeriod
//       ..autoReconnect = _autoReconnect
//       // Assign callbacks
//       ..onConnected = _onConnectedCallback
//       ..onDisconnected = _onDisconnectedCallback
//       ..onAutoReconnected = _onReconnectedCallback
//       ..onSubscribed = _onSubscribedCallback;
//     // Browser client uses WebSockets by default

//     // Connection Message setup (uses mqtt5 types)
//     final connMess = mqtt5.MqttConnectMessage()
//         .withClientIdentifier(_identifier!)
//         .withWillQos(_toMqtt5Qos(MqttQos.atMostOnce));

//     _client!.connectionMessage = connMess;
//   }

//   // --- Other methods use the common mqtt5.MqttClient interface ---

//   @override
//   Future<void> connect([String? username, String? password]) async {
//     assert(_client != null, 'Client must be initialized before connecting.');
//     try {
//       if (_allowPrintLog) {
//         print('MQTT V5 (Web): Connecting...');
//       }
//       await _client!.connect(username, password);
//     } on Exception catch (e) {
//       if (_allowPrintLog) print('MQTT V5 (Web): Connect exception - $e');
//       disconnect();
//       throw e;
//     }
//   }

//   @override
//   void disconnect() {
//     if (_allowPrintLog) print('MQTT V5 (Web): Disconnecting...');
//     _client?.autoReconnect = false;
//     _client?.disconnect();
//     _cleanUpSubscription();
//   }

//   @override
//   void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
//     assert(_client != null, 'Client not initialized');
//     final mqtt5.MqttQos v5Qos = _toMqtt5Qos(qos);
//     if (_allowPrintLog)
//       print('MQTT V5 (Web): Subscribing to $topic with QoS $v5Qos');
//     _client!.subscribe(topic, v5Qos);
//   }

//   @override
//   void unsubscribe(String topic, {bool expectAcknowledge = false}) {
//     assert(_client != null, 'Client not initialized');
//     if (_allowPrintLog) print('MQTT V5 (Web): Unsubscribing from $topic');
//     _client!.unsubscribeStringTopic(topic);
//   }

//   @override
//   void publish(String topic, String payload,
//       {MqttQos qos = MqttQos.atLeastOnce, bool retain = false}) {
//     assert(_client != null, 'Client not initialized');
//     final builder = mqtt5.MqttPayloadBuilder();
//     builder.addString(payload);
//     final mqtt5.MqttQos v5Qos = _toMqtt5Qos(qos);

//     if (_allowPrintLog) {
//       print(
//           'MQTT V5 (Web): Publishing to $topic, QoS: $v5Qos, Retain: $retain');
//     }
//     _client!.publishMessage(topic, v5Qos, builder.payload!, retain: retain);
//   }

//   @override
//   MqttConnectionState? getConnectionState() {
//     // Return the MqttConnectionState from mqtt_client for interface consistency
//     if (_client?.connectionStatus == null)
//       return MqttConnectionState.disconnected;
//     // Compare against mqtt5 specific states
//     switch (_client!.connectionStatus!.state) {
//       case mqtt5.MqttConnectionState.connecting:
//         return MqttConnectionState.connecting;
//       case mqtt5.MqttConnectionState.connected:
//         return MqttConnectionState.connected;
//       case mqtt5.MqttConnectionState.disconnecting:
//       case mqtt5.MqttConnectionState.disconnected:
//       case mqtt5.MqttConnectionState.faulted:
//         return MqttConnectionState.disconnected;
//     }
//   }

//   // --- Internal Callbacks ---

//   void _onSubscribedCallback(mqtt5.MqttSubscription subscription) {
//     if (_allowPrintLog)
//       print('MQTT V5 (Web): Subscribed to ${subscription.topic}');
//   }

//   void _onDisconnectedCallback() {
//     _cleanUpSubscription();
//     if (_allowPrintLog) {
//       print('MQTT V5 (Web): Disconnected.');
//     }
//     onDisconnected?.call();
//   }

//   void _onConnectedCallback() {
//     if (_allowPrintLog) print('MQTT V5 (Web): Connected.');
//     _setupMessageListener();
//     onConnected?.call(false);
//   }

//   void _onReconnectedCallback() {
//     if (_allowPrintLog) print('MQTT V5 (Web): Reconnected.');
//     _setupMessageListener();
//     onConnected?.call(true);
//   }

//   void _setupMessageListener() {
//     _subscription?.cancel();
//     _subscription = _client!.updates
//         .listen((List<mqtt5.MqttReceivedMessage<mqtt5.MqttMessage>> c) {
//       if (c.isNotEmpty) {
//         final mqtt5.MqttReceivedMessage<mqtt5.MqttMessage> recMessage = c[0];
//         if (recMessage.payload is mqtt5.MqttPublishMessage) {
//           final mqtt5.MqttPublishMessage pubMess =
//               recMessage.payload as mqtt5.MqttPublishMessage;
//           final String payload = utf8.decode(pubMess.payload.message!);
//           final String? topic = recMessage.topic;

//           if (topic != null) {
//             if (_allowPrintLog) {
//               print('MQTT V5 (Web): Received <$topic>: $payload');
//             }
//             onMessage?.call(topic, payload);
//           } else {
//             if (_allowPrintLog) {
//               print('MQTT V5 (Web): Received message with null topic.');
//             }
//           }
//         } else {
//           if (_allowPrintLog) {
//             print(
//                 'MQTT V5 (Web): Received non-publish message type ${recMessage.payload.runtimeType} on topic ${recMessage.topic ?? 'null'}');
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
