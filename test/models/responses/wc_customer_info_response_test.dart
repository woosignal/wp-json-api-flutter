import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';

void main() {
  group('WCCustomerInfoResponse', () {
    group('fromJson', () {
      test('should parse complete response with shipping and billing', () {
        final json = {
          'data': {
            'first_name': 'John',
            'last_name': 'Doe',
            'display_name': 'John Doe',
            'avatar': 'https://example.com/avatar.png',
            'shipping': {
              'first_name': 'John',
              'last_name': 'Doe',
              'company': 'Acme Corp',
              'address_1': '123 Main St',
              'address_2': 'Suite 100',
              'city': 'New York',
              'state': 'NY',
              'postcode': '10001',
              'country': 'US',
            },
            'billing': {
              'first_name': 'John',
              'last_name': 'Doe',
              'company': 'Acme Corp',
              'address_1': '456 Oak Ave',
              'address_2': 'Floor 2',
              'city': 'Los Angeles',
              'state': 'CA',
              'postcode': '90001',
              'country': 'US',
              'email': 'billing@example.com',
              'phone': '555-1234',
            },
            'meta_data': {
              'customer_type': ['premium'],
              'loyalty_points': ['1000'],
            },
          },
          'message': 'Customer info retrieved',
          'status': 200,
        };

        final response = WCCustomerInfoResponse.fromJson(json);

        expect(response.status, 200);
        expect(response.message, 'Customer info retrieved');
        expect(response.data, isNotNull);
        expect(response.data!.firstName, 'John');
        expect(response.data!.lastName, 'Doe');
        expect(response.data!.displayName, 'John Doe');
        expect(response.data!.avatar, 'https://example.com/avatar.png');

        // Shipping
        expect(response.data!.shipping, isNotNull);
        expect(response.data!.shipping!.firstName, 'John');
        expect(response.data!.shipping!.lastName, 'Doe');
        expect(response.data!.shipping!.company, 'Acme Corp');
        expect(response.data!.shipping!.address1, '123 Main St');
        expect(response.data!.shipping!.address2, 'Suite 100');
        expect(response.data!.shipping!.city, 'New York');
        expect(response.data!.shipping!.state, 'NY');
        expect(response.data!.shipping!.postcode, '10001');
        expect(response.data!.shipping!.country, 'US');

        // Billing
        expect(response.data!.billing, isNotNull);
        expect(response.data!.billing!.firstName, 'John');
        expect(response.data!.billing!.email, 'billing@example.com');
        expect(response.data!.billing!.phone, '555-1234');
        expect(response.data!.billing!.city, 'Los Angeles');
        expect(response.data!.billing!.state, 'CA');

        // Meta data
        expect(response.data!.metaData, isNotNull);
        expect(response.data!.metaData!.length, 2);
      });

      test('should handle null shipping and billing', () {
        final json = {
          'data': {
            'first_name': 'Jane',
            'last_name': 'Smith',
          },
          'message': 'Success',
          'status': 200,
        };

        final response = WCCustomerInfoResponse.fromJson(json);

        expect(response.data!.shipping, isNull);
        expect(response.data!.billing, isNull);
      });

      test('should handle null data', () {
        final json = {
          'data': null,
          'message': 'No customer found',
          'status': 404,
        };

        final response = WCCustomerInfoResponse.fromJson(json);

        expect(response.data, isNull);
        expect(response.status, 404);
      });
    });

    group('toJson', () {
      test('should serialize complete response', () {
        final response = WCCustomerInfoResponse(
          data: Data(
            firstName: 'Test',
            lastName: 'User',
            displayName: 'Test User',
            avatar: 'https://example.com/test.png',
            shipping: Shipping(
              firstName: 'Test',
              lastName: 'User',
              address1: '123 Test St',
              city: 'Test City',
              state: 'TS',
              postcode: '12345',
              country: 'US',
            ),
            billing: Billing(
              firstName: 'Test',
              lastName: 'User',
              address1: '456 Bill Ave',
              city: 'Bill City',
              email: 'test@example.com',
              phone: '555-0000',
            ),
          ),
          message: 'Serialized',
          status: 200,
        );

        final json = response.toJson();

        expect(json['status'], 200);
        expect(json['data']['first_name'], 'Test');
        expect(json['data']['shipping']['address_1'], '123 Test St');
        expect(json['data']['billing']['email'], 'test@example.com');
      });
    });

    group('Data helper methods', () {
      late Data dataWithMeta;

      setUp(() {
        dataWithMeta = Data.fromJson({
          'first_name': 'Helper',
          'meta_data': {
            'custom_field': ['value1', 'value2'],
            'single_value': ['only_one'],
            'empty_field': [],
          },
        });
      });

      group('getMetaDataArrayWhere', () {
        test('should return array for existing key', () {
          final result = dataWithMeta.getMetaDataArrayWhere('custom_field');

          expect(result, isNotNull);
          expect(result, hasLength(2));
          expect(result, contains('value1'));
        });

        test('should return null for non-existing key', () {
          final result = dataWithMeta.getMetaDataArrayWhere('non_existing');

          expect(result, isNull);
        });

        test('should return null when metaData is null', () {
          final dataNoMeta = Data(firstName: 'No Meta');

          final result = dataNoMeta.getMetaDataArrayWhere('any_key');

          expect(result, isNull);
        });
      });

      group('getMetaDataFirstWhere', () {
        test('should return first value', () {
          final result = dataWithMeta.getMetaDataFirstWhere('custom_field');

          expect(result, 'value1');
        });

        test('should return single value', () {
          final result = dataWithMeta.getMetaDataFirstWhere('single_value');

          expect(result, 'only_one');
        });

        test('should return null for empty array', () {
          final result = dataWithMeta.getMetaDataFirstWhere('empty_field');

          expect(result, isNull);
        });

        test('should return null for non-existing key', () {
          final result = dataWithMeta.getMetaDataFirstWhere('non_existing');

          expect(result, isNull);
        });
      });
    });
  });

  group('Shipping', () {
    test('should parse all fields', () {
      final json = {
        'first_name': 'Ship',
        'last_name': 'User',
        'company': 'Ship Co',
        'address_1': '100 Ship St',
        'address_2': 'Dock 5',
        'city': 'Ship City',
        'state': 'SC',
        'postcode': '54321',
        'country': 'US',
      };

      final shipping = Shipping.fromJson(json);

      expect(shipping.firstName, 'Ship');
      expect(shipping.lastName, 'User');
      expect(shipping.company, 'Ship Co');
      expect(shipping.address1, '100 Ship St');
      expect(shipping.address2, 'Dock 5');
      expect(shipping.city, 'Ship City');
      expect(shipping.state, 'SC');
      expect(shipping.postcode, '54321');
      expect(shipping.country, 'US');
    });

    test('should serialize correctly', () {
      final shipping = Shipping(
        firstName: 'Test',
        lastName: 'Ship',
        city: 'Test City',
        country: 'UK',
      );

      final json = shipping.toJson();

      expect(json['first_name'], 'Test');
      expect(json['last_name'], 'Ship');
      expect(json['city'], 'Test City');
      expect(json['country'], 'UK');
    });
  });

  group('Billing', () {
    test('should parse all fields including email and phone', () {
      final json = {
        'first_name': 'Bill',
        'last_name': 'User',
        'company': 'Bill Corp',
        'address_1': '200 Bill Ave',
        'address_2': 'Suite 10',
        'city': 'Bill City',
        'state': 'BC',
        'postcode': '11111',
        'country': 'US',
        'email': 'bill@example.com',
        'phone': '555-BILL',
      };

      final billing = Billing.fromJson(json);

      expect(billing.firstName, 'Bill');
      expect(billing.lastName, 'User');
      expect(billing.company, 'Bill Corp');
      expect(billing.address1, '200 Bill Ave');
      expect(billing.address2, 'Suite 10');
      expect(billing.city, 'Bill City');
      expect(billing.state, 'BC');
      expect(billing.postcode, '11111');
      expect(billing.country, 'US');
      expect(billing.email, 'bill@example.com');
      expect(billing.phone, '555-BILL');
    });

    test('should serialize correctly', () {
      final billing = Billing(
        firstName: 'Serialize',
        lastName: 'Test',
        email: 'serial@example.com',
        phone: '123-456-7890',
      );

      final json = billing.toJson();

      expect(json['first_name'], 'Serialize');
      expect(json['email'], 'serial@example.com');
      expect(json['phone'], '123-456-7890');
    });
  });

  group('MetaData', () {
    test('should construct from key and value', () {
      final metaData = MetaData.fromJson('wc_custom', ['a', 'b']);

      expect(metaData.key, 'wc_custom');
      expect(metaData.value, ['a', 'b']);
    });

    test('should serialize to json with key as property name', () {
      final metaData = MetaData(key: 'my_meta', value: ['x', 'y', 'z']);

      final json = metaData.toJson();

      expect(json['my_meta'], ['x', 'y', 'z']);
    });
  });
}
