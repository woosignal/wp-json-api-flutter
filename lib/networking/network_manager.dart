// Copyright (c) 2021, WooSignal Ltd.
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

import 'package:wp_json_api/enums/wp_auth_type.dart';
import 'package:wp_json_api/exceptions/empty_username_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_email_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_login_exception.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/invalid_params_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/exceptions/woocommerce_not_found_exception.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/models/responses/wp_nonce_response.dart';
import 'package:wp_json_api/models/responses/wp_nonce_verified_response.dart';
import 'package:wp_json_api/models/responses/wp_user_add_role_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/models/responses/wp_user_remove_role_response.dart';
import 'package:wp_json_api/models/responses/wp_user_reset_password_response.dart';
import 'package:wp_json_api/models/wp_meta_meta.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:wp_json_api/enums/wp_route_type.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:http/http.dart' as http;

/// A networking class to manage all the APIs from "wp_json_api"
class WPAppNetworkManager {
  WPAppNetworkManager._privateConstructor();

  /// An instance of [WPAppNetworkManager] class
  static final WPAppNetworkManager instance =
      WPAppNetworkManager._privateConstructor();

  /// Sends a request to login a user with the [email] & [password]
  /// or [username] and [password]. Set [authType] to auth with email/username.
  ///
  /// Returns a [WPUserLoginResponse] future.
  /// Throws an [InvalidNonceException] if nonce token is not valid
  /// [InvalidEmailException] if the email is not valid
  /// [IncorrectPasswordException] if the password is not valid
  /// [InvalidUsernameException] if the username is not valid
  /// [Exception] for any other reason.
  Future<WPUserLoginResponse> wpLogin(
      {String? email,
      String? username,
      required String password,
      WPAuthType authType = WPAuthType.WpEmail,
      String? tokenExpiryAt}) async {

    // Get nonce from WordPress
    WPNonceResponse wpNonceResponse = await wpNonce();

    // throw exception if there's an error
    if (!(wpNonceResponse is WPNonceResponse)) {
      throw new InvalidNonceException();
    }

    // Creates payload for login
    Map<String, dynamic> payload = {};
    if (username != null) payload["username"] = username;
    if (email != null) payload["email"] = email;
    payload["password"] = password;
    payload["nonce"] = wpNonceResponse.data!.nonce;
    if (tokenExpiryAt != null) payload["expiry"] = tokenExpiryAt;

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserLogin) +
          _getAuthQueryForType(authType),
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserLoginResponse.fromJson(json);
  }

  /// Sends a request to register a user in WordPress with the following
  /// parameters [username], [email] and [password].
  /// You can optionally set an [expiry] for the token expiry like "+1 day".
  ///
  /// Returns a [WPUserRegisterResponse] future.
  /// Throws an [UsernameTakenException] if username is taken
  /// [InvalidNonceException] if nonce token is not valid
  /// [ExistingUserLoginException] if user login exists
  /// [ExistingUserEmailException] if that email is in use
  /// [UserAlreadyExistException] if a user was found with the same email
  /// [EmptyUsernameException] if the username field has empty
  /// [Exception] if fails.
  Future<WPUserRegisterResponse> wpRegister(
      {required String email,
      required String password,
      required String username,
      String? expiry}) async {
    // Get nonce from WordPress
    WPNonceResponse wpNonceResponse = await wpNonce();

    // throw exception if nonce null
    if (!(wpNonceResponse is WPNonceResponse)) {
      throw InvalidNonceException();
    }

    // Creates payload for register
    Map<String, dynamic> payload = {
      "email": email,
      "password": password,
      "username": username,
      "nonce": wpNonceResponse.data!.nonce
    };
    if (expiry != null) payload["expiry"] = expiry;

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserRegister),
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserRegisterResponse.fromJson(json);
  }

  /// Makes a request to get a valid nonce code
  ///
  /// Returns a [WPNonceResponse] future.
  /// Throws an [Exception] if fails.
  Future<WPNonceResponse> wpNonce() async {
    // send http request
    final json = await _http(
      method: "GET",
      url: _urlForRouteType(WPRouteType.AuthNonce),
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPNonceResponse.fromJson(json);
  }

  /// Sends a request to check if a given [nonce] value is still valid.
  ///
  /// Returns a [WPNonceVerifiedResponse] future.
  /// Throws an [Exception] if fails
  Future<WPNonceVerifiedResponse> wpNonceVerify(
      {required String nonce}) async {
    Map<String, dynamic> payload = {"nonce": nonce};

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.AuthVerify),
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPNonceVerifiedResponse.fromJson(json);
  }

  /// Sends a request to get a users WordPress info using a valid [userToken].
  ///
  ///
  /// Returns a [WPUserInfoResponse] future.
  /// Throws an [Exception] if fails
  Future<WPUserInfoResponse> wpGetUserInfo(String userToken) async {
    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserInfo),
      userToken: userToken,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserInfoResponse.fromJson(json);
  }

  /// Sends a request to update details for a WordPress user. Include a valid
  /// [userToken] to send a successful request. Optional parameters include
  /// a [firstName], [lastName], [displayName] and [UserMetaDataItem] to update
  /// meta data on the user.
  ///
  /// Returns a [WPUserInfoUpdatedResponse] future.
  /// Throws an [Exception] if fails.
  Future<WPUserInfoUpdatedResponse> wpUpdateUserInfo(userToken,
      {String? firstName, String? lastName, String? displayName, List<UserMetaDataItem>? wpUserMetaData}) async {
    Map<String, dynamic> payload = {};
    if (firstName != null) payload["first_name"] = firstName;
    if (lastName != null) payload["last_name"] = lastName;
    if (displayName != null) payload["display_name"] = displayName;
    if (wpUserMetaData != null) {
      payload['meta_data'] = {
        "items": wpUserMetaData.map((e) => e.toJson()).toList()
      };
    }

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserUpdateInfo),
      userToken: userToken,
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserInfoUpdatedResponse.fromJson(json);
  }

  /// Sends a request to add a role to a WordPress user. Include a valid
  /// [userToken] and [role] to send a successful request.
  ///
  /// Returns a [WPUserInfoUpdatedResponse] future.
  /// Throws an [Exception] if fails.
  Future<WPUserAddRoleResponse> wpUserAddRole(userToken, {required String role}) async {
    Map<String, dynamic> payload = {};
    payload["role"] = role;

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserAddRole),
      userToken: userToken,
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserAddRoleResponse.fromJson(json);
  }

  /// Sends a request to remove a role from a WordPress user. Include a valid
  /// [userToken] and [role] to send a successful request.
  ///
  /// Returns a [WPUserInfoUpdatedResponse] future.
  /// Throws an [Exception] if fails.
  Future<WPUserRemoveRoleResponse> wpUserRemoveRole(userToken, {required String role}) async {
    Map<String, dynamic> payload = {};
    payload["role"] = role;

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserRemoveRole),
      userToken: userToken,
      body: payload,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserRemoveRoleResponse.fromJson(json);
  }

  /// Reset a user password using the [userToken] and new [password] created.
  ///
  /// Returns a [WCCustomerInfoResponse] future.
  /// Throws an [Exception] if fails.
  Future<WPUserResetPasswordResponse> wpResetPassword(
    String userToken, {
    required String password,
  }) async {
    Map<String, dynamic> payload = {"password": password};

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.UserUpdatePassword),
      body: payload,
      userToken: userToken,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WPUserResetPasswordResponse.fromJson(json);
  }

  /// Get the users WooCommerce information using the [userToken].
  ///
  /// Returns a [WCCustomerInfoResponse] future.
  /// Throws an [Exception] if fails.
  Future<WCCustomerInfoResponse> wcCustomerInfo(String userToken) async {
    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.WCCustomerInfo),
      userToken: userToken,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WCCustomerInfoResponse.fromJson(json);
  }

  /// Sends a request to update a users WooCommerce details using
  /// a valid [userToken], set optional parameters for updating user.
  ///
  /// Returns [WCCustomerUpdatedResponse] future.
  /// Throws an [Exception] if fails.
  Future<WCCustomerUpdatedResponse> wcUpdateCustomerInfo(userToken,
      {String? firstName,
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
      String? shippingEmail,
      String? shippingPhone}) async {
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

    // send http request
    final json = await _http(
      method: "POST",
      url: _urlForRouteType(WPRouteType.WCCustomerUpdateInfo),
      body: payload,
      userToken: userToken,
    );

    // return response
    return _jsonHasBadStatus(json)
        ? this._throwExceptionForStatusCode(json)
        : WCCustomerUpdatedResponse.fromJson(json);
  }

  /// Sends a Http request using a valid request [method] and [url] endpoint
  /// from the WP_JSON_API plugin. The [body] and [userToken] is optional but
  /// you can use these if the request requires them.
  ///
  /// Returns a [dynamic] response from the server.
  Future<dynamic> _http(
      {required String method,
      required String url,
      Map<String, dynamic>? body,
      String? userToken}) async {
    late var response;
    Uri uri = Uri.parse(url);
    if (method == "GET") {
      response = await http.get(
        uri,
      );
    } else if (method == "POST") {
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: "application/json",
      };
      if (body == null) {
        body = {};
      }
      if (userToken != null) {
        body.addAll({"token": userToken});
      }
      response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: headers,
      );
    }

    // log output
    _devLogger(
        url: response.request.url.toString(),
        payload: method == "GET"
            ? response.request.url.queryParametersAll.toString()
            : body.toString(),
        result: response.body.toString());

    // return response
    return jsonDecode(response.body);
  }

  /// Logs the output of a app request.
  /// [url] should be set containing the url route for the request.
  /// The [payload] and [result] are optional but are used in the
  /// log output if set. This will only log if shouldDebug is enabled.
  ///
  /// Returns void.
  _devLogger({required String url, String? payload, String? result}) {
    String strOutput = "\nREQUEST: " + url;
    if (payload != null) strOutput += "\nPayload: " + payload;
    if (result != null) strOutput += "\nRESULT: " + result;

    // logs response if shouldDebug is enabled
    if (WPJsonAPI.instance.shouldDebug()!) log(strOutput);
  }

  /// Checks if a response payload has a bad status (=> 500).
  ///
  /// Returns [bool] true if status is => 500.
  _jsonHasBadStatus(json) {
    return (json["status"] == null || json["status"] >= 500);
  }

  /// Creates an endpoint with the baseUrl and path.
  ///
  /// Returns [String] of the url route.
  String _urlForRouteType(WPRouteType wpRouteType) {
    return WPJsonAPI.instance.getBaseApi() + _getRouteUrlForType(wpRouteType);
  }

  /// Creates a query parameter which is used for the `wpLogin` method
  /// set [authType] to specify which method of authentication you want to use.
  ///
  /// Returns [String] of the query parameter.
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

  /// The routes available for the WP_JSON_API plugin
  /// set [wpRouteType] and use optional [apiVersion] to change API version.
  ///
  /// Returns [String] url path for request.
  String _getRouteUrlForType(
    WPRouteType wpRouteType, {
    String apiVersion = 'v3',
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
        case WPRouteType.UserAddRole:
        {
          return "/wpapp/api/$apiVersion/update/user/role/add";
        }
        case WPRouteType.UserRemoveRole:
        {
          return "/wpapp/api/$apiVersion/update/user/role/remove";
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

  /// Throws an exception from the [json] status returned from payload.
  _throwExceptionForStatusCode(json) {
    if (json != null && json['status'] != null) {
      int? statusCode = json["status"];
      String message = json["message"] ?? 'Something went wrong';

      switch (statusCode) {
        case 520:
          throw new UsernameTakenException();
        case 500:
          throw new Exception(message);
        case 510:
          throw new WooCommerceNotFoundException();
        case 540:
          throw new InvalidUserTokenException();
        case 523:
          throw new InvalidParamsException();
        case 567:
          throw new Exception(message);
        case 547:
          throw new InvalidEmailException(message);
        case 546:
          throw new IncorrectPasswordException(message);
        case 545:
          throw new InvalidUsernameException(message);
        case 531:
          throw new ExistingUserLoginException(message);
        case 532:
          throw new ExistingUserEmailException(message);
        case 527:
          throw new UserAlreadyExistException();
        case 542:
          throw new EmptyUsernameException();
        default: {
          throw new Exception('Something went wrong, please check server response');
        }
      }
    }
  }
}
