import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';

void main() {
  group('WpUser', () {
    group('fromJson', () {
      test('should parse all fields correctly', () {
        final json = {
          'id': 123,
          'token': 'test_token_abc123',
          'email': 'test@example.com',
          'username': 'testuser',
          'first_name': 'John',
          'last_name': 'Doe',
          'avatar': 'https://example.com/avatar.png',
          'created_at': '2024-01-01 12:00:00',
        };

        final wpUser = WpUser.fromJson(json);

        expect(wpUser.id, 123);
        expect(wpUser.token, 'test_token_abc123');
        expect(wpUser.email, 'test@example.com');
        expect(wpUser.username, 'testuser');
        expect(wpUser.firstName, 'John');
        expect(wpUser.lastName, 'Doe');
        expect(wpUser.avatar, 'https://example.com/avatar.png');
        expect(wpUser.createdAt, '2024-01-01 12:00:00');
      });

      test('should handle null values', () {
        final json = <String, dynamic>{};

        final wpUser = WpUser.fromJson(json);

        expect(wpUser.id, isNull);
        expect(wpUser.token, isNull);
        expect(wpUser.email, isNull);
        expect(wpUser.username, isNull);
        expect(wpUser.firstName, isNull);
        expect(wpUser.lastName, isNull);
        expect(wpUser.avatar, isNull);
        expect(wpUser.createdAt, isNull);
      });

      test('should handle partial data', () {
        final json = {
          'id': 456,
          'email': 'partial@example.com',
        };

        final wpUser = WpUser.fromJson(json);

        expect(wpUser.id, 456);
        expect(wpUser.email, 'partial@example.com');
        expect(wpUser.token, isNull);
        expect(wpUser.username, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final wpUser = WpUser(
          id: 123,
          token: 'test_token_abc123',
          email: 'test@example.com',
          username: 'testuser',
          firstName: 'John',
          lastName: 'Doe',
          avatar: 'https://example.com/avatar.png',
          createdAt: '2024-01-01 12:00:00',
        );

        final json = wpUser.toJson();

        expect(json['id'], 123);
        expect(json['token'], 'test_token_abc123');
        expect(json['email'], 'test@example.com');
        expect(json['username'], 'testuser');
        expect(json['first_name'], 'John');
        expect(json['last_name'], 'Doe');
        expect(json['avatar'], 'https://example.com/avatar.png');
        expect(json['created_at'], '2024-01-01 12:00:00');
      });

      test('should include null values', () {
        final wpUser = WpUser();

        final json = wpUser.toJson();

        expect(json.containsKey('id'), true);
        expect(json.containsKey('token'), true);
        expect(json['id'], isNull);
        expect(json['token'], isNull);
      });
    });

    group('fromJson/toJson roundtrip', () {
      test('should preserve data through serialization cycle', () {
        final originalJson = {
          'id': 789,
          'token': 'roundtrip_token',
          'email': 'roundtrip@example.com',
          'username': 'roundtripuser',
          'first_name': 'Jane',
          'last_name': 'Smith',
          'avatar': 'https://example.com/jane.png',
          'created_at': '2024-06-15 10:30:00',
        };

        final wpUser = WpUser.fromJson(originalJson);
        final serializedJson = wpUser.toJson();

        expect(serializedJson['id'], originalJson['id']);
        expect(serializedJson['token'], originalJson['token']);
        expect(serializedJson['email'], originalJson['email']);
        expect(serializedJson['username'], originalJson['username']);
        expect(serializedJson['first_name'], originalJson['first_name']);
        expect(serializedJson['last_name'], originalJson['last_name']);
        expect(serializedJson['avatar'], originalJson['avatar']);
        expect(serializedJson['created_at'], originalJson['created_at']);
      });
    });

    group('fromWPUserLoginResponse', () {
      test('should construct from login response', () {
        final loginResponse = WPUserLoginResponse(
          data: WPUserLoginResponse.fromJson({
            'data': {
              'user_id': 100,
              'user_token': 'login_token_123',
              'email': 'login@example.com',
              'username': 'loginuser',
              'first_name': 'Login',
              'last_name': 'User',
              'avatar': 'https://example.com/login.png',
              'created_at': '2024-02-20 08:00:00',
            }
          }).data,
          message: 'Success',
          status: 200,
        );

        final wpUser = WpUser.fromWPUserLoginResponse(loginResponse);

        expect(wpUser.id, 100);
        expect(wpUser.token, 'login_token_123');
        expect(wpUser.email, 'login@example.com');
        expect(wpUser.username, 'loginuser');
        expect(wpUser.firstName, 'Login');
        expect(wpUser.lastName, 'User');
      });

      test('should handle null data in login response', () {
        final loginResponse = WPUserLoginResponse(
          data: null,
          message: 'Error',
          status: 500,
        );

        final wpUser = WpUser.fromWPUserLoginResponse(loginResponse);

        expect(wpUser.id, isNull);
        expect(wpUser.token, isNull);
        expect(wpUser.email, isNull);
      });
    });

    group('fromWPUserRegisterResponse', () {
      test('should construct from register response', () {
        final registerResponse = WPUserRegisterResponse(
          data: WPUserRegisterResponse.fromJson({
            'data': {
              'user_id': 200,
              'user_token': 'register_token_456',
              'email': 'register@example.com',
              'username': 'registeruser',
              'first_name': 'Register',
              'last_name': 'User',
              'avatar': 'https://example.com/register.png',
              'created_at': '2024-03-10 14:00:00',
            }
          }).data,
          message: 'Registered successfully',
          status: 200,
        );

        final wpUser = WpUser.fromWPUserRegisterResponse(registerResponse);

        expect(wpUser.id, 200);
        expect(wpUser.token, 'register_token_456');
        expect(wpUser.email, 'register@example.com');
        expect(wpUser.username, 'registeruser');
        expect(wpUser.firstName, 'Register');
        expect(wpUser.lastName, 'User');
      });
    });

    group('constructor', () {
      test('should create instance with named parameters', () {
        final wpUser = WpUser(
          id: 999,
          token: 'constructor_token',
          email: 'constructor@example.com',
          username: 'constructoruser',
          firstName: 'Constructor',
          lastName: 'Test',
          avatar: 'https://example.com/constructor.png',
          createdAt: '2024-04-01 00:00:00',
        );

        expect(wpUser.id, 999);
        expect(wpUser.token, 'constructor_token');
        expect(wpUser.email, 'constructor@example.com');
        expect(wpUser.username, 'constructoruser');
        expect(wpUser.firstName, 'Constructor');
        expect(wpUser.lastName, 'Test');
        expect(wpUser.avatar, 'https://example.com/constructor.png');
        expect(wpUser.createdAt, '2024-04-01 00:00:00');
      });

      test('should create empty instance', () {
        final wpUser = WpUser();

        expect(wpUser.id, isNull);
        expect(wpUser.token, isNull);
        expect(wpUser.email, isNull);
      });
    });
  });
}
