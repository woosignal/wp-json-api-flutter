import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_params_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/exceptions/woocommerce_not_found_exception.dart';
import 'package:wp_json_api/exceptions/invalid_credentials_exception.dart';
import 'package:wp_json_api/exceptions/login_blocked_exception.dart';
import 'package:wp_json_api/exceptions/meta_key_not_allowed_exception.dart';
import 'package:wp_json_api/exceptions/points_and_rewards_not_found_exception.dart';
import 'package:wp_json_api/exceptions/privileged_user_exception.dart';
import 'package:wp_json_api/exceptions/registration_disabled_exception.dart';
import 'package:wp_json_api/exceptions/too_many_attempts_exception.dart';
import 'package:wp_json_api/exceptions/weak_password_exception.dart';
import 'package:wp_json_api/exceptions/wp_network_exception.dart';
import 'package:wp_json_api/exceptions/wp_server_exception.dart';

void main() {
  group('Exceptions', () {
    group('IncorrectPasswordException', () {
      test('should implement Exception', () {
        final exception = IncorrectPasswordException('Wrong password');

        expect(exception, isA<Exception>());
      });

      test('should store custom message', () {
        final exception =
            IncorrectPasswordException('The password you entered is incorrect');

        expect(exception.message, 'The password you entered is incorrect');
      });

      test('should be throwable with message', () {
        expect(
          () => throw IncorrectPasswordException('Password mismatch'),
          throwsA(
            isA<IncorrectPasswordException>().having(
              (e) => e.message,
              'message',
              'Password mismatch',
            ),
          ),
        );
      });
    });

    group('InvalidEmailException', () {
      test('should implement Exception', () {
        final exception = InvalidEmailException('Invalid email');

        expect(exception, isA<Exception>());
      });

      test('should store custom message', () {
        final exception = InvalidEmailException('Email format is invalid');

        expect(exception.message, 'Email format is invalid');
      });

      test('should be throwable', () {
        expect(
          () => throw InvalidEmailException('Bad email'),
          throwsA(isA<InvalidEmailException>()),
        );
      });
    });

    group('InvalidParamsException', () {
      test('should implement Exception', () {
        final exception = InvalidParamsException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = InvalidParamsException();

        expect(exception.message, 'Invalid parameters, please check the data');
      });

      test('should be throwable', () {
        expect(
          () => throw InvalidParamsException(),
          throwsA(isA<InvalidParamsException>()),
        );
      });
    });

    group('InvalidUserTokenException', () {
      test('should implement Exception', () {
        final exception = InvalidUserTokenException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = InvalidUserTokenException();

        expect(exception.message, 'Invalid user API token');
      });

      test('should be throwable', () {
        expect(
          () => throw InvalidUserTokenException(),
          throwsA(isA<InvalidUserTokenException>()),
        );
      });
    });

    group('UserAlreadyExistException', () {
      test('should implement Exception', () {
        final exception = UserAlreadyExistException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = UserAlreadyExistException();

        expect(
            exception.message, 'A user already exists with those credentials');
      });

      test('should be throwable', () {
        expect(
          () => throw UserAlreadyExistException(),
          throwsA(isA<UserAlreadyExistException>()),
        );
      });
    });

    group('UsernameTakenException', () {
      test('should implement Exception', () {
        final exception = UsernameTakenException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = UsernameTakenException();

        expect(exception.message, 'Username taken, try another.');
      });

      test('should be throwable', () {
        expect(
          () => throw UsernameTakenException(),
          throwsA(isA<UsernameTakenException>()),
        );
      });
    });

    group('WooCommerceNotFoundException', () {
      test('should implement Exception', () {
        final exception = WooCommerceNotFoundException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = WooCommerceNotFoundException();

        expect(exception.message, 'WooCommerce is not found on WordPress');
      });

      test('should be throwable', () {
        expect(
          () => throw WooCommerceNotFoundException(),
          throwsA(isA<WooCommerceNotFoundException>()),
        );
      });
    });
  });

  group('Exception catching patterns', () {
    test('should catch specific exception types', () {
      String? caught;

      try {
        throw UsernameTakenException();
      } on UsernameTakenException catch (e) {
        caught = e.message;
      }

      expect(caught, 'Username taken, try another.');
    });

    test('should catch as generic Exception', () {
      Exception? caught;

      try {
        throw InvalidUserTokenException();
      } on Exception catch (e) {
        caught = e;
      }

      expect(caught, isA<InvalidUserTokenException>());
    });

    test('should distinguish between exception types', () {
      String exceptionType = '';

      void handleException(Exception e) {
        if (e is UsernameTakenException) {
          exceptionType = 'username_taken';
        } else if (e is InvalidEmailException) {
          exceptionType = 'invalid_email';
        } else if (e is IncorrectPasswordException) {
          exceptionType = 'incorrect_password';
        } else {
          exceptionType = 'unknown';
        }
      }

      handleException(UsernameTakenException());
      expect(exceptionType, 'username_taken');

      handleException(InvalidEmailException('bad email'));
      expect(exceptionType, 'invalid_email');

      handleException(IncorrectPasswordException('wrong'));
      expect(exceptionType, 'incorrect_password');
    });
  });

  group('Exceptions with a default message', () {
    final Map<String, Exception Function([String?])> factories = {
      'InvalidUserTokenException': InvalidUserTokenException.new,
      'UsernameTakenException': UsernameTakenException.new,
      'UserAlreadyExistException': UserAlreadyExistException.new,
      'InvalidParamsException': InvalidParamsException.new,
      'WooCommerceNotFoundException': WooCommerceNotFoundException.new,
      'PrivilegedUserException': PrivilegedUserException.new,
      'InvalidCredentialsException': InvalidCredentialsException.new,
      'RegistrationDisabledException': RegistrationDisabledException.new,
      'WeakPasswordException': WeakPasswordException.new,
      'PointsAndRewardsNotFoundException':
          PointsAndRewardsNotFoundException.new,
    };

    factories.forEach((name, create) {
      group(name, () {
        test('should implement Exception', () {
          expect(create(), isA<Exception>());
        });

        test('should have a default message', () {
          expect((create() as dynamic).message, isNotEmpty);
        });

        test('should use the server message when given', () {
          expect((create('From server') as dynamic).message, 'From server');
        });

        test('should include the message in toString', () {
          expect(create('From server').toString(), '$name: From server');
        });
      });
    });
  });

  group('LoginBlockedException', () {
    test('should store the server message', () {
      final exception = LoginBlockedException('Enter your 2FA code');

      expect(exception, isA<Exception>());
      expect(exception.message, 'Enter your 2FA code');
    });
  });

  group('TooManyAttemptsException', () {
    test('should store retryAfter', () {
      final exception = TooManyAttemptsException('Slow down', 30);

      expect(exception, isA<Exception>());
      expect(exception.message, 'Slow down');
      expect(exception.retryAfter, 30);
    });

    test('should have a default message and null retryAfter', () {
      final exception = TooManyAttemptsException();

      expect(exception.message, isNotEmpty);
      expect(exception.retryAfter, isNull);
    });
  });

  group('MetaKeyNotAllowedException', () {
    test('should store the refused key', () {
      final exception =
          MetaKeyNotAllowedException('Not allowed', 'wp_capabilities');

      expect(exception, isA<Exception>());
      expect(exception.message, 'Not allowed');
      expect(exception.key, 'wp_capabilities');
    });
  });

  group('WPServerException', () {
    test('should store code, message, status and data', () {
      final exception = WPServerException(
        'Unexpected failure',
        code: 'wpapp_server_error',
        status: 500,
        data: {'status': 500},
      );

      expect(exception, isA<Exception>());
      expect(exception.message, 'Unexpected failure');
      expect(exception.code, 'wpapp_server_error');
      expect(exception.status, 500);
      expect(exception.data, {'status': 500});
      expect(exception.toString(), contains('wpapp_server_error'));
    });
  });

  group('WPNetworkException', () {
    test('should store the message and underlying error', () {
      final Object error = Object();
      final exception = WPNetworkException('No connection', error: error);

      expect(exception, isA<Exception>());
      expect(exception.message, 'No connection');
      expect(exception.error, same(error));
    });
  });
}
