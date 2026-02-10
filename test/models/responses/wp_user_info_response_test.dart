import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';

void main() {
  group('WPUserInfoResponse', () {
    group('fromJson', () {
      test('should parse complete response with metadata', () {
        final json = {
          'data': {
            'id': 123,
            'first_name': 'John',
            'last_name': 'Doe',
            'username': 'johndoe',
            'user_nicename': 'john-doe',
            'display_name': 'John Doe',
            'user_status': '0',
            'email': 'john@example.com',
            'avatar': 'https://example.com/avatar.png',
            'roles': ['subscriber', 'customer'],
            'meta_data': {
              'phone': ['1234567890'],
              'address': ['123 Main St', '456 Oak Ave'],
            },
            'created_at': '2024-01-01 00:00:00',
          },
          'message': 'User info retrieved',
          'status': 200,
        };

        final response = WPUserInfoResponse.fromJson(json);

        expect(response.status, 200);
        expect(response.message, 'User info retrieved');
        expect(response.data, isNotNull);
        expect(response.data!.id, 123);
        expect(response.data!.firstName, 'John');
        expect(response.data!.lastName, 'Doe');
        expect(response.data!.username, 'johndoe');
        expect(response.data!.userNicename, 'john-doe');
        expect(response.data!.displayName, 'John Doe');
        expect(response.data!.userStatus, '0');
        expect(response.data!.email, 'john@example.com');
        expect(response.data!.avatar, 'https://example.com/avatar.png');
        expect(response.data!.roles, ['subscriber', 'customer']);
        expect(response.data!.metaData, isNotNull);
        expect(response.data!.metaData!.length, 2);
        expect(response.data!.createdAt, '2024-01-01 00:00:00');
      });

      test('should handle empty metadata', () {
        final json = {
          'data': {
            'id': 456,
            'email': 'test@example.com',
            'meta_data': {},
          },
          'message': 'Success',
          'status': 200,
        };

        final response = WPUserInfoResponse.fromJson(json);

        expect(response.data!.id, 456);
        expect(response.data!.metaData, isNull);
      });

      test('should handle null metadata', () {
        final json = {
          'data': {
            'id': 789,
            'email': 'nullmeta@example.com',
          },
          'message': 'Success',
          'status': 200,
        };

        final response = WPUserInfoResponse.fromJson(json);

        expect(response.data!.id, 789);
        expect(response.data!.metaData, isNull);
      });

      test('should parse roles correctly', () {
        final json = {
          'data': {
            'id': 100,
            'roles': ['administrator', 'editor', 'author'],
          },
          'status': 200,
        };

        final response = WPUserInfoResponse.fromJson(json);

        expect(response.data!.roles, hasLength(3));
        expect(response.data!.roles, contains('administrator'));
        expect(response.data!.roles, contains('editor'));
        expect(response.data!.roles, contains('author'));
      });

      test('should handle empty roles', () {
        final json = {
          'data': {
            'id': 100,
            'roles': null,
          },
          'status': 200,
        };

        final response = WPUserInfoResponse.fromJson(json);

        expect(response.data!.roles, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize all fields', () {
        final response = WPUserInfoResponse(
          data: Data(
            id: 123,
            firstName: 'Jane',
            lastName: 'Smith',
            username: 'janesmith',
            userNicename: 'jane-smith',
            displayName: 'Jane Smith',
            userStatus: '1',
            email: 'jane@example.com',
            avatar: 'https://example.com/jane.png',
            roles: ['subscriber'],
            createdAt: '2024-02-01 00:00:00',
          ),
          message: 'Serialized',
          status: 200,
        );

        final json = response.toJson();

        expect(json['status'], 200);
        expect(json['data']['id'], 123);
        expect(json['data']['first_name'], 'Jane');
        expect(json['data']['last_name'], 'Smith');
        expect(json['data']['username'], 'janesmith');
        expect(json['data']['display_name'], 'Jane Smith');
        expect(json['data']['roles'], ['subscriber']);
      });
    });

    group('Data helper methods', () {
      late Data dataWithMeta;

      setUp(() {
        dataWithMeta = Data.fromJson({
          'id': 1,
          'meta_data': {
            'billing_phone': ['555-1234'],
            'shipping_address': ['123 Main St', '456 Oak Ave'],
            'preferences': ['email_notifications', 'sms_alerts'],
            'empty_key': [],
          },
        });
      });

      group('getMetaDataArrayWhere', () {
        test('should return array for existing key', () {
          final result = dataWithMeta.getMetaDataArrayWhere('shipping_address');

          expect(result, isNotNull);
          expect(result, hasLength(2));
          expect(result, contains('123 Main St'));
          expect(result, contains('456 Oak Ave'));
        });

        test('should return null for non-existing key', () {
          final result = dataWithMeta.getMetaDataArrayWhere('non_existing');

          expect(result, isNull);
        });

        test('should return null when metaData is null', () {
          final dataNoMeta = Data(id: 1);

          final result = dataNoMeta.getMetaDataArrayWhere('any_key');

          expect(result, isNull);
        });

        test('should return single item array', () {
          final result = dataWithMeta.getMetaDataArrayWhere('billing_phone');

          expect(result, isNotNull);
          expect(result, hasLength(1));
          expect(result!.first, '555-1234');
        });
      });

      group('getMetaDataFirstWhere', () {
        test('should return first value for existing key', () {
          final result = dataWithMeta.getMetaDataFirstWhere('shipping_address');

          expect(result, '123 Main St');
        });

        test('should return null for non-existing key', () {
          final result = dataWithMeta.getMetaDataFirstWhere('non_existing');

          expect(result, isNull);
        });

        test('should return null when metaData is null', () {
          final dataNoMeta = Data(id: 1);

          final result = dataNoMeta.getMetaDataFirstWhere('any_key');

          expect(result, isNull);
        });

        test('should return null for empty array value', () {
          final result = dataWithMeta.getMetaDataFirstWhere('empty_key');

          expect(result, isNull);
        });

        test('should return single value', () {
          final result = dataWithMeta.getMetaDataFirstWhere('billing_phone');

          expect(result, '555-1234');
        });
      });
    });
  });

  group('MetaData', () {
    test('should construct from key and value', () {
      final metaData = MetaData.fromJson('test_key', ['value1', 'value2']);

      expect(metaData.key, 'test_key');
      expect(metaData.value, ['value1', 'value2']);
    });

    test('should serialize to json', () {
      final metaData = MetaData(key: 'my_key', value: ['a', 'b', 'c']);

      final json = metaData.toJson();

      expect(json['my_key'], ['a', 'b', 'c']);
    });

    test('should handle null key in toJson', () {
      final metaData = MetaData(key: null, value: ['value']);

      final json = metaData.toJson();

      expect(json.isEmpty, true);
    });
  });
}
