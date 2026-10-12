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

/// Thrown for `wpapp_server_error` (HTTP 500) and for any error response
/// that has no dedicated exception, such as an unknown error [code] or a
/// response that is not a WordPress REST error.
///
/// [code] is the WordPress REST error code (null when the response had none),
/// [status] is the HTTP status code and [data] is the error's `data` object.
/// Show [message] to the user.
class WPServerException implements Exception {
  String message;
  String? code;
  int? status;
  Map<String, dynamic>? data;
  WPServerException(this.message, {this.code, this.status, this.data});

  @override
  String toString() => 'WPServerException($code, $status): $message';
}
