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

/// Thrown when the account is not allowed to use the API, e.g. an
/// administrator or shop manager.
///
/// Server error code: `wpapp_privileged_user` (HTTP 403).
class PrivilegedUserException implements Exception {
  String message;
  PrivilegedUserException([String? message])
      : message = message ?? 'This account is not allowed to use the API';

  @override
  String toString() => 'PrivilegedUserException: $message';
}
