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
  String? firstName;
  String? lastName;
  String? displayName;
  String? avatar;
  Shipping? shipping;
  Billing? billing;
  List<MetaData>? metaData;

  Data(
      {this.firstName,
      this.lastName,
      this.displayName,
      this.avatar,
      this.shipping,
      this.billing,
      this.metaData});

  Data.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    displayName = json['display_name'];
    avatar = json['avatar'];
    shipping =
        json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null;
    billing =
        json['billing'] != null ? Billing.fromJson(json['billing']) : null;

    if (json['meta_data'] != null && Map.of(json['meta_data']).isNotEmpty) {
      metaData = [];
      Map.from(json['meta_data']).forEach((key, value) {
        metaData!.add(MetaData.fromJson(key, value));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
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
      result['meta_data'] = metaData!.map((e) => e.toJson()).toList();
    }
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

  Shipping(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.postcode,
      this.country});

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
