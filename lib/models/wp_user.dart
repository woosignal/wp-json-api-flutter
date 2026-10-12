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

import 'package:nylo_support/helpers/src/model.dart';

import '/models/responses/wp_user_info_response.dart' as user_info;
import '/models/responses/wp_user_login_response.dart';
import '/models/responses/wp_user_register_response.dart';

/// The logged in user that wp_json_api stores on the device.
class WpUser extends Model {
  int? id;
  String? token;

  /// When the [token] expires, as a Unix timestamp in seconds.
  int? expiresAt;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? avatar;
  String? createdAt;

  WpUser(
      {this.id,
      this.token,
      this.expiresAt,
      this.email,
      this.username,
      this.firstName,
      this.lastName,
      this.avatar,
      this.createdAt});

  /// Creates a [WpUser] from a JSON object
  WpUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    expiresAt = json['expires_at'] is num
        ? (json['expires_at'] as num).toInt()
        : int.tryParse(json['expires_at']?.toString() ?? '');
    email = json['email'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    avatar = json['avatar'];
    createdAt = json['created_at'];
  }

  /// Creates a [WpUser] from a [WPUserRegisterResponse]
  WpUser.fromWPUserRegisterResponse(
      WPUserRegisterResponse wpUserRegisterResponse) {
    token = wpUserRegisterResponse.data?.token;
    expiresAt = wpUserRegisterResponse.data?.expiresAt;
    _setUser(wpUserRegisterResponse.data?.user);
  }

  /// Creates a [WpUser] from a [WPUserLoginResponse]
  WpUser.fromWPUserLoginResponse(WPUserLoginResponse wpUserLoginResponse) {
    token = wpUserLoginResponse.data?.token;
    expiresAt = wpUserLoginResponse.data?.expiresAt;
    _setUser(wpUserLoginResponse.data?.user);
  }

  /// Copies the profile fields from a v4 **User** object.
  void _setUser(user_info.Data? user) {
    id = user?.id;
    email = user?.email;
    username = user?.username;
    firstName = user?.firstName;
    lastName = user?.lastName;
    avatar = user?.avatar;
    createdAt = user?.createdAt;
  }

  /// Returns [expiresAt] as a [DateTime], or null if it is not set.
  DateTime? get expiresAtDateTime => expiresAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);

  /// Returns true if the [token] has expired on this device.
  ///
  /// A user without [expiresAt] (e.g. one stored by wp_json_api 4.x) is
  /// treated as expired, because WP JSON API 5.0 tokens always expire.
  bool get isTokenExpired {
    if (expiresAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt!;
  }

  /// Converts the [WpUser] to a JSON object
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'expires_at': expiresAt,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': avatar,
        'created_at': createdAt
      };
}
