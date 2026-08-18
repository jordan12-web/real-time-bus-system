import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/repositories/auth_repository.dart';
import 'package:passenger_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthRepository token handling', () {
    late MockAuthService mockService;
    late AuthRepository repository;

    setUp(() {
      mockService = MockAuthService();
      repository = AuthRepository(mockService);
    });

    test('TODO: login persists accessToken and refreshToken to secure storage', () async {
      // TODO: stub mockService.login to return a fixed user/token map,
      // call repository.login, then verify getAccessToken()/getRefreshToken()
      // return the stored values.
      expect(repository, isNotNull);
    });

    test('TODO: refresh() clears tokens and returns false with no stored refresh token', () async {
      // TODO: call repository.refresh() against empty secure storage and
      // assert it returns false without calling mockService.refresh.
      expect(mockService, isNotNull);
    });

    test('TODO: refresh() logs out when service.refresh throws ApiException', () async {
      // TODO: stub mockService.refresh to throw ApiException, seed a
      // refresh token, call repository.refresh(), assert result is false
      // and both tokens are cleared afterward.
      expect(repository, isNotNull);
    });
  });
}