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

// ignore_for_file: constant_identifier_names

/// The routes available in the WP JSON API `wpapp/v4` namespace.
enum WPRouteType {
  /// Route type [WPRouteType.UserLogin] is used to login a user on WordPress.
  /// `POST /auth/login`
  UserLogin,

  /// Route type [WPRouteType.UserRegister] is used to register a user on
  /// WordPress (or WooCommerce). `POST /auth/register`
  UserRegister,

  /// Route type [WPRouteType.UserLogout] is used to revoke the user's token.
  /// `POST /auth/logout`
  UserLogout,

  /// Route type [WPRouteType.UserInfo] is used to return a WordPress user's info.
  /// `GET /user`
  UserInfo,

  /// Route type [WPRouteType.UserUpdateInfo] is used to update a WordPress user's account info.
  /// `POST /user`
  UserUpdateInfo,

  /// Route type [WPRouteType.UserUpdatePassword] is used to update a WordPress user's password.
  /// `POST /user/password`
  UserUpdatePassword,

  /// Route type [WPRouteType.UserDelete] is used to delete a user from WordPress.
  /// `POST /user/delete`
  UserDelete,

  /// Route type [WPRouteType.WCCustomerInfo] is used to get a Customer's info.
  /// For WooCommerce. `GET /wc/customer`
  WCCustomerInfo,

  /// Route type [WPRouteType.WCCustomerUpdateInfo] is used to Update WooCommerce details for a customer.
  /// For WooCommerce. `POST /wc/customer`
  WCCustomerUpdateInfo,

  /// Route type [WPRouteType.WCPointsAndRewardsUser] is used to get a customers points.
  /// For WooCommerce Points and Rewards. `GET /wc/points`
  WCPointsAndRewardsUser,

  /// Route type [WPRouteType.WCPointsAndRewardsCalculatePoints] is used to calculate the value of a customer's points.
  /// For WooCommerce Points and Rewards. `POST /wc/points/calculate`
  WCPointsAndRewardsCalculatePoints,
}
