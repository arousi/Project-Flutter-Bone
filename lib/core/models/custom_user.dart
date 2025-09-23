import 'dart:convert';
class CustomUser {
  final String? userId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final bool? biometricEnabled;
  final String? lastModified;
  final bool? isArchived;
  final bool? isVisitor;
  final bool? isActive;
  final String? dateJoined;
  final int? emailPin;
  final String? emailPinCreated;
  final bool? emailVerified;
  final bool? profileEmailVerified;
  final String? profileEmailPin;
  final String? profileEmailPinCreated;
  final bool? isStaff;
  final bool? isSuperuser;
  final String? deviceId;
  final String? tempId;
  final String? relatedDevices; // JSON-encoded list

  CustomUser({
  this.userId, // lowerCamelCase
  this.username,
  this.firstName,
  this.lastName,
  this.email,
  this.phoneNumber,
  this.biometricEnabled,
  this.lastModified,
  this.isArchived,
  this.isVisitor,
  this.isActive,
  this.dateJoined,
  this.emailPin,
  this.emailPinCreated,
  this.emailVerified,
  this.profileEmailVerified,
  this.profileEmailPin,
  this.profileEmailPinCreated,
  this.isStaff,
  this.isSuperuser,
  this.deviceId,
  this.tempId,
  this.relatedDevices,
  });

  // Factory method to create a CustomUser from JSON
  factory CustomUser.fromJson(Map<String, dynamic> json) {
  return CustomUser(
    userId: json['user_id'] as String?,
    username: json['username'] as String?,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    email: json['email'] as String?,
    phoneNumber: json['phone_number'] as String?,
    biometricEnabled: (json['biometric_enabled'] is int)
      ? (json['biometric_enabled'] == 1)
      : json['biometric_enabled'] as bool?,
    lastModified: json['last_modified'] as String?,
    isArchived: (json['is_archived'] is int)
      ? (json['is_archived'] == 1)
      : json['is_archived'] as bool?,
    isVisitor: (json['is_visitor'] is int)
      ? (json['is_visitor'] == 1)
      : json['is_visitor'] as bool?,
    isActive: (json['is_active'] is int)
      ? (json['is_active'] == 1)
      : json['is_active'] as bool?,
    dateJoined: json['date_joined'] as String?,
    emailPin: json['email_pin'] as int?,
    emailPinCreated: json['email_pin_created'] as String?,
    emailVerified: (json['email_verified'] is int)
      ? (json['email_verified'] == 1)
      : json['email_verified'] as bool?,
    profileEmailVerified: (json['profile_email_verified'] is int)
      ? (json['profile_email_verified'] == 1)
      : json['profile_email_verified'] as bool?,
    profileEmailPin: json['profile_email_pin'] as String?,
    profileEmailPinCreated: json['profile_email_pin_created'] as String?,
    isStaff: (json['is_staff'] is int) ? (json['is_staff'] == 1) : json['is_staff'] as bool?,
    isSuperuser:
      (json['is_superuser'] is int) ? (json['is_superuser'] == 1) : json['is_superuser'] as bool?,
    deviceId: json['device_id'] as String?,
    tempId: json['temp_id'] as String?,
    // Server may return related_devices as a JSON string or as a native list;
    // normalize to a JSON-encoded string for backward compatibility.
    relatedDevices: () {
      final v = json['related_devices'];
      if (v == null) return null;
      if (v is String) return v;
      if (v is List) {
        try { return jsonEncode(v); } catch (_) { return '[]'; }
      }
      // Any other type: best-effort stringify
      return v.toString();
    }(),
  );
  }

  // Method to convert a CustomUser to JSON
  Map<String, dynamic> toJson() {
  final Map<String, dynamic> map = {};
  if (userId != null) map['user_id'] = userId;
  if (username != null) map['username'] = username;
  if (firstName != null) map['first_name'] = firstName;
  if (lastName != null) map['last_name'] = lastName;
  if (email != null) map['email'] = email;
  if (phoneNumber != null) map['phone_number'] = phoneNumber;
  if (biometricEnabled != null) map['biometric_enabled'] = biometricEnabled! ? 1 : 0;
  if (lastModified != null) map['last_modified'] = lastModified;
  if (isArchived != null) map['is_archived'] = isArchived! ? 1 : 0;
  if (isVisitor != null) map['is_visitor'] = isVisitor! ? 1 : 0;
  if (isActive != null) map['is_active'] = isActive! ? 1 : 0;
  if (dateJoined != null) map['date_joined'] = dateJoined;
  if (emailPin != null) map['email_pin'] = emailPin;
  if (emailPinCreated != null) map['email_pin_created'] = emailPinCreated;
  if (emailVerified != null) map['email_verified'] = emailVerified! ? 1 : 0;
  if (profileEmailVerified != null) map['profile_email_verified'] = profileEmailVerified! ? 1 : 0;
  if (profileEmailPin != null) map['profile_email_pin'] = profileEmailPin;
  if (profileEmailPinCreated != null) map['profile_email_pin_created'] = profileEmailPinCreated;
  if (isStaff != null) map['is_staff'] = isStaff! ? 1 : 0;
  if (isSuperuser != null) map['is_superuser'] = isSuperuser! ? 1 : 0;
  if (deviceId != null) map['device_id'] = deviceId;
  if (tempId != null) map['temp_id'] = tempId;
  if (relatedDevices != null) map['related_devices'] = relatedDevices;
  return map;
  }
}