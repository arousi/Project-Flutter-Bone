import 'package:meta/meta.dart';

@immutable
class OAuthState {
  final String id;
  final String provider;
  final String state;
  final String codeChallenge;
  final String? codeVerifier;
  final String? redirectUri;
  final String? mobileRedirect;
  final String? resultPayload;
  final bool resultRetrieved;
  final String? scope;
  final String? userId;
  final String createdAt;
  final String expiresAt;
  final bool used;

  const OAuthState({
    required this.id,
    required this.provider,
    required this.state,
    required this.codeChallenge,
    this.codeVerifier,
    this.redirectUri,
    this.mobileRedirect,
    this.resultPayload,
    required this.resultRetrieved,
    this.scope,
    this.userId,
    required this.createdAt,
    required this.expiresAt,
    required this.used,
  });

  factory OAuthState.fromJson(Map<String, dynamic> json) => OAuthState(
        id: json['id'] as String,
        provider: json['provider'] as String,
        state: json['state'] as String,
        codeChallenge: json['code_challenge'] as String,
        codeVerifier: json['code_verifier'] as String?,
        redirectUri: json['redirect_uri'] as String?,
        mobileRedirect: json['mobile_redirect'] as String?,
        resultPayload: json['result_payload'] as String?,
        resultRetrieved: (json['result_retrieved'] == 1 || json['result_retrieved'] == true),
        scope: json['scope'] as String?,
        userId: json['user_id'] as String?,
        createdAt: json['created_at'] as String,
        expiresAt: json['expires_at'] as String,
        used: (json['used'] == 1 || json['used'] == true),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider': provider,
        'state': state,
        'code_challenge': codeChallenge,
        'code_verifier': codeVerifier,
        'redirect_uri': redirectUri,
        'mobile_redirect': mobileRedirect,
        'result_payload': resultPayload,
        'result_retrieved': resultRetrieved ? 1 : 0,
        'scope': scope,
        'user_id': userId,
        'created_at': createdAt,
        'expires_at': expiresAt,
        'used': used ? 1 : 0,
      };
}