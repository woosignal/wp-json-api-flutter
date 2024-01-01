// Copyright (c) 2024, WooSignal Ltd.
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

enum WPMetaDataActionType {
  /// MetaData action type [WPMetaDataActionType.Create] is used for
  /// creating/adding additional meta data to a key.
  Create,

  /// MetaData action type [WPMetaDataActionType.Update] is used for
  /// updating a meta data key.
  /// If the meta field for the user does not exist, it will be added.
  Update,

  /// MetaData action type [WPMetaDataActionType.Delete] is used for
  /// deleting a meta data key and value. You can optionally pass in a [value]
  /// to only remove that value from the the array of data.
  Delete,
}
