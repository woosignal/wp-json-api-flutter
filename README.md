# WordPress and WooCommerce JSON API Dart package for Flutter

You can download the WordPress plugin here [WP JSON API](https://woosignal.com/plugins/wordpress/wp-json-api).

**Version 5.0 requires the [WP JSON API](https://woosignal.com/plugins/wordpress/wp-json-api) WordPress plugin 5.0 or later.** It uses the plugin's `wpapp/v4` API. Upgrading from 4.x? See [Migrating from 4.x](#migrating-from-4x).

## API features:

**WordPress**

* Register/Sign Up API for Users
* Login (with email or username)
* Logout (revokes the token)
* Get Users Info
* Update Users Info
* Update Users Password
* Delete a user

**WooCommerce**

* Get Customers Info (Billing and Shipping)
* Update Customers details
* Points and Rewards

To use this API you must have the [WP JSON API Plugin](https://woosignal.com/plugins/wordpress/wp-json-api) (5.0 or later) installed first on your WordPress site, you can download it via the WooSignal website.

### Getting Started #
In your flutter project add the dependency:

``` dart 
dependencies:
  ...
  wp_json_api: ^5.0.0
```

### Usage example #
Import wp_json_api.dart
``` dart
import 'package:wp_json_api/wp_json_api.dart';
```

### Example using Wp JSON API

``` dart
import 'package:wp_json_api/wp_json_api.dart';
...

void main() {

WPJsonAPI.instance.init(baseUrl: "https://mysite.com");

...
```


### Call a method from the request callback
``` dart
// Models and exceptions are imported from their own files
import 'package:wp_json_api/exceptions/invalid_credentials_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
...

try {
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
          .api((request) => request.wpLogin(
            login: usernameOrEmail,
            password: password
          ));
} on InvalidCredentialsException {
    print("The login details are incorrect");
} on Exception catch (e) {
    print(e);
}
```

### Authentication

After a successful login or register, the user and their token are stored on the device. Every authenticated request then sends the token in the `Authorization: Bearer <token>` and `X-WPApp-Token: <token>` headers. You can pass `userToken:` to any authenticated method to use a different token.

Tokens expire (90 days by default, set on the server). You can ask for a shorter lifetime with `expiresIn` (seconds) when logging in or registering.

``` dart
bool isLoggedIn = await WPJsonAPI.wpUserLoggedIn(); // false if the token has expired
DateTime? expiresAt = await WPJsonAPI.wpUserTokenExpiresAt();
WpUser? user = await WPJsonAPI.wpUser();
```

If a request throws `InvalidUserTokenException`, the token is no longer valid (expired, revoked or the password changed elsewhere). Log the user out and ask them to login again.

### Available API Requests

#### WordPress - Login
- Used to login a user
- `login` can be the username or the email. You can also pass `email:` or `username:` instead of `login:`

``` dart
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
      .api((request) => request.wpLogin(
          login: usernameOrEmail,
          password: password,
          // expiresIn: 3600, // optional - token lifetime in seconds
          // deviceName: "Luke's iPhone", // optional - shown to admins
      ));

print(wpUserLoginResponse.data?.token);
print(wpUserLoginResponse.data?.expiresAtDateTime);
print(wpUserLoginResponse.data?.user?.email);
```

#### WordPress - Register
- Used to register a user
- The username is optional, the server will generate one from the email if not provided
- `metaData` only accepts keys on the site's allow-list (by default the WooCommerce billing and shipping fields)

``` dart
WPUserRegisterResponse wpUserRegisterResponse = await WPJsonAPI.instance
      .api((request) => request.wpRegister(
          email: email,
          password: password,
          // username: username, // optional
          // firstName: firstName, // optional
          // lastName: lastName, // optional
          // metaData: {"billing_phone": "0123456789"}, // optional
      ));
```

#### WordPress - Logout
- Revokes the token on the server and removes the user from the device
- The user is always removed from the device, even if the request fails
- Returns `true` if the server revoked the token

``` dart
bool revoked = await WPJsonAPI.instance
        .api((request) => request.wpLogout());
```

#### WordPress - Get Users Info
- Used to get a WordPress users info
- After you login/register, you can call this method to get the users info

``` dart
WPUserInfoResponse wpUserInfoResponse = await WPJsonAPI.instance
        .api((request) => request.wpGetUserInfo());

String? city = wpUserInfoResponse.data?.getMetaDataFirstWhere("billing_city");
```

#### WordPress - Update Users Info
- Used to update a WordPress users info
- After you login/register, you can call this method to update the users info
- `metaData` only accepts keys on the site's allow-list. One key that is not allowed fails the whole request with a `MetaKeyNotAllowedException`

``` dart
WPUserInfoUpdatedResponse wpUserInfoUpdatedResponse = await WPJsonAPI.instance
        .api((request) => request.wpUpdateUserInfo(
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
          metaData: [
            WpMetaData(key: "billing_city", value: "London"),
          ],
      ));

print(wpUserInfoUpdatedResponse.data?.firstName); // the updated user
```

#### WordPress - Update users password
- Used to change a users password
- The user's current password is required
- The user's other tokens are revoked; the current token stays valid

``` dart
WPUserResetPasswordResponse wpUserResetPasswordResponse = await WPJsonAPI.instance
        .api((request) => request.wpResetPassword(
            currentPassword: currentPassword,
            password: newPassword
        ));
```

#### WordPress - Delete a user
- Used to delete the logged in user's account
- The user's current password is required
- On success the user is removed from the device

``` dart
WPUserDeleteResponse wpUserDeleteResponse = await WPJsonAPI.instance
        .api((request) => request.wpUserDelete(
            password: password
        ));
```

#### WooCommerce - Register
- Used to register a user as a WooCommerce customer
- Takes the same parameters as `wpRegister`

``` dart
WPUserRegisterResponse wpUserRegisterResponse = await WPJsonAPI.instance
      .api((request) => request.wcRegister(
          email: email,
          password: password
      ));
```

#### WooCommerce - Get users info in WooCommerce
- Used to get WooCommerce info for a given user
- After you login/register, you can call this method to get the users WooCommerce info

``` dart
WCCustomerInfoResponse wcCustomerInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wcCustomerInfo());
```

#### WooCommerce - Update users info in WooCommerce
- Used to update a users WooCommerce details
- All the parameter are optional so if you wanted to just update the name, you could just add first_name and last_name
- After you login/register, you can call this method to update the users WooCommerce info

``` dart
WCCustomerUpdatedResponse wcCustomerUpdatedResponse = await WPJsonAPI.instance
        .api((request) => request.wcUpdateCustomerInfo(
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            billingFirstName: billingFirstName,
            billingLastName: billingLastName,
            billingCompany: billingCompany,
            billingAddress1: billingAddress1,
            billingAddress2: billingAddress2,
            billingCity: billingCity,
            billingState: billingState,
            billingPostcode: billingPostcode,
            billingCountry: billingCountry,
            billingEmail: billingEmail,
            billingPhone: billingPhone,
            shippingFirstName: shippingFirstName,
            shippingLastName: shippingLastName,
            shippingCompany: shippingCompany,
            shippingAddress1: shippingAddress1,
            shippingAddress2: shippingAddress2,
            shippingCity: shippingCity,
            shippingState: shippingState,
            shippingPostcode: shippingPostcode,
            shippingCountry: shippingCountry,
            shippingPhone: shippingPhone
        ));

print(wcCustomerUpdatedResponse.data?.billing?.city); // the updated customer
```

#### WooCommerce Points and Rewards - Get user's points 
- This is used to get the user's current points in the [WooCommerce Points and Rewards](https://woo.com/products/woocommerce-points-and-rewards/) plugin
- After you login/register, you can call this method to get the users points

``` dart
WcPointsAndRewardUser wcPointsAndRewardUser = await WPJsonAPI.instance
          .api((request) => request.wcPointsAndRewardsUser());
```

#### WooCommerce Points and Rewards - Calculate the value of points
- This is used to calculate the value of points in the [WooCommerce Points and Rewards](https://woo.com/products/woocommerce-points-and-rewards/) plugin
- After you login/register, you can call this method to calculate the value of points

``` dart
WcPointsAndRewardCalculatePoints wcPointsAndRewardsCalculatePoints = await WPJsonAPI.instance
          .api((request) => request.wcPointsAndRewardsCalculatePoints(
          points: 100
      ));
```

### Errors

A request is successful only when the server returns an HTTP 2xx status. Otherwise a typed exception is thrown, based on the error `code` returned by the plugin. Each exception has a `message` from the server that you can show to the user.

| Server `code` | HTTP | Exception |
|---|---|---|
| `wpapp_unauthorized` | 401 | `InvalidUserTokenException` |
| `wpapp_privileged_user` | 403 | `PrivilegedUserException` |
| `wpapp_invalid_credentials` | 401 | `InvalidCredentialsException` |
| `wpapp_login_blocked` | 403 | `LoginBlockedException` (show its `message`) |
| `wpapp_too_many_attempts` | 429 | `TooManyAttemptsException` (`retryAfter` in seconds) |
| `wpapp_registration_disabled` | 403 | `RegistrationDisabledException` |
| `wpapp_username_taken` | 409 | `UsernameTakenException` |
| `wpapp_email_exists` | 409 | `UserAlreadyExistException` |
| `wpapp_invalid_email` | 400 | `InvalidEmailException` |
| `wpapp_weak_password` | 400 | `WeakPasswordException` |
| `wpapp_meta_key_not_allowed` | 403 | `MetaKeyNotAllowedException` (`key` is the refused key) |
| `wpapp_incorrect_password` | 403 | `IncorrectPasswordException` |
| `wpapp_woocommerce_missing` | 501 | `WooCommerceNotFoundException` |
| `wpapp_points_rewards_missing` | 501 | `PointsAndRewardsNotFoundException` |
| `wpapp_invalid_params`, `rest_missing_callback_param`, `rest_invalid_param` | 400 | `InvalidParamsException` |
| `wpapp_server_error` and any other code | 4xx/5xx | `WPServerException` (`code`, `status`, `data`) |
| No response (offline, timeout) | - | `WPNetworkException` (`error` is the underlying error) |

Exceptions are imported from `package:wp_json_api/exceptions/...`, e.g.

``` dart
import 'package:wp_json_api/exceptions/too_many_attempts_exception.dart';

try {
  await WPJsonAPI.instance.api((request) => request.wpLogin(login: login, password: password));
} on TooManyAttemptsException catch (e) {
  print("Try again in ${e.retryAfter} seconds");
}
```

## Migrating from 4.x

5.0 only works with the WP JSON API WordPress plugin **5.0 or later**. Update the plugin on your site first; the plugin keeps the old v3 API working for apps that are still on 4.x.

**Authentication**
* The token is sent in the `Authorization: Bearer` and `X-WPApp-Token` headers instead of the request body. No code change is needed if you use the stored token.
* There is no nonce anymore. `wpNonce()` and `wpNonceVerify()` have been removed.
* Tokens always expire. `WPJsonAPI.wpUserLoggedIn()` returns `false` once the stored token has expired. Sessions saved by 4.x have no expiry and are treated as logged out, so your users will need to login once after updating.
* Users with admin-level capabilities (administrators, shop managers) can't login through the API unless the site allows it. They get a `PrivilegedUserException`.

**Method changes**

| 4.x | 5.0 |
|---|---|
| `wpLogin(email: e, password: p, authType: WPAuthType.WpEmail)` | `wpLogin(login: e, password: p)` (`email:` and `username:` still work) |
| `wpLogin(..., tokenExpiryAt: "+1 day")` | `wpLogin(..., expiresIn: 86400)` |
| `wpRegister(..., expiry: ..., args: {...})` | `wpRegister(..., expiresIn: ..., firstName: ..., lastName: ..., metaData: {...})` |
| `wpResetPassword(password: p)` | `wpResetPassword(currentPassword: current, password: p)` |
| `wpUserDelete(reassign: id)` | `wpUserDelete(password: p)` |
| `wpLogout()` (local only) | `wpLogout()` revokes the token on the server, then clears the device. Returns `Future<bool>` |
| `wpUserAddRole(role: r)`, `wpUserRemoveRole(role: r)` | Removed. Manage roles on the server |
| `wpNonce()`, `wpNonceVerify(nonce: n)` | Removed |
| `wcUpdateCustomerInfo(shippingEmail: ...)` | Removed (not a WooCommerce shipping field) |

**Response changes**
* `WPUserLoginResponse.data` / `WPUserRegisterResponse.data`: `userToken` is now `token`, `expiry` is now `expiresAt` (Unix seconds), and the user's details moved to `user` (e.g. `data?.userId` is now `data?.user?.id`, `data?.email` is now `data?.user?.email`).
* `WPUserInfoResponse.data`: `userNicename` and `userStatus` were removed. `metaData` only contains keys on the site's allow-list.
* `WPUserInfoUpdatedResponse.data` and `WCCustomerUpdatedResponse.data` now contain the updated user / customer.
* `WpMetaData.unique` is now a `bool?`.
* `WpUser` has a new `expiresAt`, `expiresAtDateTime` and `isTokenExpired`.

**Exceptions**
* Errors are now based on the HTTP status and the error `code`; see [Errors](#errors).
* Removed: `InvalidNonceException`, `EmptyUsernameException`, `ExistingUserLoginException` (now `UsernameTakenException`), `ExistingUserEmailException` (now `UserAlreadyExistException`) and `InvalidUsernameException` (login failures are now `InvalidCredentialsException`; `IncorrectPasswordException` is only used when confirming the password to change it or delete the account).
* New: `InvalidCredentialsException`, `LoginBlockedException`, `PrivilegedUserException`, `TooManyAttemptsException`, `RegistrationDisabledException`, `WeakPasswordException`, `MetaKeyNotAllowedException`, `PointsAndRewardsNotFoundException`, `WPServerException` and `WPNetworkException`.
* Requests that fail without a response throw `WPNetworkException` instead of a `DioException`.

For help getting started with WooSignal, view our
[online documentation](https://woosignal.com/docs/flutter/wp-json-api), which offers a more detailed guide.

## Usage
To use this plugin, add `wp_json_api` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Note
Install our WordPress plugin "[WP JSON API](https://woosignal.com/plugins/wordpress/wp-json-api)" v5.0 or later to use this flutter plugin. The plugin and this package share major versions: plugin 5.x works with wp_json_api 5.x.

Disclaimer: This plugin is not affiliated with or supported by Automattic, Inc. All logos and trademarks are the property of their respective owners.
