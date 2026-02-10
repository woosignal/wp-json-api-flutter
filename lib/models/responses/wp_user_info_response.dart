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

import 'package:collection/collection.dart' show IterableExtension;

class WPUserInfoResponse {
  Data? data;
  String? message;
  int? status;

  WPUserInfoResponse({this.data, this.message, this.status});

  WPUserInfoResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? userNicename;
  String? displayName;
  String? userStatus;
  String? email;
  String? avatar;
  List<MetaData>? metaData;
  List<String>? roles;
  String? createdAt;

  Data(
      {this.id,
      this.firstName,
      this.lastName,
      this.username,
      this.userNicename,
      this.displayName,
      this.roles,
      this.userStatus,
      this.email,
      this.avatar,
      this.metaData,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    userNicename = json['user_nicename'];
    displayName = json['display_name'];
    userStatus = json['user_status'];
    email = json['email'];
    roles = [];
    if (json['roles'] != null) {
      for (final role in json['roles'] as List) {
        roles!.add(role);
      }
    }
    avatar = json['avatar'];
    if (json['meta_data'] != null && Map.of(json['meta_data']).isNotEmpty) {
      metaData = [];
      Map.from(json['meta_data']).forEach((key, value) {
        metaData!.add(MetaData.fromJson(key, value));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['id'] = id;
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['username'] = username;
    result['user_nicename'] = userNicename;
    result['display_name'] = displayName;
    result['user_status'] = userStatus;
    result['email'] = email;
    result['roles'] = (roles ?? []).map((e) => e).toList();
    result['avatar'] = avatar;
    if (metaData != null) {
      result['meta_data'] = metaData!.map((e) => e.toJson()).toList();
    }
    result['created_at'] = createdAt;
    return result;
  }

  /// Returns an array of meta data from a WP MetaData [key]
  ///
  /// Returns List<dynamic>
  List<dynamic>? getMetaDataArrayWhere(String key) {
    if (metaData == null) return null;
    MetaData? meta = metaData!.firstWhereOrNull((e) => e.key == key);
    if (meta == null || meta.value == null) {
      return null;
    }
    return meta.value;
  }

  /// Returns a single meta data value from a WP MetaData [key]
  ///
  /// Returns dynamic
  dynamic getMetaDataFirstWhere(String key) {
    if (metaData == null) return null;
    MetaData? meta = metaData!.firstWhereOrNull((e) => e.key == key);
    if (meta == null || meta.value == null || meta.value!.isEmpty) {
      return null;
    }
    return meta.value!.first;
  }
}

class MetaData {
  String? key;
  List<dynamic>? value;

  MetaData({this.key, this.value});

  MetaData.fromJson(String key, List<dynamic> value)
      : key = key,
        value = value;

  Map<String?, dynamic> toJson() {
    final Map<String?, List<dynamic>?> result = <String?, List<dynamic>?>{};
    if (key != null) {
      result[key] = value;
    }
    return result;
  }
}
