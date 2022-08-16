import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const methodSendMessage = "SEND_MESSAGE";
const methodIsAvailable = "IS_AVAILABLE";
const methodIsAppWatchInstalled = "IS_APP_WATCH_INSTALLED";
const methodIsPaired = "IS_PAIRED";
const methodIsReachable = "IS_REACHABLE";
const methodIsSupport = "IS_SUPPORT";
const methodReceivedApplicationContexts = "METHOD_RECEIVED_APPLICATION_CONTEXTS";
const methodApplicationContext = "METHOD_APPLICATION_CONTEXT";
const methodUpdateApplicationContext = "UPDATE_APPLICATION_CONTEXT";

const didReceiveMessage = "DID_RECEIVE_MESSAGE";
const didReceiveApplicationContext = "DID_RECEIVE_APPLICATION_CONTEXT";
const didReceiveSessionDidBecomeInactive = "SESSION_DID_BECOME_INACTIVE";
const didSessionDidDeActive = "SESSION_DID_DE_ACTIVE";

class WatchAppConnectivity {

  @protected
  final MethodChannel methodChannel = const MethodChannel("wear_connectivity");

  final _sessionDidBecomeActive =
  StreamController<void>.broadcast();
  final _sessionDidDeActive =
  StreamController<void>.broadcast();
  final _messageStreamController =
  StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of did become active received
  Stream<void> get sessionDidBecomeActive =>
      _sessionDidBecomeActive.stream;
  /// Stream of did de active received
  Stream<void> get sessionDidDeActive =>
      _sessionDidDeActive.stream;
  /// Stream of messages received
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  WatchAppConnectivity()
  {
    methodChannel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    switch (call.method) {
      case didReceiveMessage:
        _messageStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case didReceiveApplicationContext:
        _contextStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      default:
        throw UnimplementedError('${call.method} not implemented');
    }
  }

  /// If watches are supported by the current platform
  Future<bool> get isSupported async {
    final supported = await methodChannel.invokeMethod<bool>(methodIsSupport);
    return supported ?? false;
  }

  /// If a watch is paired
  Future<bool> get isPaired async {
    final paired = await methodChannel.invokeMethod<bool>(methodIsPaired);
    return paired ?? false;
  }

  /// If an app watch is installed
  Future<bool> get isAppWatchInstalled async {
    final isInstalled = await methodChannel.invokeMethod<bool>(methodIsAppWatchInstalled);
    return isInstalled ?? false;
  }

  /// If the companion app is reachable
  Future<bool> get isReachable async {
    final reachable = await methodChannel.invokeMethod<bool>(methodIsReachable);
    return reachable ?? false;
  }

  /// The most recently sent contextual data
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext =
    await methodChannel.invokeMapMethod<String, dynamic>(methodApplicationContext);
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
    await methodChannel.invokeListMethod(methodReceivedApplicationContexts);
    final transformedContexts = receivedApplicationContexts
        ?.map((e) => Map<String, dynamic>.from(e))
        .toList();
    return transformedContexts ?? [];
  }

  /// Send a message to all connected watches
  Future<void> sendMessage(Map<String, dynamic> message) {
    return _invokeSendMessage(message);
  }

  /// Update the application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) {
    return methodChannel.invokeMethod(methodUpdateApplicationContext, context);
  }

  Future<T?> _invokeSendMessage<T>(Map<String, dynamic> args) async{
    return await methodChannel.invokeMethod<T>(methodSendMessage,args);
  }


}
