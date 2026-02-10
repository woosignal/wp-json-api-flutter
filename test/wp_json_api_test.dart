import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/networking/network_manager.dart';

void main() {
  group('WPJsonAPI', () {
    group('Singleton', () {
      test('should return same instance', () {
        final instance1 = WPJsonAPI.instance;
        final instance2 = WPJsonAPI.instance;

        expect(identical(instance1, instance2), true);
      });
    });

    group('version', () {
      test('should return current version', () {
        expect(WPJsonAPI.version, isNotEmpty);
        expect(WPJsonAPI.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      });
    });

    group('storageKey', () {
      test('should return consistent storage key', () {
        expect(WPJsonAPI.storageKey(), 'wp_json_api');
      });

      test('should return same key on multiple calls', () {
        final key1 = WPJsonAPI.storageKey();
        final key2 = WPJsonAPI.storageKey();

        expect(key1, key2);
      });
    });

    group('init', () {
      test('should initialize with required parameters', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://example.com',
        );

        expect(WPJsonAPI.instance.getBaseApi(), 'https://example.com/wp-json');
      });

      test('should use custom wpJsonPath', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://custom.example.com',
          wpJsonPath: '/custom-api',
        );

        expect(
          WPJsonAPI.instance.getBaseApi(),
          'https://custom.example.com/custom-api',
        );
      });

      test('should set debug mode', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://debug.example.com',
          shouldDebug: true,
        );

        expect(WPJsonAPI.instance.shouldDebug(), true);
      });

      test('should disable debug mode', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://nodebug.example.com',
          shouldDebug: false,
        );

        expect(WPJsonAPI.instance.shouldDebug(), false);
      });

      test('should use default wpJsonPath when not specified', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://default.example.com',
        );

        expect(
          WPJsonAPI.instance.getBaseApi(),
          'https://default.example.com/wp-json',
        );
      });
    });

    group('getBaseApi', () {
      test('should combine baseUrl and apiPath', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://mysite.com',
          wpJsonPath: '/wp-json',
        );

        expect(WPJsonAPI.instance.getBaseApi(), 'https://mysite.com/wp-json');
      });

      test('should handle baseUrl without trailing slash', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://noslash.com',
        );

        expect(WPJsonAPI.instance.getBaseApi(), 'https://noslash.com/wp-json');
      });
    });

    group('api', () {
      setUp(() async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://api-test.com',
        );
      });

      test('should return WPAppNetworkManager instance', () async {
        WPAppNetworkManager? networkManager;

        await WPJsonAPI.instance.api((request) async {
          networkManager = request;
          return null;
        });

        expect(networkManager, isNotNull);
        expect(networkManager, isA<WPAppNetworkManager>());
      });

      test('should return result from callback', () async {
        final result = await WPJsonAPI.instance.api((request) async {
          return 'test_result';
        });

        expect(result, 'test_result');
      });

      test('should pass same network manager instance', () async {
        WPAppNetworkManager? manager1;
        WPAppNetworkManager? manager2;

        await WPJsonAPI.instance.api((request) async {
          manager1 = request;
          return null;
        });

        await WPJsonAPI.instance.api((request) async {
          manager2 = request;
          return null;
        });

        expect(identical(manager1, manager2), true);
      });
    });

    group('shouldDebug', () {
      test('should return true when debug enabled', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://test.com',
          shouldDebug: true,
        );

        expect(WPJsonAPI.instance.shouldDebug(), true);
      });

      test('should return false when debug disabled', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://test.com',
          shouldDebug: false,
        );

        expect(WPJsonAPI.instance.shouldDebug(), false);
      });

      test('should default to true', () async {
        await WPJsonAPI.instance.init(
          baseUrl: 'https://test.com',
        );

        expect(WPJsonAPI.instance.shouldDebug(), true);
      });
    });
  });

  group('WpUser Model Integration', () {
    test('should create WpUser for storage', () {
      final wpUser = WpUser(
        id: 123,
        token: 'integration_token',
        email: 'integration@example.com',
        username: 'integrationuser',
        firstName: 'Integration',
        lastName: 'Test',
      );

      final json = wpUser.toJson();

      expect(json['id'], 123);
      expect(json['token'], 'integration_token');
      expect(json['email'], 'integration@example.com');
    });

    test('should restore WpUser from storage data', () {
      final storedJson = {
        'id': 456,
        'token': 'restored_token',
        'email': 'restored@example.com',
        'username': 'restoreduser',
        'first_name': 'Restored',
        'last_name': 'User',
        'avatar': 'https://example.com/avatar.png',
        'created_at': '2024-01-01 00:00:00',
      };

      final wpUser = WpUser.fromJson(storedJson);

      expect(wpUser.id, 456);
      expect(wpUser.token, 'restored_token');
      expect(wpUser.email, 'restored@example.com');
      expect(wpUser.firstName, 'Restored');
      expect(wpUser.lastName, 'User');
    });
  });
}
