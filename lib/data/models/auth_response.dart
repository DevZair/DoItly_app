// class AuthResponse {
//   const AuthResponse({
//     required this.accessToken,
//     required this.refreshToken,
//     required this.tokenType,
//   });

//   final String accessToken;
//   final String refreshToken;
//   final String? tokenType;

//   factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
//     accessToken: json['access_token'] as String,
//     refreshToken: json['refresh_token'] as String,
//     tokenType: json['token_type'] as String?,
//   );

//   @override
//   String toString() =>
//       'AuthResponse('
//       'accessToken: $accessToken,'
//       'refreshToken: $refreshToken,'
//       'tokenType: $tokenType)';
// }
