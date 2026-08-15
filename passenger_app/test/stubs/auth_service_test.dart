import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/core/api/dio_client.dart';
import 'package:passenger_app/services/auth_service.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  group('AuthService', () {
    late MockDioClient mockClient;
    late AuthService authService;

    setUp(() {
      mockClient = MockDioClient();
      authService = AuthService(mockClient);
    });

    test('TODO: login posts to POST /auth/login with email and password', () {
      // TODO: mock dio.post and verify payload matches OpenAPI contract.
      expect(authService, isNotNull);
    });

    test('TODO: refresh posts refreshToken to POST /auth/refresh', () {
      // TODO: mock dio.post and verify refreshToken field name.
      expect(authService, isNotNull);
    });

    test('TODO: me calls GET /auth/me with bearer token', () {
      // TODO: mock sendWithRetry/dio.get and assert path.
      expect(authService, isNotNull);
    });
  });
}
