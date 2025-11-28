import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    this.nickname = '',
    this.email = '',
    this.xp = 0,
    this.level = 1,
    this.avatarColor = 0xFF3BA8F8,
  });

  final String id;
  final String name;
  final String nickname;
  final String email;
  final int xp;
  final int level;
  final int avatarColor;

  UserModel copyWith({
    String? id,
    String? name,
    String? nickname,
    String? email,
    int? xp,
    int? level,
    int? avatarColor,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['name']?.toString() ?? '';
    final surname = json['surname']?.toString();
    final fullName = surname != null && surname.isNotEmpty
        ? '$firstName $surname'
        : firstName;
    final points = json['points'] as int?;
    final xp = points ?? json['xp'] as int? ?? 0;
    final level = json['level'] as int? ?? _levelFromXp(xp);
    return UserModel(
      id: json['id'].toString(),
      name: fullName,
      nickname: json['nickname']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      xp: xp,
      level: level,
      avatarColor: json['avatar_color'] as int? ??
          _stableColorFromId(json['id'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'email': email,
      'xp': xp,
      'level': level,
      'avatar_color': avatarColor,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nickname,
    email,
    xp,
    level,
    avatarColor,
  ];

  String get displayName => nickname.isNotEmpty ? nickname : name;

  static int _levelFromXp(int xp) => (xp ~/ 120) + 1;

  static int _stableColorFromId(String id) {
    const palette = [
      0xFF3BA8F8,
      0xFF34D399,
      0xFFFBBF24,
      0xFF818CF8,
      0xFFF472B6,
      0xFF94A3B8,
    ];
    final hash = id.codeUnits.fold<int>(0, (acc, unit) => acc + unit);
    return palette[hash % palette.length];
  }
}
