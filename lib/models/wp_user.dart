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

import 'package:nylo_support/helpers/helper.dart';
import '/models/responses/wp_user_login_response.dart';
import '/models/responses/wp_user_register_response.dart';

class WpUser extends Model {
  int? id;
  String? token;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? avatar;
  String? createdAt;

  WpUser(
      {this.id,
      this.token,
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
    id = wpUserRegisterResponse.data?.userId;
    token = wpUserRegisterResponse.data?.userToken;
    email = wpUserRegisterResponse.data?.email;
    username = wpUserRegisterResponse.data?.username;
    firstName = wpUserRegisterResponse.data?.firstName;
    lastName = wpUserRegisterResponse.data?.lastName;
    avatar = wpUserRegisterResponse.data?.avatar;
    createdAt = wpUserRegisterResponse.data?.createdAt;
  }

  /// Creates a [WpUser] from a [WPUserLoginResponse]
  WpUser.fromWPUserLoginResponse(WPUserLoginResponse wpUserLoginResponse) {
    id = wpUserLoginResponse.data?.userId;
    token = wpUserLoginResponse.data?.userToken;
    email = wpUserLoginResponse.data?.email;
    username = wpUserLoginResponse.data?.username;
    firstName = wpUserLoginResponse.data?.firstName;
    lastName = wpUserLoginResponse.data?.lastName;
    avatar = wpUserLoginResponse.data?.avatar;
    createdAt = wpUserLoginResponse.data?.createdAt;
  }

  /// Converts the [WpUser] to a JSON object
  toJson() => {
        'id': id,
        'token': token,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': avatar,
        'created_at': createdAt
      };
}
