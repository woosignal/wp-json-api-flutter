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

import '/enums/wp_meta_data_action_type.dart';

class WpMetaData {
  String? key;
  dynamic value;
  WPMetaDataActionType action;
  int? unique;

  WpMetaData(
      {this.key,
      this.value,
      this.action = WPMetaDataActionType.Update,
      this.unique});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['key'] = key;
    result['value'] = value;
    result['action'] = _getActionFromType();
    if (unique != null) {
      result['unique'] = unique;
    }
    return result;
  }

  String _getActionFromType() {
    switch (action) {
      case WPMetaDataActionType.Create:
        return "create";
      case WPMetaDataActionType.Update:
        return "update";
      case WPMetaDataActionType.Delete:
        return "delete";
    }
  }
}
