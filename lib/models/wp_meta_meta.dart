// Copyright (c) 2020, WooSignal Ltd.
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

import 'package:wp_json_api/enums/wp_meta_data_action_type.dart';

class UserMetaDataItem {
  String key;
  String value;
  WPMetaDataActionType action;
  int unique;

  UserMetaDataItem({this.key, this.value, this.action = WPMetaDataActionType.Update, this.unique});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    if (this.action != null) {
      data['action'] = _getActionFromType();
    }
    if (this.unique != null) {
      data['unique'] = this.unique;
    }
    return data;
  }

  String _getActionFromType() {
    switch (this.action) {
      case WPMetaDataActionType.Create:
        {
          return "create";
        }
      case WPMetaDataActionType.Update:
        {
          return "update";
        }
      case WPMetaDataActionType.Delete:
        {
          return "delete";
        }
      default:
        {
          return "";
        }
    }
  }
}
