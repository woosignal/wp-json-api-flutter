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

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import '/enums/wp_route_type.dart';
import '/exceptions/incorrect_password_exception.dart';
import '/exceptions/invalid_credentials_exception.dart';
import '/exceptions/invalid_email_exception.dart';
import '/exceptions/invalid_params_exception.dart';
import '/exceptions/invalid_user_token_exception.dart';
import '/exceptions/login_blocked_exception.dart';
import '/exceptions/meta_key_not_allowed_exception.dart';
import '/exceptions/points_and_rewards_not_found_exception.dart';
import '/exceptions/privileged_user_exception.dart';
import '/exceptions/registration_disabled_exception.dart';
import '/exceptions/too_many_attempts_exception.dart';
import '/exceptions/user_already_exist_exception.dart';
import '/exceptions/username_taken_exception.dart';
import '/exceptions/weak_password_exception.dart';
import '/exceptions/woocommerce_not_found_exception.dart';
import '/exceptions/wp_network_exception.dart';
import '/exceptions/wp_server_exception.dart';
import '/models/responses/wc_customer_info_response.dart';
import '/models/responses/wc_customer_updated_response.dart';
import '/models/responses/wc_points_and_rewards_calculate_points.dart';
import '/models/responses/wc_points_and_rewards_user.dart';
import '/models/responses/wp_user_delete_response.dart';
import '/models/responses/wp_user_info_response.dart';
import '/models/responses/wp_user_info_updated_response.dart';
import '/models/responses/wp_user_login_response.dart';
import '/models/responses/wp_user_register_response.dart';
import '/models/responses/wp_user_reset_password_response.dart';
import '/models/wp_meta_meta.dart';
import '/models/wp_user.dart';
import '/wp_json_api.dart';

/// A networking class to manage all the APIs from "wp_json_api".
///
/// Requests are sent to the WP JSON API `wpapp/v4` namespace. Authenticated
/// requests send the user's token in the `Authorization: Bearer` and
/// `X-WPApp-Token` headers, never in the request body.
///
/// Every request throws a typed exception when the server returns an error,
/// e.g. [InvalidUserTokenException] for `wpapp_unauthorized`. Errors without
/// a dedicated exception throw a [WPServerException], and requests that fail
/// without a response (no connection, timeout) throw a [WPNetworkException].
class WPAppNetworkManager {
  WPAppNetworkManager._privateConstructor();

  Dio dio = Dio();

  /// An instance of [WPAppNetworkManager] class
  static final WPAppNetworkManager instance =
      WPAppNetworkManager._privateConstructor();

  /// The WP JSON API namespace used for all requests.
  static const String apiNamespace = "/wpapp/v4";

  /// The header that carries the token for hosts that strip `Authorization`.
  static const String tokenHeader = "X-WPApp-Token";

  /// Sends a request to login a user.
  ///
  /// Pass the user's username or email as [login]. For convenience you can
  /// pass [email] or [username] instead; the server accepts either in the same
  /// field. If more than one is set, [login] is used first, then [email], then
  /// [username].
  ///
  /// [expiresIn] optionally asks for a shorter token lifetime in seconds (the
  /// site maximum still applies). [deviceName] is shown to admins when they
  /// list tokens. When [saveTokenToLocalStorage] is true the user and token are
  /// stored on the device.
  ///
  /// Returns a [WPUserLoginResponse] future.
  /// Throws an [InvalidCredentialsException] if the login details are wrong,
  /// [LoginBlockedException] if another plugin (e.g. two-factor) stopped the
  /// login, [PrivilegedUserException] if the account may not use the API,
  /// [TooManyAttemptsException] if rate limited,
  /// [InvalidParamsException] if a parameter is missing or invalid.
  Future<WPUserLoginResponse> wpLogin(
      {String? login,
      String? email,
      String? username,
      required String password,
      int? expiresIn,
      String? deviceName,
      bool saveTokenToLocalStorage = true}) async {
    // Creates payload for login
    Map<String, dynamic> payload = {
      "login": login ?? email ?? username,
      "password": password,
    };
    if (expiresIn != null) payload["expires_in"] = expiresIn;
    if (deviceName != null) payload["device_name"] = deviceName;

    // send http request
    final Map<String, dynamic> json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserLogin),
      body: payload,
    );

    WPUserLoginResponse wpUserLoginResponse =
        WPUserLoginResponse.fromJson(json);
    String? userToken = wpUserLoginResponse.data?.token;

    if (userToken != null && saveTokenToLocalStorage) {
      WpUser wpUser = WpUser.fromWPUserLoginResponse(wpUserLoginResponse);
      await WPJsonAPI.wpLogin(wpUser);
    }
    return wpUserLoginResponse;
  }

  /// Sends a request to register a user in WordPress with an [email] and
  /// [password].
  ///
  /// [username] is optional; the server generates one from the email when it
  /// is empty. [firstName] and [lastName] are optional. [metaData] is an
  /// optional map of user meta (`{"billing_phone": "..."}`); only keys on the
  /// site's allow-list are accepted. [expiresIn] and [deviceName] work as in
  /// [wpLogin].
  ///
  /// Returns a [WPUserRegisterResponse] future.
  /// Throws an [UsernameTakenException] if the username is taken,
  /// [UserAlreadyExistException] if the email is in use,
  /// [InvalidEmailException] if the email is not valid,
  /// [WeakPasswordException] if the password is too short,
  /// [RegistrationDisabledException] if registration is turned off,
  /// [MetaKeyNotAllowedException] if a [metaData] key is not allowed,
  /// [TooManyAttemptsException] if rate limited.
  Future<WPUserRegisterResponse> wpRegister(
      {required String email,
      required String password,
      String? username,
      String? firstName,
      String? lastName,
      Map<String, dynamic>? metaData,
      int? expiresIn,
      String? deviceName,
      bool saveTokenToLocalStorage = true}) async {
    return await _register(
      wcRegister: false,
      email: email,
      password: password,
      username: username,
      firstName: firstName,
      lastName: lastName,
      metaData: metaData,
      expiresIn: expiresIn,
      deviceName: deviceName,
      saveTokenToLocalStorage: saveTokenToLocalStorage,
    );
  }

  /// Sends a request to register a user as a WooCommerce customer. Takes the
  /// same parameters as [wpRegister].
  ///
  /// Returns a [WPUserRegisterResponse] future.
  /// Throws the same exceptions as [wpRegister], and
  /// [WooCommerceNotFoundException] if WooCommerce is not active.
  Future<WPUserRegisterResponse> wcRegister(
      {required String email,
      required String password,
      String? username,
      String? firstName,
      String? lastName,
      Map<String, dynamic>? metaData,
      int? expiresIn,
      String? deviceName,
      bool saveTokenToLocalStorage = true}) async {
    return await _register(
      wcRegister: true,
      email: email,
      password: password,
      username: username,
      firstName: firstName,
      lastName: lastName,
      metaData: metaData,
      expiresIn: expiresIn,
      deviceName: deviceName,
      saveTokenToLocalStorage: saveTokenToLocalStorage,
    );
  }

  /// Sends the register request for [wpRegister] and [wcRegister].
  Future<WPUserRegisterResponse> _register(
      {required bool wcRegister,
      required String email,
      required String password,
      String? username,
      String? firstName,
      String? lastName,
      Map<String, dynamic>? metaData,
      int? expiresIn,
      String? deviceName,
      bool saveTokenToLocalStorage = true}) async {
    // Creates payload for register
    Map<String, dynamic> payload = {
      "email": email,
      "password": password,
      "wc_register": wcRegister,
    };
    if (username != null && username.isNotEmpty) {
      payload["username"] = username;
    }
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (metaData != null && metaData.isNotEmpty) {
      payload["meta_data"] = metaData;
    }
    if (expiresIn != null) payload["expires_in"] = expiresIn;
    if (deviceName != null) payload["device_name"] = deviceName;

    // send http request
    final Map<String, dynamic> json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserRegister),
      body: payload,
    );

    WPUserRegisterResponse wpUserRegisterResponse =
        WPUserRegisterResponse.fromJson(json);
    String? userToken = wpUserRegisterResponse.data?.token;

    if (userToken != null && saveTokenToLocalStorage) {
      WpUser wpUser = WpUser.fromWPUserRegisterResponse(wpUserRegisterResponse);
      await WPJsonAPI.wpLogin(wpUser);
    }
    return wpUserRegisterResponse;
  }

  /// Logs out the user. Sends a request to revoke the token on the server,
  /// then removes the user and token from the device.
  ///
  /// The local session is always cleared, even if the request fails (e.g. the
  /// token has already expired or there is no connection).
  ///
  /// Returns true if the server revoked the token, false otherwise.
  Future<bool> wpLogout({String? userToken}) async {
    bool revoked = false;
    try {
      String? token = userToken ?? await WPJsonAPI.wpUserToken();
      if (token != null && token.isNotEmpty) {
        await _http(
          method: "POST",
          url: _urlForRouteType(WPRouteType.UserLogout),
          userToken: token,
          shouldAuthRequest: true,
        );
        revoked = true;
      }
    } on Exception catch (e) {
      _devLogger(
          url: _urlForRouteType(WPRouteType.UserLogout),
          result: "Logout request failed, clearing the local session: $e");
    } finally {
      await WPJsonAPI.wpLogout();
    }
    return revoked;
  }

  /// Sends a request to get the user's WordPress info.
  ///
  /// Returns a [WPUserInfoResponse] future.
  /// Throws an [InvalidUserTokenException] if the token is not valid.
  Future<WPUserInfoResponse> wpGetUserInfo({String? userToken}) async {
    // send http request
    final Map<String, dynamic> json = await _http(
        method: "GET",
        url: _urlForRouteType(WPRouteType.UserInfo),
        userToken: userToken,
        shouldAuthRequest: true);

    return WPUserInfoResponse.fromJson(json);
  }

  /// Sends a request to update details for a WordPress user. Optional
  /// parameters include a [firstName], [lastName], [displayName] or
  /// [metaData] to update.
  ///
  /// Every [metaData] key is checked before anything is saved; one key that
  /// is not on the site's allow-list fails the whole request.
  ///
  /// Returns a [WPUserInfoUpdatedResponse] future with the updated user.
  /// Throws an [InvalidUserTokenException] if the token is not valid,
  /// [MetaKeyNotAllowedException] if a [metaData] key is not allowed.
  Future<WPUserInfoUpdatedResponse> wpUpdateUserInfo(
      {String? userToken,
      String? firstName,
      String? lastName,
      String? displayName,
      List<WpMetaData>? metaData}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;
    if (metaData != null) {
      payload['meta_data'] = metaData.map((e) => e.toJson()).toList();
    }

    // send http request
    final Map<String, dynamic> json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserUpdateInfo),
      userToken: userToken,
      shouldAuthRequest: true,
      body: payload,
    );

    return WPUserInfoUpdatedResponse.fromJson(json);
  }

  /// Sends a request to delete the user's WordPress account. The user's
  /// current [password] is required.
  ///
  /// On success the account and all its tokens are deleted, and the stored
  /// session is removed from the device (unless [userToken] belongs to a
  /// different user than the stored one).
  ///
  /// Returns a [WPUserDeleteResponse] future.
  /// Throws an [IncorrectPasswordException] if the [password] is wrong,
  /// [InvalidUserTokenException] if the token is not valid.
  Future<WPUserDeleteResponse> wpUserDelete(
      {required String password, String? userToken}) async {
    // send http request
    final Map<String, dynamic> json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserDelete),
      userToken: userToken,
      shouldAuthRequest: true,
      body: {"password": password},
    );

    String? storedToken = await WPJsonAPI.wpUserToken();
    if (userToken == null || userToken == storedToken) {
      await WPJsonAPI.wpLogout();
    }
    return WPUserDeleteResponse.fromJson(json);
  }

  /// Changes the user's password. [currentPassword] is the user's current
  /// password and [password] is the new one.
  ///
  /// All of the user's other tokens are revoked; the token used for this
  /// request stays valid.
  ///
  /// Returns a [WPUserResetPasswordResponse] future.
  /// Throws an [IncorrectPasswordException] if [currentPassword] is wrong,
  /// [WeakPasswordException] if the new [password] is too short,
  /// [InvalidUserTokenException] if the token is not valid.
  Future<WPUserResetPasswordResponse> wpResetPassword({
    required String currentPassword,
    required String password,
    String? userToken,
  }) async {
    Map<String, dynamic> payload = {
      "current_password": currentPassword,
      "password": password,
    };

    // send http request
    final Map<String, dynamic> json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.UserUpdatePassword),
        body: payload,
        userToken: userToken,
        shouldAuthRequest: true);

    return WPUserResetPasswordResponse.fromJson(json);
  }

  /// Get the user's WooCommerce customer information.
  ///
  /// Returns a [WCCustomerInfoResponse] future.
  /// Throws a [WooCommerceNotFoundException] if WooCommerce is not active,
  /// [InvalidUserTokenException] if the token is not valid.
  Future<WCCustomerInfoResponse> wcCustomerInfo({String? userToken}) async {
    // send http request
    final Map<String, dynamic> json = await _http(
        method: "GET",
        url: _urlForRouteType(WPRouteType.WCCustomerInfo),
        userToken: userToken,
        shouldAuthRequest: true);

    return WCCustomerInfoResponse.fromJson(json);
  }

  /// Get the user's points from WooCommerce Points and Rewards.
  ///
  /// Returns a [WcPointsAndRewardUser] future.
  /// Throws a [PointsAndRewardsNotFoundException] if WooCommerce Points and
  /// Rewards is not active, [InvalidUserTokenException] if the token is not
  /// valid.
  Future<WcPointsAndRewardUser> wcPointsAndRewardsUser(
      {String? userToken}) async {
    // send http request
    final Map<String, dynamic> json = await _http(
      method: "GET",
      url: _urlForRouteType(WPRouteType.WCPointsAndRewardsUser),
      userToken: userToken,
      shouldAuthRequest: true,
    );

    return WcPointsAndRewardUser.fromJson(_dataFromJson(json));
  }

  /// Calculate the value of [points] (0 or more) with WooCommerce Points and
  /// Rewards.
  ///
  /// Returns a [WcPointsAndRewardCalculatePoints] future.
  /// Throws a [PointsAndRewardsNotFoundException] if WooCommerce Points and
  /// Rewards is not active, [InvalidUserTokenException] if the token is not
  /// valid.
  Future<WcPointsAndRewardCalculatePoints> wcPointsAndRewardsCalculatePoints(
      {required double points, String? userToken}) async {
    // send http request
    final Map<String, dynamic> json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.WCPointsAndRewardsCalculatePoints),
      userToken: userToken,
      shouldAuthRequest: true,
      body: {"points": points},
    );

    return WcPointsAndRewardCalculatePoints.fromJson(_dataFromJson(json));
  }

  /// Sends a request to update the user's WooCommerce customer details. All
  /// parameters are optional; only the ones you set are sent.
  ///
  /// Returns a [WCCustomerUpdatedResponse] future with the updated customer.
  /// Throws a [WooCommerceNotFoundException] if WooCommerce is not active,
  /// [InvalidUserTokenException] if the token is not valid.
  Future<WCCustomerUpdatedResponse> wcUpdateCustomerInfo(
      {String? userToken,
      String? firstName,
      String? lastName,
      String? displayName,
      String? billingFirstName,
      String? billingLastName,
      String? billingCompany,
      String? billingAddress1,
      String? billingAddress2,
      String? billingCity,
      String? billingState,
      String? billingPostcode,
      String? billingCountry,
      String? billingEmail,
      String? billingPhone,
      String? shippingFirstName,
      String? shippingLastName,
      String? shippingCompany,
      String? shippingAddress1,
      String? shippingAddress2,
      String? shippingCity,
      String? shippingState,
      String? shippingPostcode,
      String? shippingCountry,
      String? shippingPhone}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;

    Map<String, dynamic> shippingPayload = {};
    if (shippingFirstName != null) {
      shippingPayload["first_name"] = shippingFirstName;
    }
    if (shippingLastName != null) {
      shippingPayload["last_name"] = shippingLastName;
    }
    if (shippingCompany != null) shippingPayload["company"] = shippingCompany;
    if (shippingAddress1 != null) {
      shippingPayload["address_1"] = shippingAddress1;
    }
    if (shippingAddress2 != null) {
      shippingPayload["address_2"] = shippingAddress2;
    }
    if (shippingCity != null) shippingPayload["city"] = shippingCity;
    if (shippingState != null) shippingPayload["state"] = shippingState;
    if (shippingPostcode != null) {
      shippingPayload["postcode"] = shippingPostcode;
    }
    if (shippingCountry != null) shippingPayload["country"] = shippingCountry;
    if (shippingPhone != null) shippingPayload["phone"] = shippingPhone;

    Map<String, dynamic> billingPayload = {};
    if (billingFirstName != null) {
      billingPayload["first_name"] = billingFirstName;
    }
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

    // send http request
    final Map<String, dynamic> json = await _http(
        method: "POST",
        url: _urlForRouteType(WPRouteType.WCCustomerUpdateInfo),
        body: payload,
        userToken: userToken,
        shouldAuthRequest: true);

    return WCCustomerUpdatedResponse.fromJson(json);
  }

  /// Sends a Http request using a valid request [method] and [url] endpoint
  /// from the WP JSON API plugin. The [body] is optional and only sent for
  /// POST requests.
  ///
  /// When [shouldAuthRequest] is true, the [userToken] (or the stored user's
  /// token) is sent in the `Authorization` and `X-WPApp-Token` headers.
  ///
  /// Returns the decoded JSON body of a 2xx response.
  /// Throws a typed exception for an error response, see
  /// [_exceptionForError], or a [WPNetworkException] if there is no response.
  Future<Map<String, dynamic>> _http(
      {required String method,
      required String url,
      Map<String, dynamic>? body,
      String? userToken,
      bool shouldAuthRequest = false}) async {
    Map<String, String> headers = {
      HttpHeaders.acceptHeader: "application/json",
    };
    if (method == "POST") {
      headers[HttpHeaders.contentTypeHeader] = "application/json";
    }
    if (shouldAuthRequest) {
      String? token = userToken ?? await WPJsonAPI.wpUserToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = "Bearer $token";
        headers[tokenHeader] = token;
      }
    }

    // Accept every status so error bodies are handled in one place below.
    Options options = Options(headers: headers, validateStatus: (_) => true);

    Response? response;
    try {
      if (method == "GET") {
        response = await dio.get(url, options: options);
      } else {
        response = await dio.post(url,
            data: body ?? <String, dynamic>{}, options: options);
      }
    } on DioException catch (e) {
      if (e.response == null) {
        _devLogger(url: url, payload: _redact(body).toString(), result: "$e");
        throw WPNetworkException(
          e.message ?? 'Unable to connect to the server',
          error: e,
        );
      }
      response = e.response;
    }

    // log output
    _devLogger(
        url: response!.requestOptions.uri.toString(),
        payload: _redact(body).toString(),
        result: "${response.statusCode} ${_redact(response.data)}");

    int? statusCode = response.statusCode;
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw _exceptionForResponse(response);
    }

    final dynamic data = response.data;
    if (data is! Map) {
      throw WPServerException(
        'Unexpected response from the server',
        status: statusCode,
      );
    }
    return Map<String, dynamic>.from(data);
  }

  /// Logs the output of a app request.
  /// [url] should be set containing the url route for the request.
  /// The [payload] and [result] are optional but are used in the
  /// log output if set. This will only log if shouldDebug is enabled.
  ///
  /// Returns void.
  void _devLogger({required String url, String? payload, String? result}) {
    String strOutput = "\nREQUEST: $url";
    if (payload != null) strOutput += "\nPayload: $payload";
    if (result != null) strOutput += "\nRESULT: $result";

    // logs response if shouldDebug is enabled
    if (WPJsonAPI.instance.shouldDebug() ?? false) log(strOutput);
  }

  /// Hides passwords and tokens in [value] before it is logged.
  dynamic _redact(dynamic value) {
    const Set<String> secretKeys = {"password", "current_password", "token"};
    if (value is Map) {
      return value.map((key, item) =>
          MapEntry(key, secretKeys.contains(key) ? "[hidden]" : _redact(item)));
    }
    if (value is List) {
      return value.map(_redact).toList();
    }
    return value;
  }

  /// Returns the `data` object from a success response [json].
  Map<String, dynamic> _dataFromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    if (data is! Map) {
      throw WPServerException(
        'Unexpected response from the server',
        status: json['status'] is int ? json['status'] : null,
      );
    }
    return Map<String, dynamic>.from(data);
  }

  /// Creates an endpoint with the baseUrl and path.
  ///
  /// Returns [String] of the url route.
  String _urlForRouteType(WPRouteType wpRouteType) {
    return '${WPJsonAPI.instance.getBaseApi()}$apiNamespace${_getRouteUrlForType(wpRouteType)}';
  }

  /// The routes available for the WP JSON API plugin (`wpapp/v4`).
  ///
  /// Returns [String] url path for request.
  String _getRouteUrlForType(WPRouteType wpRouteType) {
    switch (wpRouteType) {
      // AUTH
      case WPRouteType.UserLogin:
        return "/auth/login";
      case WPRouteType.UserRegister:
        return "/auth/register";
      case WPRouteType.UserLogout:
        return "/auth/logout";

      // WORDPRESS
      case WPRouteType.UserInfo:
      case WPRouteType.UserUpdateInfo:
        return "/user";
      case WPRouteType.UserUpdatePassword:
        return "/user/password";
      case WPRouteType.UserDelete:
        return "/user/delete";

      // WOOCOMMERCE
      case WPRouteType.WCCustomerInfo:
      case WPRouteType.WCCustomerUpdateInfo:
        return "/wc/customer";
      case WPRouteType.WCPointsAndRewardsUser:
        return "/wc/points";
      case WPRouteType.WCPointsAndRewardsCalculatePoints:
        return "/wc/points/calculate";
    }
  }

  /// Reads the WordPress REST error body (`{code, message, data}`) from an
  /// error [response] and returns the matching exception.
  Exception _exceptionForResponse(Response response) {
    String? code;
    String? message;
    Map<String, dynamic>? data;

    final dynamic body = response.data;
    if (body is Map) {
      if (body['code'] != null) code = body['code'].toString();
      if (body['message'] is String && (body['message'] as String).isNotEmpty) {
        message = body['message'];
      }
      if (body['data'] is Map) {
        data = Map<String, dynamic>.from(body['data']);
      }
    }

    int? retryAfter = _parseInt(data?['retry_after']) ??
        _parseInt(response.headers.value('retry-after'));

    return _exceptionForError(
      code: code,
      message: message,
      status: response.statusCode,
      data: data,
      retryAfter: retryAfter,
    );
  }

  /// Maps a WP JSON API error [code] to an exception.
  ///
  /// Codes without a dedicated exception return a [WPServerException]
  /// carrying the [code], [message], [status] and [data].
  Exception _exceptionForError(
      {String? code,
      String? message,
      int? status,
      Map<String, dynamic>? data,
      int? retryAfter}) {
    switch (code) {
      case 'wpapp_unauthorized':
        return InvalidUserTokenException(message);
      case 'wpapp_privileged_user':
        return PrivilegedUserException(message);
      case 'wpapp_invalid_credentials':
        return InvalidCredentialsException(message);
      case 'wpapp_login_blocked':
        return LoginBlockedException(
            message ?? 'The login was blocked, please try again later');
      case 'wpapp_too_many_attempts':
        return TooManyAttemptsException(message, retryAfter);
      case 'wpapp_registration_disabled':
        return RegistrationDisabledException(message);
      case 'wpapp_username_taken':
        return UsernameTakenException(message);
      case 'wpapp_email_exists':
        return UserAlreadyExistException(message);
      case 'wpapp_invalid_email':
        return InvalidEmailException(message ?? 'The email is not valid');
      case 'wpapp_weak_password':
        return WeakPasswordException(message);
      case 'wpapp_meta_key_not_allowed':
        return MetaKeyNotAllowedException(message, data?['key']?.toString());
      case 'wpapp_incorrect_password':
        return IncorrectPasswordException(
            message ?? 'The password is incorrect');
      case 'wpapp_woocommerce_missing':
        return WooCommerceNotFoundException(message);
      case 'wpapp_points_rewards_missing':
        return PointsAndRewardsNotFoundException(message);
      case 'wpapp_invalid_params':
      case 'rest_missing_callback_param':
      case 'rest_invalid_param':
        return InvalidParamsException(message);
      default:
        return WPServerException(
          message ?? 'Something went wrong, please check the server response',
          code: code,
          status: status,
          data: data,
        );
    }
  }

  /// Parses an int from a number or numeric string [value].
  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
