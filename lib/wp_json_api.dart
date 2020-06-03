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

class WPJsonAPI {
  WPJsonAPI._privateConstructor();

  static final WPJsonAPI instance = WPJsonAPI._privateConstructor();

  String _baseUrl;
  bool _shouldDebug;
  String _apiPath = "/wp-json";

  initWith(
      {@required String baseUrl,
      String wpJsonPath = '/wp-json',
      bool shouldDebug = true}) {
    _setBaseApi(baseUrl: baseUrl);
    _setApiPath(path: wpJsonPath);
    _setShouldDebug(value: shouldDebug);
  }

  _setBaseApi({@required baseUrl}) {
    this._baseUrl = baseUrl;
  }

  _setApiPath({@required path}) {
    this._apiPath = path;
  }

  _setShouldDebug({bool value}) {
    this._shouldDebug = value;
  }

  bool shouldDebug() {
    return this._shouldDebug;
  }

  String getBaseApi() {
    return this._baseUrl + this._apiPath;
  }

  api(RequestCallback request) {
    return request(WPAppNetworkManager.instance);
  }
}
