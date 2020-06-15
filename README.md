# WordPress and WooCommerce JSON API Dart package for Flutter

[Official WooSignal package](https://woosignal.com)

## API features:

**WordPress**

* Register/Sign Up API for Users
* Login (with email or username)
* Get Users Info
* Update Users Info
* Update Users Password

**WooCommerce**

* Get Customers Info (Billing and Shipping)
* Update Customers details

To use this API you must have the [WP JSON API Plugin](https://woosignal.com/plugins/wordpress/wp-json-api) installed first on your WordPress site, you can download it via the WooSignal website.

### Getting Started #
In your flutter project add the dependency:

``` dart 
dependencies:
  ...
  wp_json_api: ^0.1.4
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

WPJsonAPI.instance.initWith(baseUrl: "https://mysite.com");

...
```


### Call a method from the request callback
``` dart
try {
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
          .api((request) => request.wpLogin(
            email: email,
            password: password
          ));
} on Exception catch (e) {
    print(e);
}
```

### Available API Requests

#### WordPress - Get Nonce
- Used for returning a valid nonce
``` dart
WPNonceResponse wpNonceResponse = await WPJsonAPI.instance
          .api((request) => request.wpNonce());
```

#### WordPress - Verify Nonce
- Used for verifying register and login request
``` dart
WPNonceVerifiedResponse wpNonceVerifiedResponse = await WPJsonAPI.instance
          .api((request) => request.wpNonceVerify(
            nonce: nonce
          ));
```

#### WordPress - Login with email
- Used to login a user

``` dart
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
      .api((request) => request.wpLogin(
          email: email,
          password: password,
          authType: WPAuthType.WpEmail
      ));
```

#### WordPress - Login with username
- Used to login a user

``` dart
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance
      .api((request) => request.wpLogin(
          username: username,
          password: password,
          authType: WPAuthType.WpUsername
      ));
```

#### WordPress - Register
- Used to register a user
- The username parameter is required, ensure that this is unique

``` dart
WPUserRegisterResponse wpUserRegisterResponse = await WPJsonAPI.instance
      .api((request) => request.wpRegister(
          email: email,
          password: password,
          username: username
      ));
```

#### WordPress - Get Users Info
- Used to get a WordPress users info
- The first parameter is the **userToken** which is returned from the login/register response. You should have this saved somewhere e.g. shared_pref

``` dart
WPUserInfoResponse wpUserInfoResponse = await WPJsonAPI.instance
        .api((request) => request.wpGetUserInfo(
            userToken
          ));
```

#### WordPress - Update Users Info
- Used to update a WordPress users info
- The first parameter is the **userToken** which is returned from the login/register response. You should have this saved somewhere e.g. shared_pref

``` dart
WPUserInfoUpdatedResponse wpUserInfoUpdatedResponse = await WPJsonAPI.instance
        .api((request) => request.wpUpdateUserInfo(
          userToken,
          firstName: firstName,
          lastName: lastName,
          displayName: displayName
      ));
```

#### WordPress - Update users password
- Used to update a users password
- The first parameter is the **userToken** which is returned from the login/register response. You should have this saved somewhere e.g. shared_pref

``` dart
WPUserResetPasswordResponse wpUserResetPasswordResponse = await WPJsonAPI.instance
        .api((request) => request.wpResetPassword(
            userToken,
            password: password
        ));
```

#### WooCommerce - Get users info in WooCommerce
- Used to get WooCommerce info for a given user
- The first parameter is the **userToken** which is returned from the login/register response. You should have this saved somewhere e.g. shared_pref

``` dart
WCCustomerInfoResponse wcCustomerInfoResponse = await WPJsonAPI.instance
          .api((request) => request.wcCustomerInfo(
          userToken
      ));
```

#### WooCommerce - Update users info in WooCommerce
- Used to update a users WooCommerce details
- All the parameter are optional so if you wanted to just update the name, you could just add first_name and last_name
- The first parameter is the **userToken** which is returned from the login/register response. You should have this saved somewhere e.g. shared_pref

``` dart
WCCustomerUpdatedResponse wcCustomerUpdatedResponse = await WPJsonAPI.instance
        .api((request) => request.wcUpdateCustomerInfo(
            userToken,
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
            shippingEmail: shippingEmail,
            shippingPhone: shippingPhone
        ));
```

For help getting started with WooSignal, view our
[online documentation](https://woosignal.com/docs/flutter/wp-json-api), which offers a more detailed guide.

## Usage
To use this plugin, add `wp_json_api` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Note
Install WordPress plugin "WP JSON API" 2.0.x or later for version 0.1.4

Disclaimer: This plugin is not affiliated with or supported by Automattic, Inc. All logos and trademarks are the property of their respective owners.
