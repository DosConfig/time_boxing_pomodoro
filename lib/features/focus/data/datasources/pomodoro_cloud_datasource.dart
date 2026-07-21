import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:time_boxing_pomodoro/firebase_options.dart';

import '../../domain/entities/daily_plan_summary.dart';
import '../../domain/entities/pomodoro.dart';
import '../dtos/today_plan_dto.dart';

class PomodoroCloudDataSource {
  static const _usersCollection = 'users';
  static const _daysCollection = 'days';
  static const _planField = 'plan';

  String? _lastAttemptedPlanSignature;

  Future<void> saveTodayPlan(Pomodoro pomodoro, {int? updatedAtEpochMs}) async {
    final ready = await _ensureConfigured();
    if (!ready) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final todayKey = _dateKey(DateTime.now());
    final effectiveUpdatedAt =
        updatedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    final planJson = _planJson(
      pomodoro,
      todayKey,
      updatedAtEpochMs: effectiveUpdatedAt,
    );
    final signature = _signature(user.uid, todayKey, planJson);
    if (signature == _lastAttemptedPlanSignature) {
      return;
    }

    try {
      final clientUpdatedAt = DateTime.fromMillisecondsSinceEpoch(
        effectiveUpdatedAt,
        isUtc: true,
      ).toIso8601String();
      final planData = jsonDecode(planJson);
      final batch = FirebaseFirestore.instance.batch();
      batch.set(_user(user.uid), {
        'lastPlanDateKey': todayKey,
        'latestPlanDateKey': todayKey,
        'latestPlan': planData,
        'clientUpdatedAt': clientUpdatedAt,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      batch.set(_days(user.uid).doc(todayKey), {
        'dateKey': todayKey,
        _planField: planData,
        'clientUpdatedAt': clientUpdatedAt,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
      _lastAttemptedPlanSignature = signature;
    } catch (error) {
      debugPrint('Firestore today plan save failed: $error');
      rethrow;
    }
  }

  Future<Pomodoro?> restoreTodayPlan(Pomodoro fallback) async {
    final dto = await loadTodayPlanDto();
    return dto?.toEntity(fallback);
  }

  Future<TodayPlanDto?> loadTodayPlanDto() async {
    final ready = await _ensureConfigured();
    if (!ready) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final todayKey = _dateKey(DateTime.now());
    try {
      final snapshot = await _days(user.uid).doc(todayKey).get();
      final data = snapshot.data();
      final planData = _jsonMap(data?[_planField]);
      if (planData == null) {
        return null;
      }

      var dto = TodayPlanDto.fromJson(planData);
      if (dto.dateKey != todayKey) {
        return null;
      }

      if (dto.updatedAtEpochMs <= 0) {
        final serverUpdatedAt = data?['updatedAt'];
        if (serverUpdatedAt is Timestamp) {
          dto = dto.copyWith(
            updatedAtEpochMs: serverUpdatedAt.millisecondsSinceEpoch,
          );
        }
      }
      _lastAttemptedPlanSignature = _signature(
        user.uid,
        todayKey,
        jsonEncode(dto.toStorageJson()),
      );
      return dto;
    } catch (error) {
      debugPrint('Firestore today plan restore skipped: $error');
      return null;
    }
  }

  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    final ready = await _ensureConfigured();
    if (!ready) {
      return const [];
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const [];
    }

    final summaries = <DailyPlanSummary>[];
    for (final dateKey in _recentDateKeys(DateTime.now(), days)) {
      try {
        final snapshot = await _days(user.uid).doc(dateKey).get();
        final data = snapshot.data();
        final planData = _jsonMap(data?[_planField]);
        if (planData == null) {
          continue;
        }
        summaries.add(TodayPlanDto.fromJson(planData).toSummary());
      } catch (error) {
        debugPrint('Firestore history item skipped: $error');
      }
    }

    summaries.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return summaries;
  }

  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async {
    final ready = await _ensureConfigured();
    if (!ready) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final todayKey = _dateKey(DateTime.now());
    try {
      final userSnapshot = await _user(user.uid).get();
      final userData = userSnapshot.data();
      final latestDateKey = userData?['latestPlanDateKey']?.toString();
      final latestPlanData = _jsonMap(userData?['latestPlan']);
      if (latestDateKey != null &&
          latestDateKey.compareTo(todayKey) < 0 &&
          latestPlanData != null) {
        return TodayPlanDto.fromJson(latestPlanData).toEntity(fallback);
      }

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final previousKeys = _recentDateKeys(yesterday, 30).reversed;
      for (final dateKey in previousKeys) {
        final snapshot = await _days(user.uid).doc(dateKey).get();
        final data = snapshot.data();
        final planData = _jsonMap(data?[_planField]);
        if (planData == null) {
          continue;
        }
        return TodayPlanDto.fromJson(planData).toEntity(fallback);
      }
    } catch (error) {
      debugPrint('Firestore previous plan restore skipped: $error');
    }

    return null;
  }

  DocumentReference<Map<String, dynamic>> _user(String userId) {
    return FirebaseFirestore.instance.collection(_usersCollection).doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _days(String userId) {
    return _user(userId).collection(_daysCollection);
  }

  Future<bool> _ensureConfigured() async {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (error) {
        debugPrint('Firebase for Firestore is not configured: $error');
        return false;
      }
    }

    return true;
  }

  String _planJson(
    Pomodoro pomodoro,
    String dateKey, {
    required int updatedAtEpochMs,
  }) {
    return jsonEncode(
      TodayPlanDto.fromEntity(
        pomodoro,
        dateKey: dateKey,
        updatedAtEpochMs: updatedAtEpochMs,
      ).toStorageJson(),
    );
  }

  String _signature(String userId, String dateKey, String planJson) {
    return '$userId.$dateKey.$planJson';
  }

  Map<String, dynamic>? _jsonMap(Object? value) {
    if (value is! Map) {
      return null;
    }

    return value.map((key, nestedValue) {
      return MapEntry(key.toString(), _jsonValue(nestedValue));
    });
  }

  Object? _jsonValue(Object? value) {
    if (value is Map) {
      return _jsonMap(value);
    }
    if (value is List) {
      return value.map(_jsonValue).toList();
    }
    return value;
  }

  List<String> _recentDateKeys(DateTime endDate, int days) {
    final safeDays = days < 1 ? 1 : days;
    return List.generate(safeDays, (index) {
      final date = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).subtract(Duration(days: safeDays - index - 1));
      return _dateKey(date);
    });
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
