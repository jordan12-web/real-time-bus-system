import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passenger_app/core/api/dio_client.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  group('DioClient', () {
    late MockDioClient mockClient;

    setUp(() {
      mockClient = MockDioClient();
    });

    test('TODO: wire mock Dio and verify sendWithRetry behavior', () {
      // TODO: inject a mock Dio instance and assert retry/backoff on
      // connection timeouts.
      expect(mockClient, isNotNull);
    });

    test('TODO: verify 401 triggers single token refresh attempt', () {
      // TODO: stub onTokenRefresh returning true/false and assert one retry.
      expect(mockClient, isNotNull);
    });
  });
}
