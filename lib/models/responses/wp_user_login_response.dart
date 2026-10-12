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

import '/models/responses/wp_user_info_response.dart' as user_info;

/// The response from `POST /auth/login`. [data] holds the new token, when it expires and
/// the user.
class WPUserLoginResponse {
  Data? data;
  String? message;
  int? status;

  WPUserLoginResponse({this.data, this.message, this.status});

  WPUserLoginResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] is Map
        ? Data.fromJson(Map<String, dynamic>.from(json['data']))
        : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    if (data != null) {
      result['data'] = data!.toJson();
    }
    result['message'] = message;
    result['status'] = status;
    return result;
  }
}

/// The WP JSON API v4 **Auth** object.
class Data {
  /// The token to send on authenticated requests.
  String? token;

  /// When the [token] expires, as a Unix timestamp in seconds.
  int? expiresAt;

  /// The user that the [token] belongs to.
  user_info.Data? user;

  Data({this.token, this.expiresAt, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expiresAt = json['expires_at'] is num
        ? (json['expires_at'] as num).toInt()
        : int.tryParse(json['expires_at']?.toString() ?? '');
    user = json['user'] is Map
        ? user_info.Data.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
  }

  /// Returns [expiresAt] as a [DateTime], or null if it is not set.
  DateTime? get expiresAtDateTime => expiresAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['token'] = token;
    result['expires_at'] = expiresAt;
    result['user'] = user?.toJson();
    return result;
  }
}
