## [3.5.0] - 2024-03-18

* Breaking change `WPJsonAPI.initWith` is now `WPJsonAPI.init`
* Refactor project
* Ability to save user token for future requests
* New WpUser model for user data
* New wcRegister method for networking class
* Add more data to `WpUserLoginResponse` and `WpUserInfoResponse`
* Added `version` to `WpJsonAPI` class
* New `WPJsonAPI.wpLogin` method to login a user
* New `WPJsonAPI.wpLogout` method to logout a user
* New `WPJsonAPI.wpUserLoggedIn` method to check if a user is logged in
* New `WPJsonAPI.wpUser` method to get the current user
* New `WPJsonAPI.wpUserId` method to get the current user's ID
* New `WPJsonAPI.wpUserToken` method to get the current user's token
* New `WPJsonAPI.wpAuth` method to authenticate the previously logged in user 
* Added Storage key to `WPJsonAPI` class
* New docs added to Readme
* Dependency updates

## [3.4.0] - 2024-03-15

* Added new networking methods for WooCommerce Points and Rewards
* Dependency updates

## [3.3.4] - 2024-01-01

* Update license date
* Dependency updates
* Add GitHub actions

## [3.3.3] - 2023-10-05

* Use Dio instead of the **http** library
* Dependency updates

## [3.3.2] - 2022-02-20

* Add logo to package.

## [3.3.1] - 2022-12-28

* Fix updating meta for users
* Dependency updates

## [3.3.0] - 2022-09-01

* Dependency updates

## [3.2.0] - 2022-07-08

* New API to delete an account
* Update code docs

## [3.1.3] - 2021-09-03

* Add roles to wp_user_info_response

## [3.1.2] - 2021-09-02

* Ran flutter format

## [3.1.1] - 2021-09-02

* Update readme

## [3.1.0] - 2021-09-02

* Ability to add and remove roles from a user
* Dependency updates

## [3.0.0] - 2021-04-10

* Added null safety support
* Dependency updates

## [2.0.0] - 2020-11-18

* Support for v2.0.0 wp-json-api WordPress plugin

## [0.1.4] - 2020-06-16

* Meta data now is returned for users
* Ability to store, update and delete meta data on WP_User
* Throw exceptions for requests
* Handle async await in callback
* Updated models
* Refactor model file names
* More documentation added in code

## [0.1.3] - 2020-06-03

* pubspec.yaml update

## [0.1.2] - 2020-05-01

* Readme update

## [0.1.1] - 2020-04-30

* Readme update

## [0.1.0] - 2020-04-30

* pubspec.yaml desc change, updates to networking class and readme

## [0.0.1] - 2020-04-06

* Initial Release