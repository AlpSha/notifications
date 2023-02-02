import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Data object for each notification event.
class NotificationEvent {
  /// The name of the package sending the notification.
  String? packageName;

  /// The title of the notification.
  String? title;

  /// The message in the notification.
  String? message;

  /// The timestamp of the notification.
  DateTime? timeStamp;

  NotificationEvent({
    this.packageName,
    this.title,
    this.message,
    this.timeStamp,
  });

  factory NotificationEvent.fromMap(Map<dynamic, dynamic> map) {
    DateTime time = DateTime.now();
    String? name = map['packageName'];
    String? message = map['message'];
    String? title = map['title'];

    return NotificationEvent(
      packageName: name,
      title: title,
      message: message,
      timeStamp: time,
    );
  }

  @override
  String toString() =>
      '$runtimeType - package: $packageName, title: $title, message: $message, timestamp: $timeStamp';
}

NotificationEvent _notificationEvent(dynamic data) {
  return new NotificationEvent.fromMap(data);
}

/// Notification handler.
///
/// Use the [notificationStream] to listen to notifications. Like:
///
/// ````
///     Notifications().notificationStream!.listen((event) => print(event));
/// ````
class Notifications {
  static const EventChannel _notificationEventChannel =
      EventChannel('notifications');

  static const MethodChannel _permissionsMethodChannel = MethodChannel('notifications/permissions');

  Stream<NotificationEvent>? _notificationStream;

  Stream<NotificationEvent>? get notificationStream {
    if (Platform.isAndroid) {
      if (_notificationStream == null) {
        _notificationStream = _notificationEventChannel
            .receiveBroadcastStream()
            .map((event) => _notificationEvent(event));
      }
      return _notificationStream;
    }
    throw NotificationException(
        'Notification API exclusively available on Android!');
  }

  Future<bool> getIsPermissionGranted() async {
    final response = await _permissionsMethodChannel.invokeMethod<bool>('getPermissionsState');
    return response == true;
  }

  Future<void> requestPermission() async {
    await _permissionsMethodChannel.invokeMethod<void>('requestPermission');
  }
}

/// Custom Exception for the plugin.
/// Thrown whenever the plugin is used on platforms other than Android.
class NotificationException implements Exception {
  String message;

  NotificationException(this.message);

  @override
  String toString() => '$runtimeType - $message';
}
