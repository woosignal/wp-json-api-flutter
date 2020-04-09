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
import 'package:wp_json_api/models/responses/WPUserLoginResponse.dart';
import 'package:wp_json_api/models/responses/WPUserRegisterResponse.dart';
import 'package:wp_json_api/models/responses/WPUserResetPasswordResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:wp_json_api/enums/WPRouteType.dart';
import 'package:wp_json_api/models/responses/WPUserInfoResponse.dart';
import 'package:http/http.dart' as http;

class WPAppNetworkManager {
  WPAppNetworkManager._privateConstructor();

  static final WPAppNetworkManager instance = WPAppNetworkManager._privateConstructor();

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

      String url = _urlForRouteType(WPRouteType.UserLogin) + "" + _getAuthQueryForType(authType);

      final response = await http.post(Uri.parse(url),
          body: jsonEncode(payload),
      headers: {HttpHeaders.contentTypeHeader: "application/json"});

      final json = jsonDecode(response.body);

      _devLogger(
          url: response.request.url.toString(),
          payload: payload.toString(),
          result: json.toString());

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

    String url = _urlForRouteType(WPRouteType.UserRegister);

    if (wpNonceResponse != null) {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
        headers: {HttpHeaders.contentTypeHeader: "application/json"}
      );

      final json = jsonDecode(response.body);

      _devLogger(
        url: response.request.url.toString(),
        payload: payload.toString(),
        result: json.toString(),
      );

      return _jsonHasBadStatus(json)
          ? null
          : WPUserRegisterResponse.fromJson(json);
    } else {
      return null;
    }
  }

  Future<WPNonceResponse> wpNonce() async {
    String url = _urlForRouteType(WPRouteType.AuthNonce);

    final response = await http.get(
      Uri.parse(url),
    );

    final json = jsonDecode(response.body);

    _devLogger(
        url: response.request.url.toString(),
        payload: response.request.url.queryParametersAll.toString(),
        result: json.toString());

    return _jsonHasBadStatus(json) ? null : WPNonceResponse.fromJson(json);
  }

  Future<WPNonceVerifiedResponse> wpNonceVerify(
      {@required String nonce}) async {
    Map<String, dynamic> payload = {"nonce": nonce};

    final response = await http.post(_urlForRouteType(WPRouteType.AuthVerify),
        body: payload,);

    final json = jsonDecode(response.body);

    _devLogger(
        url: response.request.url.toString(),
        payload: payload.toString(),
        result: json.toString());

    return _jsonHasBadStatus(json)
        ? null
        : WPNonceVerifiedResponse.fromJson(json);
  }

  Future<WPUserInfoResponse> wpGetUserInfo(String userToken) async {
    final response = await http.get(
      _urlForRouteType(WPRouteType.UserInfo),
      headers: _authHeader(userToken),
    );

    final json = jsonDecode(response.body);

    _devLogger(url: response.request.url.toString(), result: json.toString());

    return _jsonHasBadStatus(json) ? null : WPUserInfoResponse.fromJson(json);
  }

  Future<WPUserInfoResponse> wpUpdateUserInfo(userToken,
      {String firstName, String lastName, String displayName}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };
    headers.addAll(_authHeader(userToken));

    final response = await http.post(
      _urlForRouteType(WPRouteType.UserUpdateInfo),
      body: payload,
      headers: headers,
    );

    final json = jsonDecode(response.body);

    _devLogger(
        url: response.request.url.toString(),
        payload: payload.toString(),
        result: json.toString());

    return _jsonHasBadStatus(json) ? null : WPUserInfoResponse.fromJson(json);
  }

  Future<WPUserResetPasswordResponse> wpResetPassword(
    String userToken, {
    @required String password,
  }) async {
    Map<String, dynamic> payload = {"password": password};

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };
    headers.addAll(_authHeader(userToken));

    final response = await http.post(
      _urlForRouteType(WPRouteType.UserUpdatePassword),
      body: payload,
      headers: headers,
    );

    final json = jsonDecode(response.body);

    _devLogger(
        url: response.request.url.toString(),
        payload: payload.toString(),
        result: json.toString());

    return _jsonHasBadStatus(json)
        ? null
        : WPUserResetPasswordResponse.fromJson(json);
  }

  Future<WCCustomerInfoResponse> wcCustomerInfo(String userToken) async {
    final response = await http.get(
      _urlForRouteType(WPRouteType.WCCustomerInfo),
      headers: _authHeader(userToken),
    );

    final json = jsonDecode(response.body);

    _devLogger(url: response.request.url.toString(), result: json.toString());

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

    if (shippingFirstName != null)
      payload["shipping"]["first_name"] = shippingFirstName;
    if (shippingLastName != null)
      payload["shipping"]["last_name"] = shippingLastName;
    if (shippingCompany != null)
      payload["shipping"]["company"] = shippingCompany;
    if (shippingAddress1 != null)
      payload["shipping"]["address_1"] = shippingAddress1;
    if (shippingAddress2 != null)
      payload["shipping"]["address_2"] = shippingAddress2;
    if (shippingCity != null) payload["shipping"]["city"] = shippingCity;
    if (shippingState != null) payload["shipping"]["state"] = shippingState;
    if (shippingPostcode != null)
      payload["shipping"]["postcode"] = shippingPostcode;
    if (shippingCountry != null)
      payload["shipping"]["country"] = shippingCountry;
    if (shippingEmail != null) payload["shipping"]["email"] = shippingEmail;
    if (shippingPhone != null) payload["shipping"]["phone"] = shippingPhone;

    if (billingFirstName != null)
      payload["billing"]["first_name"] = billingFirstName;
    if (billingLastName != null)
      payload["billing"]["last_name"] = billingLastName;
    if (billingCompany != null) payload["billing"]["company"] = billingCompany;
    if (billingAddress1 != null)
      payload["billing"]["address_1"] = billingAddress1;
    if (billingAddress2 != null)
      payload["billing"]["address_2"] = billingAddress2;
    if (billingCity != null) payload["billing"]["city"] = billingCity;
    if (billingState != null) payload["billing"]["state"] = billingState;
    if (billingPostcode != null)
      payload["billing"]["postcode"] = billingPostcode;
    if (billingCountry != null) payload["billing"]["country"] = billingCountry;
    if (billingEmail != null) payload["billing"]["email"] = billingEmail;
    if (billingPhone != null) payload["billing"]["phone"] = billingPhone;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };
    headers.addAll(_authHeader(userToken));

    final response = await http.post(
      _urlForRouteType(WPRouteType.WCCustomerUpdateInfo),
      body: payload,
      headers: headers,
    );
    final json = jsonDecode(response.body);

    _devLogger(
        url: response.request.url.toString(),
        payload: payload.toString(),
        result: json.toString());

    return _jsonHasBadStatus(json)
        ? null
        : WCCustomerUpdatedResponse.fromJson(json);
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
      default: {
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
          return "/wpapp/api/$apiVersion/user/info";
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
