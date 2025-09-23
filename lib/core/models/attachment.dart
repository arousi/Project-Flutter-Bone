class Attachment {
  final int? id;
  final String? messageId;
  final String? conversationId;
  final String? userId;
  final String type; // image, pdf, excel, json, md, other
  final String? mimeType;
  final String filePath; // absolute path
  final int sizeBytes;
  final int? width;
  final int? height;
  final String? sha256;
  final bool isEncrypted;
  final String? encAlgo;
  final String? ivBase64;
  final String? keyRef;
  final DateTime createdAt;

  const Attachment({
    this.id,
    this.messageId,
    this.conversationId,
    this.userId,
    required this.type,
    this.mimeType,
    required this.filePath,
    required this.sizeBytes,
    this.width,
    this.height,
    this.sha256,
    this.isEncrypted = false,
    this.encAlgo,
    this.ivBase64,
    this.keyRef,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json['id'] as int?,
        messageId: json['message_id'] as String?,
        conversationId: json['conversation_id'] as String?,
        userId: json['user_id'] as String?,
        type: (json['type'] as String?) ?? 'other',
        mimeType: json['mime_type'] as String?,
        filePath: json['file_path'] as String,
        sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
        sha256: json['sha256'] as String?,
        isEncrypted: (json['is_encrypted'] is int)
            ? ((json['is_encrypted'] as int) != 0)
            : ((json['is_encrypted'] as bool?) ?? false),
        encAlgo: json['enc_algo'] as String?,
        ivBase64: json['iv_base64'] as String?,
        keyRef: json['key_ref'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'message_id': messageId,
        'conversation_id': conversationId,
        'user_id': userId,
        'type': type,
        'mime_type': mimeType,
        'file_path': filePath,
        'size_bytes': sizeBytes,
        'width': width,
        'height': height,
        'sha256': sha256,
        'is_encrypted': isEncrypted ? 1 : 0,
        'enc_algo': encAlgo,
        'iv_base64': ivBase64,
        'key_ref': keyRef,
        'created_at': createdAt.toIso8601String(),
      };
}
