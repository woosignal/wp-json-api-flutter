# WordPress and WooCommerce JSON API Dart package for Flutter

[Official WooSignal WooCommerce package](https://woosignal.com)

API features:

**WordPress**
    - Register/Sign Up API for Users
    - Login (with email or username)
    - Get Users Info
    - Update Users Info
    - Update Users Password

**WooCommerce**:
    - Get Customers Info (Billing and Shipping)
    - Update Customers details

To use this API you must have the [WP Json API Plugin](https://woosignal.com/plugins/wp-json-api) installed first on your WordPress site, you can download it via the WooSignal website.

### Examples using Wp JSON API

``` dart
import 'package:woosignal/wp_json_api.dart';

...

#1 - Set the base url (e.g. https://mysite.com)
``` dart
String base_url = "https://mywordpress-site.com";
WPJsonAPI.instance.initWith(baseUrl: base_url);
```

#2 - Call a method from the request api
``` dart
WPUserLoginResponse wpUserLoginResponse = await WPJsonAPI.instance.api((request) {
       return request.wpLogin(email: email, password: password);
       });
```
For help getting started with WooSignal, view our
[online documentation](https://woosignal.com/docs/wordpress-json-api-flutter/1.0/overview), which offers a more detailed guide.

## Usage
To use this plugin, add `wp_json_api` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Disclaimer: This plugin is not affiliated with or supported by Automattic, Inc. All logos and trademarks are the property of their respective owners.