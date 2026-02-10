import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'package:wp_json_api/networking/network_manager.dart';

import 'network_manager_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WPAppNetworkManager networkManager;
  late MockDio mockDio;

  setUp(() async {
    mockDio = MockDio();
    networkManager = WPAppNetworkManager.instance;
    networkManager.dio = mockDio;

    await WPJsonAPI.instance.init(
      baseUrl: 'https://test.example.com',
      shouldDebug: false,
    );
  });

  group('WPAppNetworkManager', () {
    group('Singleton', () {
      test('should return same instance', () {
        final instance1 = WPAppNetworkManager.instance;
        final instance2 = WPAppNetworkManager.instance;

        expect(identical(instance1, instance2), true);
      });
    });

    group('wpNonce', () {
      test('should fetch nonce successfully', () async {
        when(mockDio.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': {
                  'nonce': 'test_nonce_123',
                  'root': 'https://test.example.com/wp-json',
                  'expiry': 86400,
                },
                'message': 'Nonce generated',
                'status': 200,
              },
              statusCode: 200,
            ));

        final response = await networkManager.wpNonce();

        expect(response.status, 200);
        expect(response.data?.nonce, 'test_nonce_123');
        expect(response.data?.root, 'https://test.example.com/wp-json');
        expect(response.data?.expiry, 86400);

        verify(mockDio.get(argThat(contains('/wpapp/auth/v3/nonce'))))
            .called(1);
      });

      test('should throw exception on error status', () async {
        when(mockDio.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'message': 'Server error',
                'status': 500,
              },
              statusCode: 200,
            ));

        expect(
          () => networkManager.wpNonce(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle response with null nonce data', () async {
        when(mockDio.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': null,
                'message': 'No nonce',
                'status': 200,
              },
              statusCode: 200,
            ));

        final response = await networkManager.wpNonce();

        expect(response.status, 200);
        expect(response.data, isNull);
      });

      test('should parse nonce with all fields', () async {
        when(mockDio.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': {
                  'nonce': 'full_nonce_abc123',
                  'root': 'https://mysite.com/wp-json',
                  'expiry': 172800,
                },
                'message': 'Nonce created successfully',
                'status': 200,
              },
              statusCode: 200,
            ));

        final response = await networkManager.wpNonce();

        expect(response.data?.nonce, 'full_nonce_abc123');
        expect(response.data?.root, 'https://mysite.com/wp-json');
        expect(response.data?.expiry, 172800);
        expect(response.message, 'Nonce created successfully');
      });

      test('should handle nonce with minimal data', () async {
        when(mockDio.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': {
                  'nonce': 'minimal_nonce',
                },
                'status': 200,
              },
              statusCode: 200,
            ));

        final response = await networkManager.wpNonce();

        expect(response.data?.nonce, 'minimal_nonce');
        expect(response.data?.root, isNull);
        expect(response.data?.expiry, isNull);
      });
    });
  });
}
