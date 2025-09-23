import 'package:meta/meta.dart';

@immutable
class ProviderOAuthToken {
  final String id;
  final String userId;
  final String provider;
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final String? scope;
  final String? expiresAt;
  final String createdAt;
  final String updatedAt;

  const ProviderOAuthToken({
    required this.id,
    required this.userId,
    required this.provider,
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.scope,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderOAuthToken.fromJson(Map<String, dynamic> json) => ProviderOAuthToken(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        provider: json['provider'] as String,
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        tokenType: json['token_type'] as String?,
        scope: json['scope'] as String?,
        expiresAt: json['expires_at'] as String?,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'provider': provider,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'scope': scope,
        'expires_at': expiresAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}