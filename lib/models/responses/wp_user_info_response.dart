// Copyright (c) 2023, WooSignal Ltd.
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
      (json['roles'] as List).forEach((role) {
        roles!.add(role);
      });
    }
    avatar = json['avatar'];
    if (json['meta_data'] != null && Map.of(json['meta_data']).isNotEmpty) {
      this.metaData = [];
      Map.from(json['meta_data']).forEach((key, value) {
        this.metaData!.add(MetaData.fromJson(key, value));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['username'] = this.username;
    data['user_nicename'] = this.userNicename;
    data['display_name'] = this.displayName;
    data['user_status'] = this.userStatus;
    data['email'] = this.email;
    data['roles'] = (this.roles ?? []).map((e) => e).toList();
    data['avatar'] = this.avatar;
    if (this.metaData != null) {
      data['meta_data'] = this.metaData!.map((e) => e.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    return data;
  }

  /// Returns an array of meta data from a WP MetaData [key]
  ///
  /// Returns List<dynamic>
  List<dynamic>? getMetaDataArrayWhere(String key) {
    MetaData? metaData = this.metaData!.firstWhereOrNull((e) => e.key == key);
    if (metaData == null || metaData.value == null) {
      return null;
    }
    return metaData.value;
  }

  /// Returns a single meta data value from a WP MetaData [key]
  ///
  /// Returns dynamic
  dynamic getMetaDataFirstWhere(String key) {
    MetaData? metaData = this.metaData!.firstWhereOrNull((e) => e.key == key);
    if (metaData == null ||
        metaData.value == null ||
        metaData.value!.length < 1) {
      return null;
    }
    return metaData.value!.first;
  }
}

class MetaData {
  String? key;
  List<dynamic>? value;

  MetaData({this.key, this.value});

  MetaData.fromJson(String key, List<dynamic> value) {
    this.key = key;
    this.value = value;
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, List<dynamic>?> data =
        new Map<String?, List<dynamic>?>();
    if (key != null) {
      data[key] = this.value;
    }
    return data;
  }
}
