import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:time_boxing_pomodoro/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  patrolTest('first launch shows intro onboarding', ($) async {
    // 시뮬레이터 시스템 언어와 무관하게 영어 문자열을 검증하도록 로케일 고정.
    SharedPreferences.setMockInitialValues({'app.localeCode': 'en'});

    await $.pumpWidgetAndSettle(const ProviderScope(child: MyApp()));

    expect($('Empty your head'), findsOneWidget);

    await $('Next').tap();
    expect($('Pick the top three'), findsOneWidget);
  });
}
