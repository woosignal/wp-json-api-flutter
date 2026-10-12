import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/models/responses/wp_user_reset_password_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_user.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_calculate_points.dart';

void main() {
  group('WPUserRegisterResponse', () {
    test('should parse the v4 Auth object', () {
      final Map<String, Object> json = {
        'data': {
          'token': 'register_token',
          'expires_at': 1767225600,
          'user': {
            'id': 456,
            'email': 'newuser@example.com',
            'username': 'newuser',
            'first_name': 'New',
            'last_name': 'User',
            'roles': ['customer'],
            'meta_data': {
              'billing_phone': ['555-1234'],
            },
          },
        },
        'message': '',
        'status': 201,
      };

      final response = WPUserRegisterResponse.fromJson(json);

      expect(response.status, 201);
      expect(response.data!.token, 'register_token');
      expect(response.data!.expiresAt, 1767225600);
      expect(response.data!.user!.id, 456);
      expect(response.data!.user!.email, 'newuser@example.com');
      expect(response.data!.user!.username, 'newuser');
      expect(response.data!.user!.getMetaDataFirstWhere('billing_phone'),
          '555-1234');
    });

    test('should handle minimal data', () {
      final Map<String, Object> json = {
        'data': {
          'token': 'minimal_token',
        },
        'status': 201,
      };

      final response = WPUserRegisterResponse.fromJson(json);

      expect(response.data!.token, 'minimal_token');
      expect(response.data!.expiresAt, isNull);
      expect(response.data!.user, isNull);
    });
  });

  group('WPUserDeleteResponse', () {
    test('should parse successful delete response', () {
      final Map<String, Object> json = {
        'data': [],
        'message': 'User deleted successfully',
        'status': 200,
      };

      final response = WPUserDeleteResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'User deleted successfully');
    });

    test('should handle error response', () {
      final Map<String, Object?> json = {
        'data': null,
        'message': 'Cannot delete user',
        'status': 403,
      };

      final response = WPUserDeleteResponse.fromJson(json);

      expect(response.status, 403);
      expect(response.data, isNull);
    });
  });

  group('WPUserResetPasswordResponse', () {
    test('should parse successful password reset', () {
      final Map<String, Object> json = {
        'data': [],
        'message': 'Password updated',
        'status': 200,
      };

      final response = WPUserResetPasswordResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'Password updated');
    });

    test('should serialize correctly', () {
      final response = WPUserResetPasswordResponse(
        data: [],
        message: 'Reset complete',
        status: 200,
      );

      final Map<String, dynamic> json = response.toJson();

      expect(json['message'], 'Reset complete');
      expect(json['status'], 200);
    });
  });

  group('WPUserInfoUpdatedResponse', () {
    test('should parse the updated user', () {
      final Map<String, Object> json = {
        'data': {
          'id': 12,
          'first_name': 'Luke',
          'display_name': 'Luke S',
          'meta_data': {
            'billing_city': ['Mos Eisley'],
          },
        },
        'message': '',
        'status': 200,
      };

      final response = WPUserInfoUpdatedResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.data!.id, 12);
      expect(response.data!.firstName, 'Luke');
      expect(response.data!.displayName, 'Luke S');
      expect(
          response.data!.getMetaDataFirstWhere('billing_city'), 'Mos Eisley');
    });

    test('should serialize correctly', () {
      final response = WPUserInfoUpdatedResponse(
        message: 'Updated',
        status: 200,
      );

      final Map<String, dynamic> json = response.toJson();

      expect(json['message'], 'Updated');
      expect(json['status'], 200);
      expect(json.containsKey('data'), false);
    });
  });

  group('WCCustomerUpdatedResponse', () {
    test('should parse the updated customer', () {
      final Map<String, Object> json = {
        'data': {
          'id': 12,
          'first_name': 'Luke',
          'billing': {'city': 'Mos Eisley', 'phone': '555-1234'},
          'shipping': {'city': 'Tatooine', 'phone': '555-9876'},
          'meta_data': {},
        },
        'message': '',
        'status': 200,
      };

      final response = WCCustomerUpdatedResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.data!.id, 12);
      expect(response.data!.firstName, 'Luke');
      expect(response.data!.billing!.city, 'Mos Eisley');
      expect(response.data!.shipping!.phone, '555-9876');
      expect(response.data!.metaData, isNull);
    });

    test('should handle missing data', () {
      final Map<String, Object> json = {
        'message': 'No changes',
        'status': 200,
      };

      final response = WCCustomerUpdatedResponse.fromJson(json);

      expect(response.data, isNull);
    });
  });

  group('WcPointsAndRewardUser', () {
    test('should parse points response', () {
      final Map<String, Object> json = {
        'id': 123,
        'points': 5000,
        'value': '\$50.00',
      };

      final response = WcPointsAndRewardUser.fromJson(json);

      expect(response.id, 123);
      expect(response.points, 5000);
      expect(response.value, '\$50.00');
    });

    test('should handle zero points', () {
      final Map<String, Object> json = {
        'id': 456,
        'points': 0,
        'value': '\$0.00',
      };

      final response = WcPointsAndRewardUser.fromJson(json);

      expect(response.points, 0);
      expect(response.value, '\$0.00');
    });

    test('should serialize correctly', () {
      final response = WcPointsAndRewardUser(
        id: 789,
        points: 10000,
        value: '\$100.00',
      );

      final Map<String, dynamic> json = response.toJson();

      expect(json['id'], 789);
      expect(json['points'], 10000);
      expect(json['value'], '\$100.00');
    });
  });

  group('WcPointsAndRewardCalculatePoints', () {
    test('should parse calculation response', () {
      final json = {
        'value': '\$25.00',
      };

      final response = WcPointsAndRewardCalculatePoints.fromJson(json);

      expect(response.value, '\$25.00');
    });

    test('should handle null value', () {
      final json = <String, dynamic>{};

      final response = WcPointsAndRewardCalculatePoints.fromJson(json);

      expect(response.value, isNull);
    });

    test('should serialize correctly', () {
      final response = WcPointsAndRewardCalculatePoints(value: '\$75.00');

      final Map<String, dynamic> json = response.toJson();

      expect(json['value'], '\$75.00');
    });
  });
}
