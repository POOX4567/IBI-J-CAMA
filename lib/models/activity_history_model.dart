class ActivityHistoryModel {
  final int id;
  final String activity;
  final String description;
  final String date;
  final String userName;

  ActivityHistoryModel({
    required this.id,
    required this.activity,
    required this.description,
    required this.date,
    required this.userName,
  });

  factory ActivityHistoryModel.fromJson(Map<String, dynamic> json) {
    return ActivityHistoryModel(
      id: int.parse(json['id'].toString()),
      activity: json['activity']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      userName: json['user']?['name']?.toString() ?? 'Usuario',
    );
  }
}