// Copyright (c) 2026, WooSignal
// All rights reserved.
//
// Redistribution and use in source and binary forms are permitted
// provided that the above copyright notice and this paragraph are
// duplicated in all such forms and that any documentation,
// advertising materials, and other materials related to such
// distribution and use acknowledge that the software was developed
// by the WooSignal. The name of the
// WooSignal may not be used to endorse or promote products derived
// from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nylo_support/helpers/src/auth.dart';
import 'package:nylo_support/local_storage/src/ny_storage.dart';
import 'package:nylo_support/local_storage/src/storage_helpers.dart';
import 'package:nylo_support/nylo.dart';
import '/helpers/typedefs.dart';
import '/models/wp_user.dart';
import '/networking/network_manager.dart';

/// The version of the wp_json_api
String _wpJsonAPIVersion = "5.0.0";

/// The base class to initialize and use WPJsonAPI.
///
/// Requires the WP JSON API WordPress plugin 5.0 or later (`wpapp/v4`).
class WPJsonAPI {
  /// Private constructor for WPJsonAPI
  WPJsonAPI._privateConstructor();

  /// Instance of WPJsonAPI
  static final WPJsonAPI instance = WPJsonAPI._privateConstructor();

  /// The base url for the WordPress Site e.g. https://mysitewp.com
  late String _baseUrl;

  /// Debug boolean for outputting to the log
  bool? _shouldDebug;

  /// Default API root for your WordPress site
  String _apiPath = "/wp-json";

  /// The version
  static String get version => _wpJsonAPIVersion;

  /// Check if Nylo is enabled
  bool _isNyloEnabled = false;

  /// Initialize and configure class interface.
  /// You can optional set [shouldDebug] == false to stop debugging
  /// [wpJsonPath] is the root path for accessing you sites WordPress APIs
  /// by default this should be "/wp-json".
  Future<void> init(
      {required String baseUrl,
      String wpJsonPath = '/wp-json',
      bool shouldDebug = true,
      Nylo? nylo}) async {
    _setBaseApi(baseUrl: baseUrl);
    _setApiPath(path: wpJsonPath);
    _setShouldDebug(value: shouldDebug);

    // nylo setup
    if (nylo != null) {
      nylo.addAuthKey(storageKey());
    }

    _isNyloEnabled = nylo != null;
  }

  /// Returns the secure storage instance
  static FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Login a user with the [WpUser]
  static Future<void> wpLogin(WpUser wpUser) async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      await storage.write(
        key: WPJsonAPI.storageKey(),
        value: jsonEncode(wpUser.toJson()),
      );
      return;
    }
    await Auth.authenticate(data: wpUser);
  }

  /// Logout a user
  static Future<void> wpLogout() async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      await storage.delete(key: WPJsonAPI.storageKey());
      return;
    }
    await Auth.logout();
  }

  /// Authenticate a user if they are logged in
  static Future<WpUser?> wpAuth() async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      String? data = await storage.read(key: WPJsonAPI.storageKey());
      if (data == null) return null;
      Map<String, dynamic> json = jsonDecode(data);
      if (json.isEmpty) return null;
      return WpUser.fromJson(json);
    }
    final dynamic data = await storageRead(WPJsonAPI.storageKey());
    if (data == null) return null;
    return WpUser.fromJson(data);
  }

  /// Check if a user is logged in.
  ///
  /// Returns false if there is no stored user, the stored user has no token,
  /// or the token has expired on this device (see [WpUser.isTokenExpired]).
  static Future<bool> wpUserLoggedIn() async {
    WpUser? user = await wpUser();
    if (user == null) return false;
    if (user.token == null || user.token!.isEmpty) return false;
    return !user.isTokenExpired;
  }

  /// Returns the logged in user
  static Future<WpUser?> wpUser() async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      String? data = await storage.read(key: WPJsonAPI.storageKey());
      if (data == null) return null;
      Map<String, dynamic> json = jsonDecode(data);
      if (json.isEmpty) return null;
      return WpUser.fromJson(json);
    }
    return await NyStorage.read<WpUser>(storageKey(), modelDecoders: {
      WpUser: (json) => WpUser.fromJson(json),
    });
  }

  /// Returns the user ID of the logged in user
  static Future<String?> wpUserId() async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      String? data = await storage.read(key: WPJsonAPI.storageKey());
      if (data == null) return null;
      Map<String, dynamic> json = jsonDecode(data);
      if (json.isEmpty) return null;
      WpUser wpUser = WpUser.fromJson(json);
      return wpUser.id.toString();
    }
    WpUser? user = await wpUser();
    return user?.id.toString();
  }

  /// Get the token for the user
  static Future<String?> wpUserToken() async {
    if (!WPJsonAPI.instance._isNyloEnabled) {
      String? data = await storage.read(key: WPJsonAPI.storageKey());
      if (data == null) return null;
      Map<String, dynamic> json = jsonDecode(data);
      if (json.isEmpty) return null;
      WpUser wpUser = WpUser.fromJson(json);
      return wpUser.token;
    }
    WpUser? user = await wpUser();
    if (user == null) return null;
    return user.token;
  }

  /// Get when the user's token expires.
  ///
  /// Returns null if there is no stored user or the expiry is unknown.
  static Future<DateTime?> wpUserTokenExpiresAt() async {
    WpUser? user = await wpUser();
    return user?.expiresAtDateTime;
  }

  /// Sets the base API in the class
  void _setBaseApi({required String baseUrl}) {
    _baseUrl = baseUrl;
  }

  /// Sets the API path in the class
  void _setApiPath({required String path}) {
    _apiPath = path;
  }

  /// Sets the debug value in the class
  void _setShouldDebug({bool? value}) {
    _shouldDebug = value;
  }

  /// Returns the debug value
  bool? shouldDebug() {
    return _shouldDebug;
  }

  /// Returns the base API
  String getBaseApi() {
    return '$_baseUrl$_apiPath';
  }

  /// Returns an instance of [WPAppNetworkManager] which you can use to call
  /// your requests from.
  Future<dynamic> api(RequestCallback request) async {
    return await request(WPAppNetworkManager.instance);
  }

  /// Returns the storage key for the plugin
  static String storageKey() => "wp_json_api";
}
