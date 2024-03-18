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

class WPUserRegisterResponse {
  Data? data;
  String? message;
  int? status;

  WPUserRegisterResponse({this.data, this.message, this.status});

  WPUserRegisterResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Data {
  int? userId;
  String? userToken;
  int? expiry;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? avatar;
  String? createdAt;

  Data(
      {this.userId,
      this.userToken,
      this.expiry,
      this.email,
      this.username,
      this.firstName,
      this.lastName,
      this.avatar,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userToken = json['user_token'];
    expiry = json['expiry'];
    if (json.containsKey('email')) {
      email = json['email'];
    }
    if (json.containsKey('username')) {
      username = json['username'];
    }
    if (json.containsKey('first_name')) {
      firstName = json['first_name'];
    }
    if (json.containsKey('last_name')) {
      lastName = json['last_name'];
    }
    if (json.containsKey('avatar')) {
      avatar = json['avatar'];
    }
    if (json.containsKey('created_at')) {
      createdAt = json['created_at'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.userId;
    data['user_token'] = this.userToken;
    data['expiry'] = this.expiry;
    data['email'] = this.email;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['avatar'] = this.avatar;
    data['created_at'] = this.createdAt;
    return data;
  }
}
