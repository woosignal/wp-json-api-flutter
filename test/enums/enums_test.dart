import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/enums/wp_meta_data_action_type.dart';
import 'package:wp_json_api/enums/wp_route_type.dart';

void main() {
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
      expect(WPRouteType.UserLogout, isNotNull);
      expect(WPRouteType.UserInfo, isNotNull);
      expect(WPRouteType.UserUpdateInfo, isNotNull);
      expect(WPRouteType.UserUpdatePassword, isNotNull);
      expect(WPRouteType.UserDelete, isNotNull);
    });

    test('should not have v3 nonce or role route types', () {
      final List<String> names = WPRouteType.values.map((e) => e.name).toList();

      expect(names, isNot(contains('AuthNonce')));
      expect(names, isNot(contains('AuthVerify')));
      expect(names, isNot(contains('UserAddRole')));
      expect(names, isNot(contains('UserRemoveRole')));
    });

    test('should have WooCommerce route types', () {
      expect(WPRouteType.WCCustomerInfo, isNotNull);
      expect(WPRouteType.WCCustomerUpdateInfo, isNotNull);
      expect(WPRouteType.WCPointsAndRewardsUser, isNotNull);
      expect(WPRouteType.WCPointsAndRewardsCalculatePoints, isNotNull);
    });

    test('should have exactly 11 values', () {
      expect(WPRouteType.values, hasLength(11));
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
    test('should access WPMetaDataActionType by index', () {
      expect(WPMetaDataActionType.values[0], WPMetaDataActionType.Create);
      expect(WPMetaDataActionType.values[1], WPMetaDataActionType.Update);
      expect(WPMetaDataActionType.values[2], WPMetaDataActionType.Delete);
    });

    test('should get index from enum value', () {
      expect(WPMetaDataActionType.Create.index, 0);
      expect(WPMetaDataActionType.Update.index, 1);
      expect(WPMetaDataActionType.Delete.index, 2);
    });
  });
}
