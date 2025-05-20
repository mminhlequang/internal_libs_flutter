// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';

// Import foundation for kIsWeb
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'i_mqtt_client_wrapper.dart';

/// Implementation of IMqttClientWrapper using the mqtt_client package (MQTT v3.1.1).
class MqttV3ClientWrapper implements IMqttClientWrapper {
  MqttServerClient? _client;
  String? _host;
  int? _port;
  String? _identifier;
  bool _allowPrintLog = false;
  bool _useWebSocket =
      true; // Default, will be adjusted based on platform/input
  bool _autoReconnect = true;
  int _keepAlivePeriod = 200;

  StreamSubscription? _subscription;

  @override
  Function(String topic, String payload)? onMessage;

  @override
  Function(bool isReconnect)? onConnected;

  @override
  Function()? onDisconnected;

  @override
  void initialize({
    required String host,
    required int port,
    required String identifier,
    bool useWebSocket = true, // Parameter from AppMqttClient
    int keepAlivePeriod = 200,
    bool autoReconnect = true,
    bool allowPrintLog = false,
    MqttVersion? version, // Added version param for consistency
  }) {
    _host = host;
    _port = port;
    _identifier = identifier;
    _keepAlivePeriod = keepAlivePeriod;
    _autoReconnect = autoReconnect;
    _allowPrintLog = allowPrintLog;

    // --- Platform specific adjustments ---
    if (kIsWeb) {
      if (_allowPrintLog) print('MQTT V3:: Running on Web, forcing WebSocket.');
      _useWebSocket = true; // Force WebSocket for web
    } else {
      // For non-web, respect the passed parameter
      _useWebSocket = useWebSocket;
      if (_allowPrintLog)
        print(
            'MQTT V3:: Running on Mobile/Desktop, useWebSocket: $_useWebSocket');
    }
    // --- End platform specific adjustments ---

    _client = MqttServerClient(_host!, _identifier!)
      ..port = _port!
      ..logging(on: false)
      ..keepAlivePeriod = _keepAlivePeriod
      ..autoReconnect = _autoReconnect
      // Use the potentially adjusted _useWebSocket value
      ..useWebSocket = _useWebSocket
      ..onConnected = _onConnectedCallback
      ..onDisconnected = _onDisconnectedCallback
      ..onAutoReconnected = _onReconnectedCallback
      ..onSubscribed = _onSubscribedCallback;

    // Set protocol to V3.1.1 (or as specified)
    if (version == MqttVersion.v311 || version == null) {
      _client!.setProtocolV311();
    } else if (version == MqttVersion.v31) {
      _client!.setProtocolV31();
    }

    if (_useWebSocket) {
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    } else {
      // For non-web, non-websocket connections, use secure TCP.
      if (!kIsWeb) {
        if (_allowPrintLog)
          print('MQTT V3:: Using secure TCP (requires certificate setup).');
        _client!.secure = true;
      }
    }

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier!)
        .withWillQos(MqttQos.atMostOnce);

    if (_allowPrintLog) print('MQTT V3:: Initializing client...');
    _client!.connectionMessage = connMess;
  }

  @override
  Future<void> connect([String? username, String? password]) async {
    assert(_client != null, 'Client must be initialized before connecting.');
    try {
      if (_allowPrintLog) {
        print('MQTT V3:: Connecting to host: $_host, port: $_port...');
        if (username != null) {
          print('MQTT V3:: Using username: $username');
        }
      }
      await _client!.connect(username, password);
    } on Exception catch (e) {
      if (_allowPrintLog)
        print('MQTT V3:: Client exception during connect - $e');
      disconnect();
      throw e;
    }
  }

  @override
  void disconnect() {
    if (_allowPrintLog) print('MQTT V3:: Disconnecting...');
    _client?.autoReconnect = false;
    _client?.disconnect();
    _cleanUpSubscription();
  }

  @override
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    assert(_client != null, 'Client not initialized');
    if (_allowPrintLog) print('MQTT V3:: Subscribing to $topic');
    _client!.subscribe(topic, qos);
  }

  @override
  void unsubscribe(String topic, {bool expectAcknowledge = false}) {
    assert(_client != null, 'Client not initialized');
    if (_allowPrintLog) print('MQTT V3:: Unsubscribing from $topic');
    _client!.unsubscribe(topic, expectAcknowledge: expectAcknowledge);
  }

  @override
  void publish(String topic, String payload,
      {MqttQos qos = MqttQos.atLeastOnce, bool retain = false}) {
    assert(_client != null, 'Client not initialized');
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    if (_allowPrintLog) {
      print('MQTT V3:: Publishing to $topic');
    }
    _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  @override
  MqttConnectionState? getConnectionState() {
    if (_client?.connectionStatus == null)
      return MqttConnectionState.disconnected;
    switch (_client!.connectionStatus!.state) {
      case MqttConnectionState.connecting:
        return MqttConnectionState.connecting;
      case MqttConnectionState.connected:
        return MqttConnectionState.connected;
      case MqttConnectionState.disconnecting:
      case MqttConnectionState.disconnected:
      case MqttConnectionState.faulted:
        return MqttConnectionState.disconnected;
    }
  }

  // --- Internal Callbacks ---

  void _onSubscribedCallback(String topic) {
    if (_allowPrintLog) print('MQTT V3:: Subscribed to $topic');
  }

  void _onDisconnectedCallback() {
    _cleanUpSubscription();
    if (_allowPrintLog) {
      print('MQTT V3:: Disconnected.');
      if (_client?.connectionStatus?.returnCode ==
          MqttConnectReturnCode.noneSpecified) {
        print('MQTT V3:: Disconnect was solicited.');
      }
    }
    onDisconnected?.call();
  }

  void _onConnectedCallback() {
    if (_allowPrintLog) print('MQTT V3:: Connected.');
    _setupMessageListener();
    onConnected?.call(false);
  }

  void _onReconnectedCallback() {
    if (_allowPrintLog) print('MQTT V3:: Reconnected.');
    _setupMessageListener();
    onConnected?.call(true);
  }

  void _setupMessageListener() {
    _subscription?.cancel();
    _subscription =
        _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final MqttReceivedMessage<MqttMessage?> recMess = c[0];
        if (recMess.payload is MqttPublishMessage) {
          final MqttPublishMessage pubMess =
              recMess.payload as MqttPublishMessage;
          final messageBytes = pubMess.payload.message;
          if (messageBytes != null) {
            final String payload =
                MqttPublishPayload.bytesToStringAsString(messageBytes);
            final String topic = recMess.topic;
            if (_allowPrintLog) {
              print('MQTT V3:: Received <$topic>: $payload');
            }
            onMessage?.call(topic, payload);
          } else {
            if (_allowPrintLog) {
              print(
                  'MQTT V3:: Received publish message with null payload on topic ${recMess.topic}');
            }
          }
        } else {
          if (_allowPrintLog) {
            print(
                'MQTT V3:: Received non-publish message: ${recMess.payload?.toString()}');
          }
        }
      }
    });
  }

  void _cleanUpSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }
}
