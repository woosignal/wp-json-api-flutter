// Copyright (c) 2020, WooSignal Ltd.
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

import 'package:flutter/widgets.dart';
import 'package:wp_json_api/helpers/typedefs.dart';
import 'package:wp_json_api/networking/network_manager.dart';

/// The base class to initialize and use WPJSONAPI
class WPJsonAPI {

  /// Private constructor for WPJSONAPI
  WPJsonAPI._privateConstructor();

  /// Instance of WPJSONAPI
  static final WPJsonAPI instance = WPJsonAPI._privateConstructor();

  /// The base url for the WordPress Site e.g. https://mysitewp.com
  String _baseUrl;

  /// Debug boolean for outputting to the log
  bool _shouldDebug;

  /// Default API root for your WordPress site
  String _apiPath = "/wp-json";

  /// Initialize and configure class interface.
  /// You can optional set [shouldDebug] == false to stop debugging
  /// [wpJsonPath] is the root path for accessing you sites WordPress APIs
  /// by default this should be "/wp-json".
  initWith(
      {@required String baseUrl,
      String wpJsonPath = '/wp-json',
      bool shouldDebug = true}) {
    _setBaseApi(baseUrl: baseUrl);
    _setApiPath(path: wpJsonPath);
    _setShouldDebug(value: shouldDebug);
  }

  /// Sets the base API in the class
  _setBaseApi({@required baseUrl}) {
    this._baseUrl = baseUrl;
  }

  /// Sets the API path in the class
  _setApiPath({@required path}) {
    this._apiPath = path;
  }

  /// Sets the debug value in the class
  _setShouldDebug({bool value}) {
    this._shouldDebug = value;
  }

  /// Returns the debug value
  bool shouldDebug() {
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
}
