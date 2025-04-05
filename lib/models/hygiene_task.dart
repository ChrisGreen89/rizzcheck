import 'package:equatable/equatable.dart';

class HygieneTask extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  bool isCompleted;

  HygieneTask({
    required this.id,
    required this.title,
    required this.description,
    required this.daysOfWeek,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, title, description, daysOfWeek, isCompleted];

  HygieneTask copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? daysOfWeek,
    bool? isCompleted,
  }) {
    return HygieneTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'daysOfWeek': daysOfWeek,
      'isCompleted': isCompleted,
    };
  }

  factory HygieneTask.fromJson(Map<String, dynamic> json) {
    return HygieneTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      daysOfWeek:
          (json['daysOfWeek'] as List).map((item) => item as int).toList(),
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
