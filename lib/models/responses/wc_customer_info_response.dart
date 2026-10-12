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

class WCCustomerInfoResponse {
  Data? data;
  String? message;
  int? status;

  WCCustomerInfoResponse({this.data, this.message, this.status});

  WCCustomerInfoResponse.fromJson(Map<String, dynamic> json) {
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

/// A WooCommerce customer, as returned by the WP JSON API v4 **Customer**
/// object.
class Data {
  int? id;
  String? firstName;
  String? lastName;
  String? displayName;
  String? avatar;
  Shipping? shipping;
  Billing? billing;

  /// Allow-listed user meta. Each key can have several values.
  List<MetaData>? metaData;
  String? createdAt;

  Data(
      {this.id,
      this.firstName,
      this.lastName,
      this.displayName,
      this.avatar,
      this.shipping,
      this.billing,
      this.metaData,
      this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    displayName = json['display_name'];
    avatar = json['avatar'];
    shipping = json['shipping'] is Map
        ? Shipping.fromJson(Map<String, dynamic>.from(json['shipping']))
        : null;
    billing = json['billing'] is Map
        ? Billing.fromJson(Map<String, dynamic>.from(json['billing']))
        : null;
    metaData = MetaData.listFromJson(json['meta_data']);
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['id'] = id;
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['display_name'] = displayName;
    result['avatar'] = avatar;
    if (shipping != null) {
      result['shipping'] = shipping!.toJson();
    }
    if (billing != null) {
      result['billing'] = billing!.toJson();
    }
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

class Shipping {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? phone;

  Shipping(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country,
      this.phone});

  Shipping.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    state = json['state'];
    postcode = json['postcode'];
    country = json['country'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['company'] = company;
    result['address_1'] = address1;
    result['address_2'] = address2;
    result['city'] = city;
    result['state'] = state;
    result['postcode'] = postcode;
    result['country'] = country;
    result['phone'] = phone;
    return result;
  }
}

class Billing {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

  Billing(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country,
      this.email,
      this.phone});

  Billing.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    state = json['state'];
    postcode = json['postcode'];
    country = json['country'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['company'] = company;
    result['address_1'] = address1;
    result['address_2'] = address2;
    result['city'] = city;
    result['state'] = state;
    result['postcode'] = postcode;
    result['country'] = country;
    result['email'] = email;
    result['phone'] = phone;
    return result;
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
