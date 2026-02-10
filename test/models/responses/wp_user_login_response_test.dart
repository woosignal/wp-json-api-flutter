import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';

void main() {
  group('WPUserLoginResponse', () {
    group('fromJson', () {
      test('should parse complete response', () {
        final json = {
          'data': {
            'user_id': 123,
            'user_token': 'abc123token',
            'expiry': 1704067200,
            'email': 'test@example.com',
            'username': 'testuser',
            'first_name': 'John',
            'last_name': 'Doe',
            'avatar': 'https://example.com/avatar.png',
            'created_at': '2024-01-01 00:00:00',
          },
          'message': 'Login successful',
          'status': 200,
        };

        final response = WPUserLoginResponse.fromJson(json);

        expect(response.status, 200);
        expect(response.message, 'Login successful');
        expect(response.data, isNotNull);
        expect(response.data!.userId, 123);
        expect(response.data!.userToken, 'abc123token');
        expect(response.data!.expiry, 1704067200);
        expect(response.data!.email, 'test@example.com');
        expect(response.data!.username, 'testuser');
        expect(response.data!.firstName, 'John');
        expect(response.data!.lastName, 'Doe');
        expect(response.data!.avatar, 'https://example.com/avatar.png');
        expect(response.data!.createdAt, '2024-01-01 00:00:00');
      });

      test('should handle null data', () {
        final json = {
          'data': null,
          'message': 'Invalid credentials',
          'status': 401,
        };

        final response = WPUserLoginResponse.fromJson(json);

        expect(response.data, isNull);
        expect(response.message, 'Invalid credentials');
        expect(response.status, 401);
      });

      test('should handle missing optional fields in data', () {
        final json = {
          'data': {
            'user_id': 456,
            'user_token': 'token456',
          },
          'message': 'Success',
          'status': 200,
        };

        final response = WPUserLoginResponse.fromJson(json);

        expect(response.data!.userId, 456);
        expect(response.data!.userToken, 'token456');
        expect(response.data!.email, isNull);
        expect(response.data!.username, isNull);
        expect(response.data!.firstName, isNull);
        expect(response.data!.lastName, isNull);
      });
    });

    group('toJson', () {
      test('should serialize complete response', () {
        final response = WPUserLoginResponse(
          data: Data(
            userId: 789,
            userToken: 'serialized_token',
            expiry: 1704153600,
            email: 'serialize@example.com',
            username: 'serializeuser',
            firstName: 'Serialize',
            lastName: 'Test',
            avatar: 'https://example.com/serialize.png',
            createdAt: '2024-01-02 00:00:00',
          ),
          message: 'Serialized',
          status: 200,
        );

        final json = response.toJson();

        expect(json['status'], 200);
        expect(json['message'], 'Serialized');
        expect(json['data'], isNotNull);
        expect(json['data']['user_id'], 789);
        expect(json['data']['user_token'], 'serialized_token');
        expect(json['data']['email'], 'serialize@example.com');
      });

      test('should handle null data', () {
        final response = WPUserLoginResponse(
          data: null,
          message: 'No data',
          status: 400,
        );

        final json = response.toJson();

        expect(json.containsKey('data'), false);
        expect(json['message'], 'No data');
        expect(json['status'], 400);
      });
    });

    group('Data fromJson/toJson roundtrip', () {
      test('should preserve all fields through serialization', () {
        final originalJson = {
          'user_id': 111,
          'user_token': 'roundtrip_token',
          'expiry': 1704240000,
          'email': 'roundtrip@example.com',
          'username': 'roundtripuser',
          'first_name': 'Round',
          'last_name': 'Trip',
          'avatar': 'https://example.com/roundtrip.png',
          'created_at': '2024-01-03 00:00:00',
        };

        final data = Data.fromJson(originalJson);
        final serialized = data.toJson();

        expect(serialized['user_id'], originalJson['user_id']);
        expect(serialized['user_token'], originalJson['user_token']);
        expect(serialized['expiry'], originalJson['expiry']);
        expect(serialized['email'], originalJson['email']);
        expect(serialized['username'], originalJson['username']);
        expect(serialized['first_name'], originalJson['first_name']);
        expect(serialized['last_name'], originalJson['last_name']);
        expect(serialized['avatar'], originalJson['avatar']);
        expect(serialized['created_at'], originalJson['created_at']);
      });
    });

    group('constructor', () {
      test('should create response with named parameters', () {
        final response = WPUserLoginResponse(
          data: Data(userId: 100, userToken: 'test_token'),
          message: 'Test message',
          status: 200,
        );

        expect(response.data!.userId, 100);
        expect(response.data!.userToken, 'test_token');
        expect(response.message, 'Test message');
        expect(response.status, 200);
      });
    });
  });
}
