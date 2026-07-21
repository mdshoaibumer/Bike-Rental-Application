import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/storage/secure_storage.dart';

/// Mock classes for testing
class MockDio extends Mock implements Dio {}

class MockApiClient extends Mock implements ApiClient {
  final MockDio mockDio = MockDio();

  @override
  Dio get dio => mockDio;
}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockRequestOptions extends Mock implements RequestOptions {}

/// Helper to create a successful Dio Response
Response<T> mockResponse<T>(T data, {int statusCode = 200}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: ''),
  );
}

/// Helper to create a DioException for error testing
DioException mockDioError({
  String message = 'Connection failed',
  int? statusCode,
  DioExceptionType type = DioExceptionType.connectionError,
}) {
  return DioException(
    requestOptions: RequestOptions(path: ''),
    message: message,
    type: type,
    response: statusCode != null
        ? Response(
            statusCode: statusCode,
            requestOptions: RequestOptions(path: ''),
          )
        : null,
  );
}
