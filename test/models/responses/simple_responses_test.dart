import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wp_nonce_response.dart';
import 'package:wp_json_api/models/responses/wp_nonce_verified_response.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/models/responses/wp_user_add_role_response.dart';
import 'package:wp_json_api/models/responses/wp_user_remove_role_response.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/models/responses/wp_user_reset_password_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_user.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_calculate_points.dart';

void main() {
  group('WPNonceResponse', () {
    test('should parse complete response', () {
      final json = {
        'data': {
          'nonce': 'abc123nonce',
          'root': 'https://example.com/wp-json',
          'expiry': 86400,
        },
        'message': 'Nonce generated',
        'status': 200,
      };

      final response = WPNonceResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'Nonce generated');
      expect(response.data!.nonce, 'abc123nonce');
      expect(response.data!.root, 'https://example.com/wp-json');
      expect(response.data!.expiry, 86400);
    });

    test('should handle null data', () {
      final json = {
        'data': null,
        'message': 'Error',
        'status': 500,
      };

      final response = WPNonceResponse.fromJson(json);

      expect(response.data, isNull);
      expect(response.status, 500);
    });

    test('should serialize correctly', () {
      final response = WPNonceResponse(
        data: WPNonceResponse.fromJson({
          'data': {
            'nonce': 'test_nonce',
            'root': 'http://test.com',
            'expiry': 3600
          }
        }).data,
        message: 'OK',
        status: 200,
      );

      final json = response.toJson();

      expect(json['data']['nonce'], 'test_nonce');
      expect(json['status'], 200);
    });
  });

  group('WPNonceVerifiedResponse', () {
    test('should parse valid nonce response', () {
      final json = {
        'data': {'is_valid': true},
        'message': 'Nonce is valid',
        'status': 200,
      };

      final response = WPNonceVerifiedResponse.fromJson(json);

      expect(response.data!.isValid, true);
      expect(response.status, 200);
    });

    test('should parse invalid nonce response', () {
      final json = {
        'data': {'is_valid': false},
        'message': 'Nonce expired',
        'status': 200,
      };

      final response = WPNonceVerifiedResponse.fromJson(json);

      expect(response.data!.isValid, false);
    });

    test('should serialize correctly', () {
      final response = WPNonceVerifiedResponse(
        data: WPNonceVerifiedResponse.fromJson({
          'data': {'is_valid': true}
        }).data,
        message: 'Valid',
        status: 200,
      );

      final json = response.toJson();

      expect(json['data']['is_valid'], true);
    });
  });

  group('WPUserRegisterResponse', () {
    test('should parse complete response', () {
      final json = {
        'data': {
          'user_id': 456,
          'user_token': 'register_token',
          'expiry': 2592000,
          'email': 'newuser@example.com',
          'username': 'newuser',
          'first_name': 'New',
          'last_name': 'User',
          'avatar': 'https://example.com/avatar.png',
          'created_at': '2024-01-01 00:00:00',
        },
        'message': 'User registered successfully',
        'status': 200,
      };

      final response = WPUserRegisterResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.data!.userId, 456);
      expect(response.data!.userToken, 'register_token');
      expect(response.data!.email, 'newuser@example.com');
      expect(response.data!.username, 'newuser');
    });

    test('should handle minimal data', () {
      final json = {
        'data': {
          'user_id': 789,
          'user_token': 'minimal_token',
        },
        'status': 200,
      };

      final response = WPUserRegisterResponse.fromJson(json);

      expect(response.data!.userId, 789);
      expect(response.data!.email, isNull);
      expect(response.data!.firstName, isNull);
    });
  });

  group('WPUserAddRoleResponse', () {
    test('should parse response with data array', () {
      final json = {
        'data': ['subscriber', 'customer'],
        'message': 'Role added',
        'status': 200,
      };

      final response = WPUserAddRoleResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'Role added');
      expect(response.data, ['subscriber', 'customer']);
    });

    test('should handle null data', () {
      final json = {
        'data': null,
        'message': 'Error',
        'status': 400,
      };

      final response = WPUserAddRoleResponse.fromJson(json);

      expect(response.data, isNull);
      expect(response.status, 400);
    });

    test('should serialize correctly', () {
      final response = WPUserAddRoleResponse(
        data: ['admin', 'editor'],
        message: 'OK',
        status: 200,
      );

      final json = response.toJson();

      expect(json['data'], ['admin', 'editor']);
    });
  });

  group('WPUserRemoveRoleResponse', () {
    test('should parse response with remaining roles', () {
      final json = {
        'data': ['subscriber'],
        'message': 'Role removed',
        'status': 200,
      };

      final response = WPUserRemoveRoleResponse.fromJson(json);

      expect(response.data, ['subscriber']);
      expect(response.message, 'Role removed');
    });
  });

  group('WPUserDeleteResponse', () {
    test('should parse successful delete response', () {
      final json = {
        'data': [],
        'message': 'User deleted successfully',
        'status': 200,
      };

      final response = WPUserDeleteResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'User deleted successfully');
    });

    test('should handle error response', () {
      final json = {
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
      final json = {
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

      final json = response.toJson();

      expect(json['message'], 'Reset complete');
      expect(json['status'], 200);
    });
  });

  group('WPUserInfoUpdatedResponse', () {
    test('should parse update response', () {
      final json = {
        'message': 'User info updated',
        'status': 200,
      };

      final response = WPUserInfoUpdatedResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'User info updated');
    });

    test('should serialize correctly', () {
      final response = WPUserInfoUpdatedResponse(
        message: 'Updated',
        status: 200,
      );

      final json = response.toJson();

      expect(json['message'], 'Updated');
      expect(json['status'], 200);
      expect(json.containsKey('data'), false);
    });
  });

  group('WCCustomerUpdatedResponse', () {
    test('should parse update response', () {
      final json = {
        'data': ['first_name', 'last_name', 'billing'],
        'message': 'Customer updated',
        'status': 200,
      };

      final response = WCCustomerUpdatedResponse.fromJson(json);

      expect(response.status, 200);
      expect(response.message, 'Customer updated');
      expect(response.data, hasLength(3));
    });

    test('should handle empty data', () {
      final json = {
        'data': [],
        'message': 'No changes',
        'status': 200,
      };

      final response = WCCustomerUpdatedResponse.fromJson(json);

      expect(response.data, isEmpty);
    });
  });

  group('WcPointsAndRewardUser', () {
    test('should parse points response', () {
      final json = {
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
      final json = {
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

      final json = response.toJson();

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

      final json = response.toJson();

      expect(json['value'], '\$75.00');
    });
  });
}
