// Copyright (c) 2024, WooSignal Ltd.
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

library wp_json_api;

import 'package:nylo_support/helpers/auth.dart';
import 'package:nylo_support/helpers/helper.dart';
import '/helpers/typedefs.dart';
import '/models/wp_user.dart';
import '/networking/network_manager.dart';

/// The version of the wp_json_api
String _wpJsonAPIVersion = "3.5.2";

/// The base class to initialize and use WPJsonAPI
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

  /// Initialize and configure class interface.
  /// You can optional set [shouldDebug] == false to stop debugging
  /// [wpJsonPath] is the root path for accessing you sites WordPress APIs
  /// by default this should be "/wp-json".
  init(
      {required String baseUrl,
      String wpJsonPath = '/wp-json',
      bool shouldDebug = true}) {
    _setBaseApi(baseUrl: baseUrl);
    _setApiPath(path: wpJsonPath);
    _setShouldDebug(value: shouldDebug);
  }

  /// Login a user with the [WpUser]
  static wpLogin(WpUser wpUser) async {
    await Auth.set(wpUser, key: storageKey());
  }

  /// Logout a user
  static wpLogout() async {
    await Auth.remove(key: storageKey());
  }

  /// Authenticate a user if they are logged in
  static wpAuth() async {
    await Auth.loginModel(
        WPJsonAPI.storageKey(), (data) => WpUser.fromJson(data));
  }

  /// Check if a user is logged in
  static Future<bool> wpUserLoggedIn() async {
    WpUser? _wpUser = await wpUser();
    if (_wpUser == null) {
      return false;
    }
    if (_wpUser.token == null) {
      return false;
    }
    return true;
  }

  /// Returns the logged in user
  static Future<WpUser?> wpUser() async {
    return await NyStorage.read<WpUser>(storageKey(), modelDecoders: {
      WpUser: (json) => WpUser.fromJson(json),
    });
  }

  /// Returns the user ID of the logged in user
  static Future<String?> wpUserId() async {
    WpUser? _wpUser = await wpUser();
    return _wpUser?.id.toString();
  }

  /// Get the token for the user
  static Future<String?> wpUserToken() async {
    WpUser? _wpUser = await wpUser();
    if (_wpUser == null) return null;
    return _wpUser.token;
  }

  /// Sets the base API in the class
  _setBaseApi({required baseUrl}) {
    this._baseUrl = baseUrl;
  }

  /// Sets the API path in the class
  _setApiPath({required path}) {
    this._apiPath = path;
  }

  /// Sets the debug value in the class
  _setShouldDebug({bool? value}) {
    this._shouldDebug = value;
  }

  /// Returns the debug value
  bool? shouldDebug() {
    return this._shouldDebug;
  }

  /// Returns the base API
  String getBaseApi() {
    return this._baseUrl + this._apiPath;
  }

  /// Returns an instance of [WPAppNetworkManager] which you can use to call
  /// your requests from.
  api(RequestCallback request) async {
    return await request(WPAppNetworkManager.instance);
  }

  /// Returns the storage key for the plugin
  static String storageKey() => "wp_json_api";
}
