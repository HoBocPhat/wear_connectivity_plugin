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
    final supported = await channel.invokeMethod<bool>('IS_SUPPORT');
    return supported ?? false;
  }

  Future<bool> get isPaired async {
    final paired = await channel.invokeMethod<bool>('IS_PAIRED');
    return paired ?? false;
  }

  Future<bool> get isReachable async {
    final reachable = await channel.invokeMethod<bool>('IS_REACHABLE');
    return reachable ?? false;
  }

  Future<bool> get isAppWatchInstalled async {
    final isInstalled = await channel.invokeMethod<bool>('IS_APP_WATCH_INSTALLED');
    return isInstalled ?? false;
  }

  Future<T?> sendMessage<T>(List<dynamic> args) {
    return channel.invokeMethod('SEND_MESSAGE', args);
  }

  Future<T?> updateApplicationContext<T>(List<dynamic> context) {
    return channel.invokeMethod('UPDATE_APPLICATION_CONTEXT', context);
  }

  Future<List<dynamic>> get applicationContext async {
    final applicationContext =
    await channel.invokeListMethod<dynamic>('METHOD_APPLICATION_CONTEXT');
    return applicationContext ?? [];
  }

  Future<List<dynamic>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
    await channel.invokeListMethod('METHOD_RECEIVED_APPLICATION_CONTEXTS');
    final transformedContexts = receivedApplicationContexts?.toList();
    return transformedContexts ?? [];
  }
}
