import 'dart:async';

import 'package:flutter/services.dart';

class WearConnectivity {
  final MethodChannel channel = const MethodChannel("wear_connectivity");

  final _messageStreamController =
  StreamController<dynamic>.broadcast();

  final _contextStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<dynamic> get messageStream =>
      _messageStreamController.stream;

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

  Future<bool> get isSupported async {
    final supported = await channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  Future<bool> get isPaired async {
    final paired = await channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  Future<bool> get isReachable async {
    final reachable = await channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  Future<bool> get isAppWatchInstalled async {
    final isInstalled = await channel.invokeMethod<bool>('isAppWatchInstalled');
    return isInstalled ?? false;
  }


  /// Send a message to all connected watches
  Future<T?> sendMessage<T>(List<dynamic> args) {
    return channel.invokeMethod('sendMessage', args);
  }

  Future<T?> updateApplicationContext<T>(List<dynamic> context) {
    return channel.invokeMethod('updateApplicationContext', context);
  }

  Future<List<dynamic>> get applicationContext async {
    final applicationContext =
    await channel.invokeListMethod<dynamic>('applicationContext');
    return applicationContext ?? [];
  }

  /// A dictionary containing the last update data received
  Future<List<dynamic>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
    await channel.invokeListMethod('receivedApplicationContexts');
    final transformedContexts = receivedApplicationContexts?.toList();
    return transformedContexts ?? [];
  }
}
