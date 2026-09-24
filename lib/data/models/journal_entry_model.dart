class JournalEntryModel {
  final String id;
  final DateTime date;
  final int energyLevel;
  final String moodWord;
  final String note;
  final double sleepHours;

  const JournalEntryModel({
    required this.id,
    required this.date,
    required this.energyLevel,
    required this.moodWord,
    required this.note,
    this.sleepHours = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'energyLevel': energyLevel,
        'moodWord': moodWord,
        'note': note,
        'sleepHours': sleepHours,
      };

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) =>
      JournalEntryModel(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        energyLevel: json['energyLevel'] as int? ?? 1,
        moodWord: json['moodWord'] as String? ?? '',
        note: json['note'] as String? ?? '',
        sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0.0,
      );
}
