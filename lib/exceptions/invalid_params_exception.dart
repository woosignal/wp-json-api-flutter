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

/// Thrown when a parameter is missing, has the wrong type or value.
///
/// Server error codes: `wpapp_invalid_params`, `rest_missing_callback_param`
/// and `rest_invalid_param` (HTTP 400).
class InvalidParamsException implements Exception {
  String message;
  InvalidParamsException([String? message])
      : message = message ?? 'Invalid parameters, please check the data';

  @override
  String toString() => 'InvalidParamsException: $message';
}
