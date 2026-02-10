import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/enums/wp_auth_type.dart';
import 'package:wp_json_api/enums/wp_meta_data_action_type.dart';
import 'package:wp_json_api/enums/wp_route_type.dart';

void main() {
  group('WPAuthType', () {
    test('should have WpEmail value', () {
      expect(WPAuthType.WpEmail, isNotNull);
      expect(WPAuthType.WpEmail.name, 'WpEmail');
    });

    test('should have WpUsername value', () {
      expect(WPAuthType.WpUsername, isNotNull);
      expect(WPAuthType.WpUsername.name, 'WpUsername');
    });

    test('should have exactly 2 values', () {
      expect(WPAuthType.values, hasLength(2));
    });

    test('values should be in expected order', () {
      expect(WPAuthType.values[0], WPAuthType.WpEmail);
      expect(WPAuthType.values[1], WPAuthType.WpUsername);
    });

    test('should be usable in switch statements', () {
      String getAuthMethod(WPAuthType type) {
        switch (type) {
          case WPAuthType.WpEmail:
            return 'email';
          case WPAuthType.WpUsername:
            return 'username';
        }
      }

      expect(getAuthMethod(WPAuthType.WpEmail), 'email');
      expect(getAuthMethod(WPAuthType.WpUsername), 'username');
    });

    test('should be comparable', () {
      expect(WPAuthType.WpEmail == WPAuthType.WpEmail, true);
      expect(WPAuthType.WpEmail == WPAuthType.WpUsername, false);
    });
  });

  group('WPMetaDataActionType', () {
    test('should have Create value', () {
      expect(WPMetaDataActionType.Create, isNotNull);
      expect(WPMetaDataActionType.Create.name, 'Create');
    });

    test('should have Update value', () {
      expect(WPMetaDataActionType.Update, isNotNull);
      expect(WPMetaDataActionType.Update.name, 'Update');
    });

    test('should have Delete value', () {
      expect(WPMetaDataActionType.Delete, isNotNull);
      expect(WPMetaDataActionType.Delete.name, 'Delete');
    });

    test('should have exactly 3 values', () {
      expect(WPMetaDataActionType.values, hasLength(3));
    });

    test('values should be in expected order', () {
      expect(WPMetaDataActionType.values[0], WPMetaDataActionType.Create);
      expect(WPMetaDataActionType.values[1], WPMetaDataActionType.Update);
      expect(WPMetaDataActionType.values[2], WPMetaDataActionType.Delete);
    });

    test('should be usable in switch statements', () {
      String getAction(WPMetaDataActionType type) {
        switch (type) {
          case WPMetaDataActionType.Create:
            return 'create';
          case WPMetaDataActionType.Update:
            return 'update';
          case WPMetaDataActionType.Delete:
            return 'delete';
        }
      }

      expect(getAction(WPMetaDataActionType.Create), 'create');
      expect(getAction(WPMetaDataActionType.Update), 'update');
      expect(getAction(WPMetaDataActionType.Delete), 'delete');
    });
  });

  group('WPRouteType', () {
    test('should have all WordPress user route types', () {
      expect(WPRouteType.UserLogin, isNotNull);
      expect(WPRouteType.UserRegister, isNotNull);
      expect(WPRouteType.UserInfo, isNotNull);
      expect(WPRouteType.UserUpdateInfo, isNotNull);
      expect(WPRouteType.UserUpdatePassword, isNotNull);
      expect(WPRouteType.UserAddRole, isNotNull);
      expect(WPRouteType.UserRemoveRole, isNotNull);
      expect(WPRouteType.UserDelete, isNotNull);
    });

    test('should have authentication route types', () {
      expect(WPRouteType.AuthNonce, isNotNull);
      expect(WPRouteType.AuthVerify, isNotNull);
    });

    test('should have WooCommerce route types', () {
      expect(WPRouteType.WCCustomerInfo, isNotNull);
      expect(WPRouteType.WCCustomerUpdateInfo, isNotNull);
      expect(WPRouteType.WCPointsAndRewardsUser, isNotNull);
      expect(WPRouteType.WCPointsAndRewardsCalculatePoints, isNotNull);
    });

    test('should have exactly 14 values', () {
      expect(WPRouteType.values, hasLength(14));
    });

    test('should be usable in switch statements for routing', () {
      String getRoutePath(WPRouteType type) {
        switch (type) {
          case WPRouteType.UserLogin:
            return '/user/login';
          case WPRouteType.UserRegister:
            return '/user/register';
          case WPRouteType.UserInfo:
            return '/user/info';
          case WPRouteType.UserUpdateInfo:
            return '/update/user/info';
          case WPRouteType.UserUpdatePassword:
            return '/update/user/password';
          case WPRouteType.UserAddRole:
            return '/update/user/role/add';
          case WPRouteType.UserRemoveRole:
            return '/update/user/role/remove';
          case WPRouteType.UserDelete:
            return '/user/delete';
          case WPRouteType.AuthNonce:
            return '/auth/nonce';
          case WPRouteType.AuthVerify:
            return '/auth/verify';
          case WPRouteType.WCCustomerInfo:
            return '/wc/user/info';
          case WPRouteType.WCCustomerUpdateInfo:
            return '/wc/update/user/info';
          case WPRouteType.WCPointsAndRewardsUser:
            return '/wc-points-and-rewards/user';
          case WPRouteType.WCPointsAndRewardsCalculatePoints:
            return '/wc-points-and-rewards/calculate_points';
        }
      }

      expect(getRoutePath(WPRouteType.UserLogin), '/user/login');
      expect(getRoutePath(WPRouteType.AuthNonce), '/auth/nonce');
      expect(getRoutePath(WPRouteType.WCCustomerInfo), '/wc/user/info');
    });

    test('should categorize WordPress vs WooCommerce routes', () {
      final wpRoutes = [
        WPRouteType.UserLogin,
        WPRouteType.UserRegister,
        WPRouteType.UserInfo,
        WPRouteType.UserUpdateInfo,
        WPRouteType.UserUpdatePassword,
        WPRouteType.UserAddRole,
        WPRouteType.UserRemoveRole,
        WPRouteType.UserDelete,
        WPRouteType.AuthNonce,
        WPRouteType.AuthVerify,
      ];

      final wcRoutes = [
        WPRouteType.WCCustomerInfo,
        WPRouteType.WCCustomerUpdateInfo,
        WPRouteType.WCPointsAndRewardsUser,
        WPRouteType.WCPointsAndRewardsCalculatePoints,
      ];

      expect(wpRoutes, hasLength(10));
      expect(wcRoutes, hasLength(4));
    });

    test('should be comparable', () {
      expect(WPRouteType.UserLogin == WPRouteType.UserLogin, true);
      expect(WPRouteType.UserLogin == WPRouteType.UserRegister, false);
    });

    test('should have correct names', () {
      expect(WPRouteType.UserUpdatePassword.name, 'UserUpdatePassword');
      expect(WPRouteType.WCPointsAndRewardsCalculatePoints.name,
          'WCPointsAndRewardsCalculatePoints');
    });
  });

  group('Enum index access', () {
    test('should access WPAuthType by index', () {
      expect(WPAuthType.values[0], WPAuthType.WpEmail);
      expect(WPAuthType.values[1], WPAuthType.WpUsername);
    });

    test('should access WPMetaDataActionType by index', () {
      expect(WPMetaDataActionType.values[0], WPMetaDataActionType.Create);
      expect(WPMetaDataActionType.values[1], WPMetaDataActionType.Update);
      expect(WPMetaDataActionType.values[2], WPMetaDataActionType.Delete);
    });

    test('should get index from enum value', () {
      expect(WPAuthType.WpEmail.index, 0);
      expect(WPAuthType.WpUsername.index, 1);

      expect(WPMetaDataActionType.Create.index, 0);
      expect(WPMetaDataActionType.Update.index, 1);
      expect(WPMetaDataActionType.Delete.index, 2);
    });
  });
}
