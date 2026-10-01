/// Thrown by the API client; never escapes the data layer.
final class ApiException implements Exception {
  const ApiException(this.statusCode, [this.body = const {}]);
  final int statusCode;
  final Map<String, Object?> body;
}

/// Thin wrapper over the HTTP/SDK client. Swap in dio, Amplify, GraphQL… behind this.
abstract interface class ProfileRemoteSource {
  Future<Map<String, Object?>> fetch(String id);
  Future<Map<String, Object?>> patch(String id, Map<String, Object?> fields);
}
