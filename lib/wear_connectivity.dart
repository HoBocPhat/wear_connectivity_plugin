import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interface to communicate with watch devices
///
/// Implementations are provided separately for each watch platform
///
/// See implementation overrides for platform-specific documentation
class WearConnectivity {
  final MethodChannel channel = const MethodChannel("wear_connectivity");

  final _messageStreamController =
  StreamController<dynamic>.broadcast();
  final _contextStreamController =
  StreamController<dynamic>.broadcast();

  /// Stream of messages received
  Stream<dynamic> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  Stream<dynamic> get contextStream =>
      _contextStreamController.stream;

  WearConnectivity() {
    channel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveMessage':
        _messageStreamController.add(call.arguments);
        break;
      case 'didReceiveApplicationContext':
        _contextStreamController.add(call.arguments);
        break;
      default:
        throw UnimplementedError('${call.method} not implemented');
    }
  }

  /// If watches are supported by the current platform
  Future<bool> get isSupported async {
    final supported = await channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  /// If a watch is paired
  Future<bool> get isPaired async {
    final paired = await channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// If the companion app is reachable
  Future<bool> get isReachable async {
    final reachable = await channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// If an app watch is installed
  Future<bool> get isAppWatchInstalled async {
    final isInstalled = await channel.invokeMethod<bool>('isAppWatchInstalled');
    return isInstalled ?? false;
  }

  /// The most recently sent contextual data
  Future<List<dynamic>> get applicationContext async {
    final applicationContext =
    await channel.invokeListMethod('applicationContext');
    return applicationContext ?? [];
  }

  /// A dictionary containing the last update data received
  Future<List<dynamic>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
    await channel.invokeListMethod('receivedApplicationContexts');
    final transformedContexts = receivedApplicationContexts?.toList();
    return transformedContexts ?? [];
  }

  /// Send a message to all connected watches
  Future<T?> sendMessage<T>(List<dynamic> args) {
    return channel.invokeMethod('sendMessage', args);
  }

  /// Update the application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) {
    return channel.invokeMethod('updateApplicationContext', context);
  }

}
