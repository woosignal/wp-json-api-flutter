import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart'
    as user_info;
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';

void main() {
  final Map<String, Object> authJson = {
    'data': {
      'token': 'a' * 64,
      'expires_at': 1767225600,
      'user': {
        'id': 12,
        'username': 'luke',
        'email': 'luke@example.com',
        'first_name': 'Luke',
        'last_name': 'Skywalker',
        'display_name': 'Luke',
        'avatar': 'https://example.com/luke.png',
        'roles': ['customer'],
        'meta_data': {
          'billing_city': ['Mos Eisley'],
        },
        'created_at': '2026-10-12 15:00:00',
      },
    },
    'message': '',
    'status': 200,
  };

  group('WPUserLoginResponse', () {
    group('fromJson', () {
      test('should parse the v4 Auth object', () {
        final response = WPUserLoginResponse.fromJson(authJson);

        expect(response.status, 200);
        expect(response.message, '');
        expect(response.data, isNotNull);
        expect(response.data!.token, 'a' * 64);
        expect(response.data!.expiresAt, 1767225600);
        expect(response.data!.user, isNotNull);
        expect(response.data!.user!.id, 12);
        expect(response.data!.user!.username, 'luke');
        expect(response.data!.user!.email, 'luke@example.com');
        expect(response.data!.user!.firstName, 'Luke');
        expect(response.data!.user!.lastName, 'Skywalker');
        expect(response.data!.user!.displayName, 'Luke');
        expect(response.data!.user!.avatar, 'https://example.com/luke.png');
        expect(response.data!.user!.roles, ['customer']);
        expect(response.data!.user!.getMetaDataFirstWhere('billing_city'),
            'Mos Eisley');
        expect(response.data!.user!.createdAt, '2026-10-12 15:00:00');
      });

      test('should convert expires_at to a DateTime', () {
        final response = WPUserLoginResponse.fromJson(authJson);

        expect(
          response.data!.expiresAtDateTime,
          DateTime.fromMillisecondsSinceEpoch(1767225600 * 1000),
        );
      });

      test('should parse expires_at sent as a string', () {
        final response = WPUserLoginResponse.fromJson({
          'data': {'token': 'abc', 'expires_at': '1767225600'},
          'status': 200,
        });

        expect(response.data!.expiresAt, 1767225600);
      });

      test('should handle null data', () {
        final response = WPUserLoginResponse.fromJson({
          'data': null,
          'message': 'Error',
          'status': 500,
        });

        expect(response.data, isNull);
        expect(response.status, 500);
      });

      test('should handle missing user and expiry', () {
        final response = WPUserLoginResponse.fromJson({
          'data': {'token': 'abc'},
          'status': 200,
        });

        expect(response.data!.token, 'abc');
        expect(response.data!.expiresAt, isNull);
        expect(response.data!.expiresAtDateTime, isNull);
        expect(response.data!.user, isNull);
      });
    });

    group('toJson', () {
      test('should serialize the Auth object', () {
        final response = WPUserLoginResponse(
          data: Data(
            token: 'token_123',
            expiresAt: 1767225600,
            user: user_info.Data(id: 1, email: 'a@example.com'),
          ),
          message: 'Serialized',
          status: 200,
        );

        final Map<String, dynamic> json = response.toJson();

        expect(json['status'], 200);
        expect(json['message'], 'Serialized');
        expect(json['data']['token'], 'token_123');
        expect(json['data']['expires_at'], 1767225600);
        expect(json['data']['user']['id'], 1);
        expect(json['data']['user']['email'], 'a@example.com');
      });

      test('should not include data when null', () {
        final response = WPUserLoginResponse(message: 'x', status: 200);

        expect(response.toJson().containsKey('data'), false);
      });
    });

    group('fromJson/toJson roundtrip', () {
      test('should preserve data through serialization cycle', () {
        final response = WPUserLoginResponse.fromJson(authJson);
        final restored = WPUserLoginResponse.fromJson(response.toJson());

        expect(restored.data!.token, response.data!.token);
        expect(restored.data!.expiresAt, response.data!.expiresAt);
        expect(restored.data!.user!.id, 12);
        expect(restored.data!.user!.getMetaDataArrayWhere('billing_city'),
            ['Mos Eisley']);
      });
    });
  });
}
