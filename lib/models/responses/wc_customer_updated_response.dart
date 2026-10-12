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

import '/models/responses/wc_customer_info_response.dart';

/// The response from `POST /wc/customer`. [data] is the updated record.
class WCCustomerUpdatedResponse {
  Data? data;
  String? message;
  int? status;

  WCCustomerUpdatedResponse({this.data, this.message, this.status});

  WCCustomerUpdatedResponse.fromJson(Map<String, dynamic> json) {
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
