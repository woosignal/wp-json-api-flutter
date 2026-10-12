import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wp_json_api/enums/wp_meta_data_action_type.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_credentials_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_params_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/login_blocked_exception.dart';
import 'package:wp_json_api/exceptions/meta_key_not_allowed_exception.dart';
import 'package:wp_json_api/exceptions/points_and_rewards_not_found_exception.dart';
import 'package:wp_json_api/exceptions/privileged_user_exception.dart';
import 'package:wp_json_api/exceptions/registration_disabled_exception.dart';
import 'package:wp_json_api/exceptions/too_many_attempts_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/exceptions/weak_password_exception.dart';
import 'package:wp_json_api/exceptions/woocommerce_not_found_exception.dart';
import 'package:wp_json_api/exceptions/wp_network_exception.dart';
import 'package:wp_json_api/exceptions/wp_server_exception.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_calculate_points.dart';
import 'package:wp_json_api/models/responses/wc_points_and_rewards_user.dart';
import 'package:wp_json_api/models/responses/wp_user_delete_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_info_updated_response.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/models/responses/wp_user_register_response.dart';
import 'package:wp_json_api/models/responses/wp_user_reset_password_response.dart';
import 'package:wp_json_api/models/wp_meta_meta.dart';
import 'package:wp_json_api/models/wp_user.dart';
import 'package:wp_json_api/networking/network_manager.dart';
import 'package:wp_json_api/wp_json_api.dart';

import 'network_manager_test.mocks.dart';

const String baseApi = 'https://test.example.com/wp-json/wpapp/v4';
const String storedToken = 'stored_token_abc';

/// Builds a Dio [Response] with a [status] code and JSON [data].
Response<dynamic> jsonResponse(int status, dynamic data,
    {Map<String, List<String>>? headers}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: ''),
    data: data,
    statusCode: status,
    headers: headers == null ? null : Headers.fromMap(headers),
  );
}

/// A WordPress REST error body.
Map<String, dynamic> errorBody(String code, String message, int status,
    [Map<String, dynamic>? extra]) {
  return {
    'code': code,
    'message': message,
    'data': {'status': status, ...?extra},
  };
}

/// A v4 Auth success body.
Map<String, dynamic> authBody({int status = 200, int? expiresAt}) {
  return {
    'data': {
      'token': 'new_token_123',
      'expires_at': expiresAt ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000 + 90 * 24 * 3600,
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
    'status': status,
  };
}

/// A server error code, its HTTP status and the expected exception.
class _ErrorCase {
  final String code;
  final int status;
  final TypeMatcher<Exception> matcher;

  _ErrorCase(this.code, this.status, this.matcher);
}

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WPAppNetworkManager networkManager;
  late MockDio mockDio;

  void stubPost(Response<dynamic> response) {
    when(mockDio.post(any,
            data: anyNamed('data'), options: anyNamed('options')))
        .thenAnswer((_) async => response);
  }

  void stubGet(Response<dynamic> response) {
    when(mockDio.get(any, options: anyNamed('options')))
        .thenAnswer((_) async => response);
  }

  /// Returns [url, data, options] of the single POST request sent.
  List<dynamic> capturedPost() {
    return verify(mockDio.post(captureAny,
            data: captureAnyNamed('data'), options: captureAnyNamed('options')))
        .captured;
  }

  /// Returns [url, options] of the single GET request sent.
  List<dynamic> capturedGet() {
    return verify(mockDio.get(captureAny, options: captureAnyNamed('options')))
        .captured;
  }

  Future<void> storeSession({int? expiresAt}) async {
    await WPJsonAPI.wpLogin(WpUser(
      id: 12,
      token: storedToken,
      expiresAt:
          expiresAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      email: 'luke@example.com',
    ));
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
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
        final WPAppNetworkManager instance1 = WPAppNetworkManager.instance;
        final WPAppNetworkManager instance2 = WPAppNetworkManager.instance;

        expect(identical(instance1, instance2), true);
      });
    });

    group('wpLogin', () {
      test('should POST the login field to /auth/login', () async {
        stubPost(jsonResponse(200, authBody()));

        final WPUserLoginResponse response =
            await networkManager.wpLogin(login: 'luke', password: 'secret123');

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/auth/login');
        expect(captured[1], {'login': 'luke', 'password': 'secret123'});
        expect(response.data!.token, 'new_token_123');
        expect(response.data!.user!.id, 12);
      });

      test('should send email as the login field', () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(
            email: 'luke@example.com', password: 'secret123');

        expect(capturedPost()[1]['login'], 'luke@example.com');
      });

      test('should send username as the login field', () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(username: 'luke', password: 'secret123');

        expect(capturedPost()[1]['login'], 'luke');
      });

      test('should prefer login, then email, then username', () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(
            login: 'a', email: 'b@example.com', username: 'c', password: 'p');

        expect(capturedPost()[1]['login'], 'a');
      });

      test('should send expires_in and device_name when set', () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(
            login: 'luke',
            password: 'secret123',
            expiresIn: 3600,
            deviceName: 'Pixel 9');

        final Map<String, dynamic> body = capturedPost()[1];
        expect(body['expires_in'], 3600);
        expect(body['device_name'], 'Pixel 9');
      });

      test('should not send a nonce, auth query or token header', () async {
        await storeSession();
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(login: 'luke', password: 'secret123');

        final List<dynamic> captured = capturedPost();
        expect(captured[0], isNot(contains('?auth=')));
        expect((captured[1] as Map).containsKey('nonce'), false);
        final Options options = captured[2];
        expect(options.headers!.containsKey(HttpHeaders.authorizationHeader),
            false);
        expect(options.headers!.containsKey('X-WPApp-Token'), false);
        verifyNever(mockDio.get(any, options: anyNamed('options')));
      });

      test('should store the user, token and expires_at', () async {
        stubPost(jsonResponse(200, authBody(expiresAt: 4102444800)));

        await networkManager.wpLogin(login: 'luke', password: 'secret123');

        final WpUser? user = await WPJsonAPI.wpUser();
        expect(user!.id, 12);
        expect(user.token, 'new_token_123');
        expect(user.expiresAt, 4102444800);
        expect(user.email, 'luke@example.com');
        expect(await WPJsonAPI.wpUserToken(), 'new_token_123');
        expect(await WPJsonAPI.wpUserTokenExpiresAt(),
            DateTime.fromMillisecondsSinceEpoch(4102444800 * 1000));
        expect(await WPJsonAPI.wpUserLoggedIn(), true);
      });

      test('should not store the user when saveTokenToLocalStorage is false',
          () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(
            login: 'luke',
            password: 'secret123',
            saveTokenToLocalStorage: false);

        expect(await WPJsonAPI.wpUser(), isNull);
        expect(await WPJsonAPI.wpUserLoggedIn(), false);
      });
    });

    group('wpRegister', () {
      test('should POST the v4 register body to /auth/register', () async {
        stubPost(jsonResponse(201, authBody(status: 201)));

        final WPUserRegisterResponse response = await networkManager.wpRegister(
          email: 'luke@example.com',
          password: 'secret123',
          username: 'luke',
          firstName: 'Luke',
          lastName: 'Skywalker',
          metaData: {'billing_city': 'Mos Eisley'},
          expiresIn: 600,
          deviceName: 'iPhone',
        );

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/auth/register');
        expect(captured[1], {
          'email': 'luke@example.com',
          'password': 'secret123',
          'wc_register': false,
          'username': 'luke',
          'first_name': 'Luke',
          'last_name': 'Skywalker',
          'meta_data': {'billing_city': 'Mos Eisley'},
          'expires_in': 600,
          'device_name': 'iPhone',
        });
        expect(response.status, 201);
        expect(response.data!.token, 'new_token_123');
      });

      test('should leave out optional fields so the server can fill them',
          () async {
        stubPost(jsonResponse(201, authBody(status: 201)));

        await networkManager.wpRegister(
            email: 'luke@example.com', password: 'secret123');

        expect(capturedPost()[1], {
          'email': 'luke@example.com',
          'password': 'secret123',
          'wc_register': false,
        });
      });

      test('should store the user after a 201 response', () async {
        stubPost(jsonResponse(201, authBody(status: 201)));

        await networkManager.wpRegister(
            email: 'luke@example.com', password: 'secret123');

        expect(await WPJsonAPI.wpUserToken(), 'new_token_123');
        expect(await WPJsonAPI.wpUserLoggedIn(), true);
      });

      test('wcRegister should send wc_register true', () async {
        stubPost(jsonResponse(201, authBody(status: 201)));

        await networkManager.wcRegister(
            email: 'luke@example.com', password: 'secret123');

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/auth/register');
        expect(captured[1]['wc_register'], true);
      });
    });

    group('authenticated requests', () {
      test('should send the stored token in both headers', () async {
        await storeSession();
        stubGet(jsonResponse(200, {
          'data': {'id': 12, 'email': 'luke@example.com'},
          'message': '',
          'status': 200,
        }));

        final WPUserInfoResponse response =
            await networkManager.wpGetUserInfo();

        final List<dynamic> captured = capturedGet();
        expect(captured[0], '$baseApi/user');
        final Options options = captured[1];
        expect(options.headers![HttpHeaders.authorizationHeader],
            'Bearer $storedToken');
        expect(options.headers!['X-WPApp-Token'], storedToken);
        expect(response.data!.id, 12);
      });

      test('should prefer an explicit userToken over the stored token',
          () async {
        await storeSession();
        stubGet(jsonResponse(200, {'data': {}, 'status': 200}));

        await networkManager.wpGetUserInfo(userToken: 'explicit_token');

        final Options options = capturedGet()[1];
        expect(options.headers![HttpHeaders.authorizationHeader],
            'Bearer explicit_token');
        expect(options.headers!['X-WPApp-Token'], 'explicit_token');
      });

      test('should not send auth headers when there is no token', () async {
        stubGet(jsonResponse(200, {'data': {}, 'status': 200}));

        await networkManager.wpGetUserInfo();

        final Options options = capturedGet()[1];
        expect(options.headers!.containsKey(HttpHeaders.authorizationHeader),
            false);
        expect(options.headers!.containsKey('X-WPApp-Token'), false);
      });

      test('should never send the token in the request body', () async {
        await storeSession();
        final Map<String, Future<dynamic> Function()> requests = {
          'logout': () => networkManager.wpLogout(),
          'update user': () => networkManager.wpUpdateUserInfo(
              firstName: 'Luke',
              metaData: [WpMetaData(key: 'billing_city', value: 'X')]),
          'password': () => networkManager.wpResetPassword(
              currentPassword: 'old', password: 'newpassword'),
          'delete': () => networkManager.wpUserDelete(password: 'secret'),
          'update customer': () =>
              networkManager.wcUpdateCustomerInfo(billingCity: 'X'),
          'calculate points': () =>
              networkManager.wcPointsAndRewardsCalculatePoints(points: 10),
        };

        for (final MapEntry<String, Future<dynamic> Function()> entry
            in requests.entries) {
          await storeSession();
          clearInteractions(mockDio);
          stubPost(jsonResponse(200, {
            'data': {'value': '1.00'},
            'message': '',
            'status': 200,
          }));

          await entry.value();

          final List<dynamic> captured = capturedPost();
          final Map<String, dynamic> body = captured[1];
          expect(body.containsKey('token'), false, reason: entry.key);
          expect(jsonEncode(body), isNot(contains(storedToken)),
              reason: entry.key);
          expect(captured[0], isNot(contains(storedToken)), reason: entry.key);
          final Options options = captured[2];
          expect(options.headers!['X-WPApp-Token'], storedToken,
              reason: entry.key);
        }
      });
    });

    group('wpUpdateUserInfo', () {
      test('should POST fields and a meta_data list to /user', () async {
        await storeSession();
        stubPost(jsonResponse(200, {
          'data': {
            'id': 12,
            'first_name': 'Luke',
            'meta_data': {
              'billing_city': ['Mos Eisley'],
            },
          },
          'message': '',
          'status': 200,
        }));

        final WPUserInfoUpdatedResponse response =
            await networkManager.wpUpdateUserInfo(
          firstName: 'Luke',
          lastName: 'Skywalker',
          displayName: 'Luke',
          metaData: [
            WpMetaData(key: 'billing_city', value: 'Mos Eisley'),
            WpMetaData(
                key: 'billing_phone',
                value: '555',
                action: WPMetaDataActionType.Create,
                unique: true),
          ],
        );

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/user');
        expect(captured[1], {
          'first_name': 'Luke',
          'last_name': 'Skywalker',
          'display_name': 'Luke',
          'meta_data': [
            {'key': 'billing_city', 'value': 'Mos Eisley', 'action': 'update'},
            {
              'key': 'billing_phone',
              'value': '555',
              'action': 'create',
              'unique': true
            },
          ],
        });
        expect(
            response.data!.getMetaDataFirstWhere('billing_city'), 'Mos Eisley');
      });
    });

    group('wpResetPassword', () {
      test('should POST current_password and password to /user/password',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            200, {'data': [], 'message': 'Password updated', 'status': 200}));

        final WPUserResetPasswordResponse response =
            await networkManager.wpResetPassword(
                currentPassword: 'old_password', password: 'new_password');

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/user/password');
        expect(captured[1],
            {'current_password': 'old_password', 'password': 'new_password'});
        expect(response.message, 'Password updated');
        expect(await WPJsonAPI.wpUserToken(), storedToken);
      });
    });

    group('wpUserDelete', () {
      test('should POST the password to /user/delete and clear the session',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            200, {'data': [], 'message': 'Account deleted', 'status': 200}));

        final WPUserDeleteResponse response =
            await networkManager.wpUserDelete(password: 'secret');

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/user/delete');
        expect(captured[1], {'password': 'secret'});
        expect(response.message, 'Account deleted');
        expect(await WPJsonAPI.wpUser(), isNull);
      });

      test('should keep the session when the password is wrong', () async {
        await storeSession();
        stubPost(jsonResponse(
            403,
            errorBody('wpapp_incorrect_password', 'The password is incorrect.',
                403)));

        await expectLater(networkManager.wpUserDelete(password: 'wrong'),
            throwsA(isA<IncorrectPasswordException>()));
        expect(await WPJsonAPI.wpUserToken(), storedToken);
      });

      test('should keep the stored session when deleting another token',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            200, {'data': [], 'message': 'Account deleted', 'status': 200}));

        await networkManager.wpUserDelete(
            password: 'secret', userToken: 'other_token');

        expect(await WPJsonAPI.wpUserToken(), storedToken);
      });
    });

    group('WooCommerce', () {
      test('wcCustomerInfo should GET /wc/customer', () async {
        await storeSession();
        stubGet(jsonResponse(200, {
          'data': {
            'id': 12,
            'first_name': 'Luke',
            'billing': {'city': 'Mos Eisley'},
            'shipping': {'phone': '555'},
            'meta_data': {},
            'created_at': '2026-10-12 15:00:00',
          },
          'message': '',
          'status': 200,
        }));

        final WCCustomerInfoResponse response =
            await networkManager.wcCustomerInfo();

        expect(capturedGet()[0], '$baseApi/wc/customer');
        expect(response.data!.id, 12);
        expect(response.data!.billing!.city, 'Mos Eisley');
        expect(response.data!.shipping!.phone, '555');
      });

      test('wcUpdateCustomerInfo should POST billing and shipping objects',
          () async {
        await storeSession();
        stubPost(jsonResponse(200, {
          'data': {'id': 12, 'first_name': 'Luke'},
          'message': '',
          'status': 200,
        }));

        final WCCustomerUpdatedResponse response =
            await networkManager.wcUpdateCustomerInfo(
          firstName: 'Luke',
          billingCity: 'Mos Eisley',
          billingEmail: 'luke@example.com',
          shippingCity: 'Tatooine',
          shippingPhone: '555',
        );

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/wc/customer');
        expect(captured[1], {
          'first_name': 'Luke',
          'shipping': {'city': 'Tatooine', 'phone': '555'},
          'billing': {'city': 'Mos Eisley', 'email': 'luke@example.com'},
        });
        expect(response.data!.firstName, 'Luke');
      });

      test('wcPointsAndRewardsUser should GET /wc/points', () async {
        await storeSession();
        stubGet(jsonResponse(200, {
          'data': {'id': 12, 'points': 120, 'value': '1.20'},
          'message': '',
          'status': 200,
        }));

        final WcPointsAndRewardUser response =
            await networkManager.wcPointsAndRewardsUser();

        expect(capturedGet()[0], '$baseApi/wc/points');
        expect(response.points, 120);
        expect(response.value, '1.20');
      });

      test('wcPointsAndRewardsCalculatePoints should POST /wc/points/calculate',
          () async {
        await storeSession();
        stubPost(jsonResponse(200, {
          'data': {'value': '1.20'},
          'message': '',
          'status': 200,
        }));

        final WcPointsAndRewardCalculatePoints response =
            await networkManager.wcPointsAndRewardsCalculatePoints(points: 120);

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/wc/points/calculate');
        expect(captured[1], {'points': 120.0});
        expect(response.value, '1.20');
      });
    });

    group('wpLogout', () {
      test('should POST /auth/logout with the token and clear the session',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            200, {'data': [], 'message': 'Logged out', 'status': 200}));

        final bool revoked = await networkManager.wpLogout();

        final List<dynamic> captured = capturedPost();
        expect(captured[0], '$baseApi/auth/logout');
        final Options options = captured[2];
        expect(options.headers![HttpHeaders.authorizationHeader],
            'Bearer $storedToken');
        expect(options.headers!['X-WPApp-Token'], storedToken);
        expect(revoked, true);
        expect(await WPJsonAPI.wpUser(), isNull);
        expect(await WPJsonAPI.wpUserLoggedIn(), false);
      });

      test('should clear the session when the server returns an error',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            401, errorBody('wpapp_unauthorized', 'Token expired.', 401)));

        final bool revoked = await networkManager.wpLogout();

        expect(revoked, false);
        expect(await WPJsonAPI.wpUser(), isNull);
      });

      test('should clear the session when there is no connection', () async {
        await storeSession();
        when(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
          message: 'No internet',
        ));

        final bool revoked = await networkManager.wpLogout();

        expect(revoked, false);
        expect(await WPJsonAPI.wpUser(), isNull);
      });

      test('should not send a request when there is no token', () async {
        final bool revoked = await networkManager.wpLogout();

        expect(revoked, false);
        verifyNever(mockDio.post(any,
            data: anyNamed('data'), options: anyNamed('options')));
      });
    });

    group('response handling', () {
      test('should accept every status so error bodies can be read', () async {
        stubPost(jsonResponse(200, authBody()));

        await networkManager.wpLogin(login: 'luke', password: 'secret123');

        final Options options = capturedPost()[2];
        expect(options.validateStatus!(401), true);
        expect(options.validateStatus!(500), true);
      });

      test('should not treat a non-2xx response as success', () async {
        // A v3-style body with a status < 500 must still fail on HTTP 400.
        stubPost(jsonResponse(400, {'message': 'Bad', 'status': 200}));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<WPServerException>()
              .having((e) => e.status, 'status', 400)
              .having((e) => e.code, 'code', isNull)
              .having((e) => e.message, 'message', 'Bad')),
        );
        expect(await WPJsonAPI.wpUser(), isNull);
      });

      test('should throw WPServerException for a 2xx body that is not JSON',
          () async {
        stubPost(jsonResponse(200, '<html>Not WordPress</html>'));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(
              isA<WPServerException>().having((e) => e.status, 'status', 200)),
        );
      });

      test('should throw WPServerException for an HTML error page', () async {
        stubPost(jsonResponse(502, '<html>Bad gateway</html>'));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<WPServerException>()
              .having((e) => e.status, 'status', 502)
              .having((e) => e.code, 'code', isNull)
              .having((e) => e.message, 'message', isNotEmpty)),
        );
      });

      test('should map an error on a DioException response', () async {
        when(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: jsonResponse(
              401,
              errorBody('wpapp_invalid_credentials',
                  'The login details are incorrect.', 401)),
        ));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'wrong'),
          throwsA(isA<InvalidCredentialsException>()),
        );
      });

      test('should throw WPNetworkException when there is no response',
          () async {
        final DioException error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
        );
        when(mockDio.get(any, options: anyNamed('options'))).thenThrow(error);

        await expectLater(
          networkManager.wpGetUserInfo(),
          throwsA(isA<WPNetworkException>()
              .having((e) => e.message, 'message', 'Connection timed out')
              .having((e) => e.error, 'error', same(error))),
        );
      });
    });

    group('error code mapping', () {
      final List<_ErrorCase> cases = [
        _ErrorCase('wpapp_unauthorized', 401, isA<InvalidUserTokenException>()),
        _ErrorCase(
            'wpapp_privileged_user', 403, isA<PrivilegedUserException>()),
        _ErrorCase('wpapp_invalid_credentials', 401,
            isA<InvalidCredentialsException>()),
        _ErrorCase('wpapp_login_blocked', 403, isA<LoginBlockedException>()),
        _ErrorCase(
            'wpapp_too_many_attempts', 429, isA<TooManyAttemptsException>()),
        _ErrorCase('wpapp_registration_disabled', 403,
            isA<RegistrationDisabledException>()),
        _ErrorCase('wpapp_username_taken', 409, isA<UsernameTakenException>()),
        _ErrorCase('wpapp_email_exists', 409, isA<UserAlreadyExistException>()),
        _ErrorCase('wpapp_invalid_email', 400, isA<InvalidEmailException>()),
        _ErrorCase('wpapp_weak_password', 400, isA<WeakPasswordException>()),
        _ErrorCase('wpapp_meta_key_not_allowed', 403,
            isA<MetaKeyNotAllowedException>()),
        _ErrorCase(
            'wpapp_incorrect_password', 403, isA<IncorrectPasswordException>()),
        _ErrorCase('wpapp_woocommerce_missing', 501,
            isA<WooCommerceNotFoundException>()),
        _ErrorCase('wpapp_points_rewards_missing', 501,
            isA<PointsAndRewardsNotFoundException>()),
        _ErrorCase('wpapp_invalid_params', 400, isA<InvalidParamsException>()),
        _ErrorCase(
            'rest_missing_callback_param', 400, isA<InvalidParamsException>()),
        _ErrorCase('rest_invalid_param', 400, isA<InvalidParamsException>()),
        _ErrorCase('wpapp_server_error', 500, isA<WPServerException>()),
      ];

      for (final _ErrorCase errorCase in cases) {
        test('should map ${errorCase.code} (${errorCase.status})', () async {
          final String message = 'Server message for ${errorCase.code}';
          stubPost(jsonResponse(errorCase.status,
              errorBody(errorCase.code, message, errorCase.status)));

          await expectLater(
            networkManager.wpLogin(login: 'luke', password: 'secret123'),
            throwsA(errorCase.matcher
                .having((e) => (e as dynamic).message, 'message', message)),
          );
        });
      }

      test('should read retry_after for wpapp_too_many_attempts', () async {
        stubPost(jsonResponse(
            429,
            errorBody('wpapp_too_many_attempts', 'Too many attempts.', 429,
                {'retry_after': 120})));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<TooManyAttemptsException>()
              .having((e) => e.retryAfter, 'retryAfter', 120)),
        );
      });

      test('should fall back to the Retry-After header', () async {
        stubPost(jsonResponse(
            429, errorBody('wpapp_too_many_attempts', 'Too many.', 429),
            headers: {
              'retry-after': ['15']
            }));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<TooManyAttemptsException>()
              .having((e) => e.retryAfter, 'retryAfter', 15)),
        );
      });

      test('should read the refused key for wpapp_meta_key_not_allowed',
          () async {
        await storeSession();
        stubPost(jsonResponse(
            403,
            errorBody('wpapp_meta_key_not_allowed', 'Not allowed.', 403,
                {'key': 'wp_capabilities'})));

        await expectLater(
          networkManager.wpUpdateUserInfo(
              metaData: [WpMetaData(key: 'wp_capabilities', value: 'x')]),
          throwsA(isA<MetaKeyNotAllowedException>()
              .having((e) => e.key, 'key', 'wp_capabilities')),
        );
      });

      test('should carry code, status and data for wpapp_server_error',
          () async {
        stubPost(jsonResponse(
            500, errorBody('wpapp_server_error', 'Unexpected failure.', 500)));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<WPServerException>()
              .having((e) => e.code, 'code', 'wpapp_server_error')
              .having((e) => e.status, 'status', 500)
              .having((e) => e.data, 'data', {'status': 500})),
        );
      });

      test('should throw WPServerException for an unknown code', () async {
        stubPost(jsonResponse(
            404, errorBody('rest_no_route', 'No route was found.', 404)));

        await expectLater(
          networkManager.wpLogin(login: 'luke', password: 'secret123'),
          throwsA(isA<WPServerException>()
              .having((e) => e.code, 'code', 'rest_no_route')
              .having((e) => e.status, 'status', 404)
              .having((e) => e.message, 'message', 'No route was found.')),
        );
      });

      test('should map errors from GET requests too', () async {
        await storeSession();
        stubGet(jsonResponse(
            501,
            errorBody('wpapp_woocommerce_missing', 'WooCommerce is not active.',
                501)));

        await expectLater(networkManager.wcCustomerInfo(),
            throwsA(isA<WooCommerceNotFoundException>()));
      });

      test('should not store a session when login fails', () async {
        stubPost(jsonResponse(
            401, errorBody('wpapp_invalid_credentials', 'Incorrect.', 401)));

        await expectLater(
            networkManager.wpLogin(login: 'luke', password: 'wrong'),
            throwsA(isA<InvalidCredentialsException>()));
        expect(await WPJsonAPI.wpUser(), isNull);
      });
    });
  });
}
