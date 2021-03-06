part of dart_openapi;

class ApiClient {
  ApiClientDelegate apiClientDelegate;
  String basePath;

  Map<String, String> _defaultHeaderMap = {};
  Map<String, Authentication> _authentications = {};

  ApiClient({this.basePath = "http://localhost", apiClientDelegate})
      : this.apiClientDelegate = apiClientDelegate ?? DioClientDelegate();

  void setDefaultHeader(String key, String value) {
    if (value == null) {
      _defaultHeaderMap.remove(key);
    } else {
      _defaultHeaderMap[key] = value;
    }
  }

  // ensure you set the Auth before calling an API that requires that type
  void setAuthentication(String key, Authentication auth) {
    if (auth == null) {
      _authentications.remove(key);
    } else {
      _authentications[key] = auth;
    }
  }

  /// Update query and header parameters based on authentication settings.
  /// @param authNames The authentications to apply
  void _updateParamsForAuth(List<String> authNames,
      List<QueryParam> queryParams, Map<String, String> headerParams) {
    authNames.forEach((authName) {
      Authentication auth = _authentications[authName];
      if (auth == null) {
        throw ArgumentError("Authentication undefined: " + authName);
      }
      auth.applyToParams(queryParams, headerParams);
    });
  }

  T getAuthentication<T extends Authentication>(String name) {
    var authentication = _authentications[name];

    return authentication is T ? authentication : null;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi' a key might appear multiple times.
  Future<ApiResponse> invokeAPI(
      String path,
      Iterable<QueryParam> queryParams,
      Object body,
      Map<String, String> headerParams,
      List<String> authNames,
      Options options) async {
    _updateParamsForAuth(authNames, queryParams, headerParams);

    options.headers.addAll(_defaultHeaderMap);
    options.headers.addAll(headerParams);

    return apiClientDelegate.invokeAPI(
        basePath, path, queryParams, body, options);
  }
}
