import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/models/wp_meta_meta.dart';
import 'package:wp_json_api/enums/wp_meta_data_action_type.dart';

void main() {
  group('WpMetaData', () {
    group('constructor', () {
      test('should create with default action type of Update', () {
        final metaData = WpMetaData(key: 'test_key', value: 'test_value');

        expect(metaData.key, 'test_key');
        expect(metaData.value, 'test_value');
        expect(metaData.action, WPMetaDataActionType.Update);
        expect(metaData.unique, isNull);
      });

      test('should create with Create action type', () {
        final metaData = WpMetaData(
          key: 'new_key',
          value: 'new_value',
          action: WPMetaDataActionType.Create,
        );

        expect(metaData.action, WPMetaDataActionType.Create);
      });

      test('should create with Delete action type', () {
        final metaData = WpMetaData(
          key: 'delete_key',
          value: 'delete_value',
          action: WPMetaDataActionType.Delete,
        );

        expect(metaData.action, WPMetaDataActionType.Delete);
      });

      test('should accept unique parameter', () {
        final metaData = WpMetaData(
          key: 'unique_key',
          value: 'unique_value',
          unique: 1,
        );

        expect(metaData.unique, 1);
      });

      test('should accept various value types', () {
        final stringMeta = WpMetaData(key: 'string', value: 'text');
        final intMeta = WpMetaData(key: 'int', value: 42);
        final listMeta = WpMetaData(key: 'list', value: ['a', 'b', 'c']);
        final mapMeta = WpMetaData(key: 'map', value: {'nested': 'data'});
        final boolMeta = WpMetaData(key: 'bool', value: true);

        expect(stringMeta.value, 'text');
        expect(intMeta.value, 42);
        expect(listMeta.value, ['a', 'b', 'c']);
        expect(mapMeta.value, {'nested': 'data'});
        expect(boolMeta.value, true);
      });
    });

    group('toJson', () {
      test('should serialize with Update action', () {
        final metaData = WpMetaData(
          key: 'update_key',
          value: 'update_value',
          action: WPMetaDataActionType.Update,
        );

        final json = metaData.toJson();

        expect(json['key'], 'update_key');
        expect(json['value'], 'update_value');
        expect(json['action'], 'update');
        expect(json.containsKey('unique'), false);
      });

      test('should serialize with Create action', () {
        final metaData = WpMetaData(
          key: 'create_key',
          value: 'create_value',
          action: WPMetaDataActionType.Create,
        );

        final json = metaData.toJson();

        expect(json['action'], 'create');
      });

      test('should serialize with Delete action', () {
        final metaData = WpMetaData(
          key: 'delete_key',
          value: 'delete_value',
          action: WPMetaDataActionType.Delete,
        );

        final json = metaData.toJson();

        expect(json['action'], 'delete');
      });

      test('should include unique when set', () {
        final metaData = WpMetaData(
          key: 'unique_test',
          value: 'value',
          unique: 1,
        );

        final json = metaData.toJson();

        expect(json['unique'], 1);
      });

      test('should not include unique when null', () {
        final metaData = WpMetaData(
          key: 'no_unique',
          value: 'value',
        );

        final json = metaData.toJson();

        expect(json.containsKey('unique'), false);
      });

      test('should handle null key', () {
        final metaData = WpMetaData(key: null, value: 'value');

        final json = metaData.toJson();

        expect(json['key'], isNull);
      });

      test('should handle null value', () {
        final metaData = WpMetaData(key: 'key', value: null);

        final json = metaData.toJson();

        expect(json['value'], isNull);
      });

      test('should serialize complex value types', () {
        final metaData = WpMetaData(
          key: 'complex',
          value: {
            'items': [1, 2, 3],
            'nested': {'a': 'b'}
          },
        );

        final json = metaData.toJson();

        expect(json['value'], isA<Map>());
        expect(json['value']['items'], [1, 2, 3]);
      });
    });

    group('action type conversion', () {
      test('all action types should convert to correct strings', () {
        final createMeta = WpMetaData(
          key: 'k',
          value: 'v',
          action: WPMetaDataActionType.Create,
        );
        final updateMeta = WpMetaData(
          key: 'k',
          value: 'v',
          action: WPMetaDataActionType.Update,
        );
        final deleteMeta = WpMetaData(
          key: 'k',
          value: 'v',
          action: WPMetaDataActionType.Delete,
        );

        expect(createMeta.toJson()['action'], 'create');
        expect(updateMeta.toJson()['action'], 'update');
        expect(deleteMeta.toJson()['action'], 'delete');
      });
    });
  });
}
