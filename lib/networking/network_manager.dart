// Copyright (c) 2020, WooSignal.
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

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:wp_json_api/enums/WPAuthType.dart';
import 'package:wp_json_api/models/responses/WCCustomerInfoResponse.dart';
import 'package:wp_json_api/models/responses/WCCustomerUpdatedResponse.dart';
import 'package:wp_json_api/models/responses/WPNonceResponse.dart';
import 'package:wp_json_api/models/responses/WPNonceVerifiedResponse.dart';
import 'package:wp_json_api/models/responses/WPUserInfoUpdatedResponse.dart';
import 'package:wp_json_api/models/responses/WPUserLoginResponse.dart';
import 'package:wp_json_api/models/responses/WPUserRegisterResponse.dart';
import 'package:wp_json_api/models/responses/WPUserResetPasswordResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:wp_json_api/enums/WPRouteType.dart';
import 'package:wp_json_api/models/responses/WPUserInfoResponse.dart';
import 'package:http/http.dart' as http;

class WPAppNetworkManager {
  WPAppNetworkManager._privateConstructor();

  static final WPAppNetworkManager instance =
      WPAppNetworkManager._privateConstructor();

  Future<WPUserLoginResponse> wpLogin(
      {String email,
      String username,
      @required String password,
      WPAuthType authType = WPAuthType.WpEmail,
      String tokenExpiryAt}) async {
    WPNonceResponse wpNonceResponse = await wpNonce();

    if (wpNonceResponse != null) {
      Map<String, dynamic> payload = {};
      if (username != null) payload["username"] = username;
      if (email != null) payload["email"] = email;
      payload["password"] = password;
      payload["nonce"] = wpNonceResponse.data.nonce;
      if (tokenExpiryAt != null) payload["expiry"] = tokenExpiryAt;

      final json = await _http(
          method: "POST",
          url: _urlForRouteType(WPRouteType.UserLogin) +
              "" +
              _getAuthQueryForType(authType),
          body: payload);

      return _jsonHasBadStatus(json)
          ? null
          : WPUserLoginResponse.fromJson(json);
    } else {
      return null;
    }
  }

  Future<WPUserRegisterResponse> wpRegister(
      {@required String email,
      @required String password,
      @required String username,
      String expiry}) async {
    WPNonceResponse wpNonceResponse = await wpNonce();

    Map<String, dynamic> payload = {
      "email": email,
      "password": password,
      "username": username,
      "nonce": wpNonceResponse.data.nonce
    };
    if (expiry != null) payload["expiry"] = expiry;

    if (wpNonceResponse != null) {
      final json = await _http(
          method: "POST",
          url: _urlForRouteType(WPRouteType.UserRegister),
          body: payload);

      return _jsonHasBadStatus(json)
          ? null
          : WPUserRegisterResponse.fromJson(json);
    } else {
      return null;
    }
  }

  Future<WPNonceResponse> wpNonce() async {
    final json = await _http(
      method: "GET",
      url: _urlForRouteType(WPRouteType.AuthNonce),
    );

    return _jsonHasBadStatus(json) ? null : WPNonceResponse.fromJson(json);
  }

  Future<WPNonceVerifiedResponse> wpNonceVerify(
      {@required String nonce}) async {
    Map<String, dynamic> payload = {"nonce": nonce};

    final json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.AuthVerify),
        body: payload);

    return _jsonHasBadStatus(json)
        ? null
        : WPNonceVerifiedResponse.fromJson(json);
  }

  Future<WPUserInfoResponse> wpGetUserInfo(String userToken) async {
    final json = await _http(
        method: "GET",
        url: _urlForRouteType(WPRouteType.UserInfo),
        userToken: userToken);

    return _jsonHasBadStatus(json) ? null : WPUserInfoResponse.fromJson(json);
  }

  Future<WPUserInfoUpdatedResponse> wpUpdateUserInfo(userToken,
      {String firstName, String lastName, String displayName}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;

    final json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.UserUpdateInfo),
        userToken: userToken,
        body: payload);

    return _jsonHasBadStatus(json)
        ? null
        : WPUserInfoUpdatedResponse.fromJson(json);
  }

  Future<WPUserResetPasswordResponse> wpResetPassword(
    String userToken, {
    @required String password,
  }) async {
    Map<String, dynamic> payload = {"password": password};

    final json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.UserUpdatePassword),
        body: payload,
        userToken: userToken);

    return _jsonHasBadStatus(json)
        ? null
        : WPUserResetPasswordResponse.fromJson(json);
  }

  Future<WCCustomerInfoResponse> wcCustomerInfo(String userToken) async {
    final json = await _http(
        method: "GET",
        url: _urlForRouteType(WPRouteType.WCCustomerInfo),
        userToken: userToken);

    return _jsonHasBadStatus(json)
        ? null
        : WCCustomerInfoResponse.fromJson(json);
  }

  Future<WCCustomerUpdatedResponse> wcUpdateCustomerInfo(userToken,
      {String firstName,
      String lastName,
      String displayName,
      String billingFirstName,
      String billingLastName,
      String billingCompany,
      String billingAddress1,
      String billingAddress2,
      String billingCity,
      String billingState,
      String billingPostcode,
      String billingCountry,
      String billingEmail,
      String billingPhone,
      String shippingFirstName,
      String shippingLastName,
      String shippingCompany,
      String shippingAddress1,
      String shippingAddress2,
      String shippingCity,
      String shippingState,
      String shippingPostcode,
      String shippingCountry,
      String shippingEmail,
      String shippingPhone}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;

    Map<String, dynamic> shippingPayload = {};
    if (shippingFirstName != null)
      shippingPayload["first_name"] = shippingFirstName;
    if (shippingLastName != null)
      shippingPayload["last_name"] = shippingLastName;
    if (shippingCompany != null) shippingPayload["company"] = shippingCompany;
    if (shippingAddress1 != null)
      shippingPayload["address_1"] = shippingAddress1;
    if (shippingAddress2 != null)
      shippingPayload["address_2"] = shippingAddress2;
    if (shippingCity != null) shippingPayload["city"] = shippingCity;
    if (shippingState != null) shippingPayload["state"] = shippingState;
    if (shippingPostcode != null)
      shippingPayload["postcode"] = shippingPostcode;
    if (shippingCountry != null) shippingPayload["country"] = shippingCountry;
    if (shippingEmail != null) shippingPayload["email"] = shippingEmail;
    if (shippingPhone != null) shippingPayload["phone"] = shippingPhone;

    Map<String, dynamic> billingPayload = {};
    if (billingFirstName != null)
      billingPayload["first_name"] = billingFirstName;
    if (billingLastName != null) billingPayload["last_name"] = billingLastName;
    if (billingCompany != null) billingPayload["company"] = billingCompany;
    if (billingAddress1 != null) billingPayload["address_1"] = billingAddress1;
    if (billingAddress2 != null) billingPayload["address_2"] = billingAddress2;
    if (billingCity != null) billingPayload["city"] = billingCity;
    if (billingState != null) billingPayload["state"] = billingState;
    if (billingPostcode != null) billingPayload["postcode"] = billingPostcode;
    if (billingCountry != null) billingPayload["country"] = billingCountry;
    if (billingEmail != null) billingPayload["email"] = billingEmail;
    if (billingPhone != null) billingPayload["phone"] = billingPhone;

    if (shippingPayload.isNotEmpty) {
      payload["shipping"] = shippingPayload;
    }

    if (billingPayload.isNotEmpty) {
      payload["billing"] = billingPayload;
    }

    final json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.WCCustomerUpdateInfo),
        body: payload,
        userToken: userToken);

    return _jsonHasBadStatus(json)
        ? null
        : WCCustomerUpdatedResponse.fromJson(json);
  }

  dynamic _http(
      {@required String method,
      @required String url,
      dynamic body,
      String userToken}) async {
    var response;
    if (method == "GET") {
      response = await http.get(
        url,
        headers: (userToken == null ? null : _authHeader(userToken)),
      );
    } else if (method == "POST") {
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json",
      };
      if (userToken != null) {
        headers.addAll(_authHeader(userToken));
      }

      response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );
    }

    _devLogger(
        url: response.request.url.toString(),
        payload: method == "GET"
            ? response.request.url.queryParametersAll.toString()
            : body.toString(),
        result: response.body.toString());

    return jsonDecode(response.body);
  }

  _devLogger({@required String url, String payload, String result}) {
    String strOutput = "\nREQUEST: " + url;
    if (payload != null) strOutput += "\nPayload: " + payload;
    if (result != null) strOutput += "\nRESULT: " + result;

    if (WPJsonAPI.instance.shouldDebug()) log(strOutput);
  }

  Map<String, String> _authHeader(userToken) {
    return {HttpHeaders.authorizationHeader: "Bearer " + userToken};
  }

  _jsonHasBadStatus(json) {
    return (json["status"] == null || json["status"] >= 500);
  }

  String _urlForRouteType(WPRouteType wpRouteType) {
    return WPJsonAPI.instance.getBaseApi() + _getRouteUrlForType(wpRouteType);
  }

  String _getAuthQueryForType(WPAuthType authType) {
    switch (authType) {
      case WPAuthType.WpEmail:
        return "?auth=email";
      case WPAuthType.WpUsername:
        return "?auth=username";
      default:
        {
          return "";
        }
    }
  }

  String _getRouteUrlForType(
    WPRouteType wpRouteType, {
    String apiVersion = 'v1',
  }) {
    switch (wpRouteType) {
      // AUTH API
      case WPRouteType.AuthNonce:
        {
          return "/wpapp/auth/$apiVersion/nonce";
        }
      case WPRouteType.AuthVerify:
        {
          return "/wpapp/auth/$apiVersion/verify";
        }
      // WORDPRESS API
      case WPRouteType.UserLogin:
        {
          return "/wpapp/api/$apiVersion/user/login";
        }
      case WPRouteType.UserRegister:
        {
          return "/wpapp/api/$apiVersion/user/register";
        }
      case WPRouteType.UserInfo:
        {
          return "/wpapp/api/$apiVersion/user/info";
        }
      case WPRouteType.UserUpdateInfo:
        {
          return "/wpapp/api/$apiVersion/update/user/info";
        }
      case WPRouteType.UserUpdatePassword:
        {
          return "/wpapp/api/$apiVersion/update/user/password";
        }

      // WOOCOMMERCE API
      case WPRouteType.WCCustomerInfo:
        {
          return "/wpapp/wc/$apiVersion/user/info";
        }
      case WPRouteType.WCCustomerUpdateInfo:
        {
          return "/wpapp/wc/$apiVersion/update/user/info";
        }
      default:
        {
          return "";
        }
    }
  }
}
