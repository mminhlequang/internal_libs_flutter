import 'package:mqtt_client/mqtt_client.dart';

enum MqttVersion {
  v31,
  v311,
  v5;

  String get displayName => switch (this) {
        v31 => '3.1',
        v311 => '3.1.1',
        v5 => '5.0',
      };
}

/// Enum representing the connection state of the Mqtt client.
// enum MqttConnectionState { connecting, connected, disconnected }

/// Abstract interface for Mqtt client wrappers.
/// This defines the common functionalities required for interacting with an Mqtt broker,
/// regardless of the underlying Mqtt protocol version (v3.1.1 or v5).
abstract class IMqttClientWrapper {
  /// Callback triggered when a message is received.
  /// Provides the topic and payload of the message.
  Function(String topic, String payload)? onMessage;

  /// Callback triggered when the client successfully connects to the broker.
  /// The boolean parameter indicates if this is a reconnection (`true`) or initial connection (`false`).
  Function(bool isReconnect)? onConnected;

  /// Callback triggered when the client disconnects from the broker.
  Function()? onDisconnected;

  /// Initializes the Mqtt client with the necessary configurations.
  ///
  /// Parameters:
  ///   [host]: The Mqtt broker host address.
  ///   [port]: The Mqtt broker port.
  ///   [identifier]: A unique client identifier.
  ///   [useWebSocket]: Whether to use WebSocket for the connection.
  ///   [keepAlivePeriod]: The keep-alive period in seconds.
  ///   [autoReconnect]: Whether the client should attempt to reconnect automatically.
  ///   [allowPrintLog]: Enable detailed logging for debugging.
  void initialize({
    required String host,
    required int port,
    required String identifier,
    bool useWebSocket = true,
    int keepAlivePeriod = 200,
    bool autoReconnect = true,
    bool allowPrintLog = false,
    MqttVersion? version,
  });

  /// Connects to the configured Mqtt broker.
  ///
  /// Optional [username] and [password] can be provided for authentication.
  Future<void> connect([String? username, String? password]);

  /// Disconnects from the Mqtt broker.
  void disconnect();

  /// Subscribes to a specific topic.
  ///
  /// Parameters:
  ///   [topic]: The topic string to subscribe to.
  ///   [qos]: The Quality of Service level for the subscription.
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce});

  /// Unsubscribes from a specific topic.
  ///
  /// Parameters:
  ///   [topic]: The topic string to unsubscribe from.
  ///   [expectAcknowledge]: Whether to expect an acknowledgment from the broker.
  void unsubscribe(String topic, {bool expectAcknowledge = false});

  /// Publishes a message to a specific topic.
  ///
  /// Parameters:
  ///   [topic]: The topic string to publish to.
  ///   [payload]: The message payload as a string.
  ///   [qos]: The Quality of Service level for publishing.
  ///   [retain]: Whether the message should be retained by the broker.
  void publish(String topic, String payload,
      {MqttQos qos = MqttQos.atLeastOnce, bool retain = false});

  /// Gets the current connection state of the client.
  MqttConnectionState? getConnectionState();
}
