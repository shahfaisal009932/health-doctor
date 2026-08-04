import 'package:flutter_test/flutter_test.dart';

import 'package:dr_serv/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email is required', () {
      expect(Validators.validateEmail(''), 'Email is required');
    });

    test('invalid email is rejected', () {
      expect(
        Validators.validateEmail('not-an-email'),
        'Enter valid email',
      );
    });

    test('valid email passes', () {
      expect(Validators.validateEmail('doctor@example.com'), isNull);
    });

    test('short password is rejected', () {
      expect(
        Validators.validatePassword('123'),
        'Password must contain minimum 6 characters',
      );
    });

    test('valid password passes', () {
      expect(Validators.validatePassword('secret123'), isNull);
    });
  });
}
