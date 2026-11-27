import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Only the owner can read this doc, so the email is kept here too
class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  // Stored under settings, where later ones like weight unit will go
  final ThemeMode theme;
  // The plan Today follows; null until the first plan is made
  final String? activePlanId;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.theme = ThemeMode.system,
    this.activePlanId,
  });

  // uid is the doc id, so it isn't stored as a field
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
    'settings': {'theme': theme.name},
    if (activePlanId != null) 'activePlanId': activePlanId,
  };

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final settings = map['settings'] as Map<String, dynamic>? ?? const {};

    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      // Null until the server timestamp lands
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      theme:
          ThemeMode.values.asNameMap()[settings['theme']] ?? ThemeMode.system,
      activePlanId: map['activePlanId'] as String?,
    );
  }
}
