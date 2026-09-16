/// Immutable model representing a selected routine item.
class RoutineItem {
  final String key;
  final String title;
  final String duration;
  final String type; // 'movement' or 'wellness'

  const RoutineItem({
    required this.key,
    required this.title,
    required this.duration,
    required this.type,
  });

  Map<String, String> toMap() => {
        'key': key,
        'title': title,
        'duration': duration,
        'type': type,
      };

  factory RoutineItem.fromMap(Map<String, String> map) => RoutineItem(
        key: map['key'] ?? '',
        title: map['title'] ?? '',
        duration: map['duration'] ?? '',
        type: map['type'] ?? 'movement',
      );
}

/// Centralized configuration and mutation helpers for routine building.
class SystemsRoutineManager {
  SystemsRoutineManager._();

  static const Map<String, Map<String, String>> movementConfigs = {
    'Run': {'title': 'Running', 'duration': '30 min.'},
    'Wlk': {'title': 'Walking', 'duration': '30 min.'},
    'Cyc': {'title': 'Cycling', 'duration': '45 min.'},
    'Str': {'title': 'Strength', 'duration': '45 min.'},
    'Hlt': {'title': 'HIIT', 'duration': '30 min.'},
    'Row': {'title': 'Rowing', 'duration': '20 min.'},
    'Swm': {'title': 'Swimming', 'duration': '45 min.'},
    'Yga': {'title': 'Yoga', 'duration': '45 min.'},
    'Pil': {'title': 'Pilates', 'duration': '40 min.'},
    'Mob': {'title': 'Mobility', 'duration': '20 min.'},
  };

  static const Map<String, Map<String, String>> wellnessConfigs = {
    'Mobile Flow': {'title': 'Mobility flow', 'duration': '30 min.'},
    'Foam roll': {'title': 'Foam roll', 'duration': '15 min.'},
    'Sleep wind': {'title': 'Sleep wind-down', 'duration': '15 min.'},
    'Box breathing': {'title': 'Box breathing', 'duration': '10 min.'},
    'Meditation': {'title': 'Meditation', 'duration': '15 min.'},
  };

  /// Computes toggled movements and routine list without side-effects.
  static ({Set<String> movements, List<Map<String, String>> routines})
      toggleMovement({
    required String key,
    required Set<String> currentMovements,
    required List<Map<String, String>> currentRoutines,
  }) {
    final movementSet = Set<String>.from(currentMovements);
    final routineList = List<Map<String, String>>.from(currentRoutines);

    if (movementSet.contains(key)) {
      movementSet.remove(key);
      routineList.removeWhere(
        (item) => item['key'] == key && item['type'] == 'movement',
      );
    } else {
      movementSet.add(key);
      final config =
          movementConfigs[key] ?? {'title': key, 'duration': '30 min.'};
      routineList.add({
        'key': key,
        'title': config['title']!,
        'duration': config['duration']!,
        'type': 'movement',
      });
    }

    return (movements: movementSet, routines: routineList);
  }

  /// Computes toggled wellness and routine list without side-effects.
  static ({Set<String> wellness, List<Map<String, String>> routines})
      toggleWellness({
    required String key,
    required Set<String> currentWellness,
    required List<Map<String, String>> currentRoutines,
  }) {
    final wellnessSet = Set<String>.from(currentWellness);
    final routineList = List<Map<String, String>>.from(currentRoutines);

    if (wellnessSet.contains(key)) {
      wellnessSet.remove(key);
      routineList.removeWhere(
        (item) => item['key'] == key && item['type'] == 'wellness',
      );
    } else {
      wellnessSet.add(key);
      final config =
          wellnessConfigs[key] ?? {'title': key, 'duration': '15 min.'};
      routineList.add({
        'key': key,
        'title': config['title']!,
        'duration': config['duration']!,
        'type': 'wellness',
      });
    }

    return (wellness: wellnessSet, routines: routineList);
  }

  /// Removes a routine item by index and deselects its corresponding chip.
  static ({
    Set<String> movements,
    Set<String> wellness,
    List<Map<String, String>> routines,
  }) removeRoutineItem({
    required int index,
    required Set<String> currentMovements,
    required Set<String> currentWellness,
    required List<Map<String, String>> currentRoutines,
  }) {
    final routineList = List<Map<String, String>>.from(currentRoutines);
    final movementSet = Set<String>.from(currentMovements);
    final wellnessSet = Set<String>.from(currentWellness);

    if (index >= 0 && index < routineList.length) {
      final removed = routineList.removeAt(index);
      final key = removed['key'];
      final type = removed['type'];

      if (key != null) {
        if (type == 'movement') {
          movementSet.remove(key);
        } else if (type == 'wellness') {
          wellnessSet.remove(key);
        }
      }
    }

    return (
      movements: movementSet,
      wellness: wellnessSet,
      routines: routineList,
    );
  }
}
