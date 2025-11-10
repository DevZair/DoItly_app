import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.xp,
    required this.level,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final String email;
  final int xp;
  final int level;
  final int avatarColor;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? xp,
    int? level,
    int? avatarColor,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      avatarColor: json['avatar_color'] as int? ?? 0xFF3BA8F8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'xp': xp,
      'level': level,
      'avatar_color': avatarColor,
    };
  }

  @override
  List<Object?> get props => [id, name, email, xp, level, avatarColor];
}
