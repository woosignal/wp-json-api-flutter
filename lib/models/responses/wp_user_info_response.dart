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

/// A WordPress user, as returned by the WP JSON API v4 **User** object.
class Data {
  int? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? displayName;
  String? avatar;
  List<String>? roles;

  /// Allow-listed user meta. Each key can have several values.
  List<MetaData>? metaData;
  String? createdAt;

  Data(
      {this.id,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.displayName,
      this.avatar,
      this.roles,
      this.metaData,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    displayName = json['display_name'];
    avatar = json['avatar'];
    roles = [];
    if (json['roles'] is List) {
      for (final role in json['roles'] as List) {
        roles!.add(role.toString());
      }
    }
    metaData = MetaData.listFromJson(json['meta_data']);
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['id'] = id;
    result['username'] = username;
    result['email'] = email;
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['display_name'] = displayName;
    result['avatar'] = avatar;
    result['roles'] = (roles ?? []).map((e) => e).toList();
    if (metaData != null) {
      result['meta_data'] = MetaData.listToJson(metaData!);
    }
    result['created_at'] = createdAt;
    return result;
  }

  /// Returns an array of meta data from a WP MetaData [key]
  ///
  /// Returns `List<dynamic>`
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

/// A user meta key and its values.
class MetaData {
  String? key;
  List<dynamic>? value;

  MetaData({this.key, this.value});

  /// Creates a [MetaData] from a [key] and its [value]. A single value is
  /// wrapped in a list.
  MetaData.fromJson(String this.key, dynamic value)
      : value = value is List ? value : [value];

  /// Parses a `meta_data` map of key -> list of values.
  ///
  /// Returns null when [json] is not a non-empty map.
  static List<MetaData>? listFromJson(dynamic json) {
    if (json is! Map || json.isEmpty) return null;
    return json.entries
        .map((entry) => MetaData.fromJson(entry.key.toString(), entry.value))
        .toList();
  }

  /// Converts a list of [MetaData] back to a `meta_data` map.
  static Map<String, dynamic> listToJson(List<MetaData> metaData) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MetaData meta in metaData) {
      if (meta.key != null) {
        result[meta.key!] = meta.value;
      }
    }
    return result;
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, List<dynamic>?> result = <String?, List<dynamic>?>{};
    if (key != null) {
      result[key] = value;
    }
    return result;
  }
}
