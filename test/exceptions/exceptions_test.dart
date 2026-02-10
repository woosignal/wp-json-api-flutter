import 'package:flutter_test/flutter_test.dart';
import 'package:wp_json_api/exceptions/empty_username_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_email_exception.dart';
import 'package:wp_json_api/exceptions/existing_user_login_exception.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_params_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/exceptions/user_already_exist_exception.dart';
import 'package:wp_json_api/exceptions/username_taken_exception.dart';
import 'package:wp_json_api/exceptions/woocommerce_not_found_exception.dart';

void main() {
  group('Exceptions', () {
    group('EmptyUsernameException', () {
      test('should implement Exception', () {
        final exception = EmptyUsernameException();

        expect(exception, isA<Exception>());
      });

      test('should have default message', () {
        final exception = EmptyUsernameException();

        expect(exception.message, 'The email field is empty');
      });

      test('should be throwable', () {
        expect(
          () => throw EmptyUsernameException(),
          throwsA(isA<EmptyUsernameException>()),
        );
      });
    });

    group('ExistingUserEmailException', () {
      test('should implement Exception', () {
        final exception = ExistingUserEmailException('Email exists');

        expect(exception, isA<Exception>());
      });

      test('should store custom message', () {
        final exception =
            ExistingUserEmailException('This email is already registered');

        expect(exception.message, 'This email is already registered');
      });

      test('should be throwable with message', () {
        expect(
          () => throw ExistingUserEmailException('Custom message'),
          throwsA(
            isA<ExistingUserEmailException>().having(
              (e) => e.message,
              'message',
              'Custom message',
            ),
          ),
        );
      });
    });

    group('ExistingUserLoginException', () {
      test('should implement Exception', () {
        final exception = ExistingUserLoginException('Login exists');

        expect(exception, isA<Exception>());
      });

      test('should store custom message', () {
        final exception =
            ExistingUserLoginException('User login already taken');

        expect(exception.message, 'User login already taken');
      });

      test('should be throwable', () {
        expect(
          () => throw ExistingUserLoginException('Login in use'),
          throwsA(isA<ExistingUserLoginException>()),
        );
      });
    });

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

    group('InvalidUsernameException', () {
      test('should implement Exception', () {
        final exception = InvalidUsernameException('Invalid username');

        expect(exception, isA<Exception>());
      });

      test('should store custom message', () {
        final exception =
            InvalidUsernameException('Username contains invalid characters');

        expect(exception.message, 'Username contains invalid characters');
      });

      test('should be throwable with message', () {
        expect(
          () => throw InvalidUsernameException('Bad username'),
          throwsA(
            isA<InvalidUsernameException>().having(
              (e) => e.message,
              'message',
              'Bad username',
            ),
          ),
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
}
