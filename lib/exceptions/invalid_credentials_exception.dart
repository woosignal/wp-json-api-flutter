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

/// Thrown when a login fails. The same error is returned for an unknown
/// user and a wrong password.
///
/// Server error code: `wpapp_invalid_credentials` (HTTP 401).
class InvalidCredentialsException implements Exception {
  String message;
  InvalidCredentialsException([String? message])
      : message = message ?? 'The login details are incorrect';

  @override
  String toString() => 'InvalidCredentialsException: $message';
}
