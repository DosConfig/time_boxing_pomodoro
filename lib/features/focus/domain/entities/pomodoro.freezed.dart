// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pomodoro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimeBox {

 String get id; String get title; String get timeRange; int get durationSeconds;
/// Create a copy of TimeBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeBoxCopyWith<TimeBox> get copyWith => _$TimeBoxCopyWithImpl<TimeBox>(this as TimeBox, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeBox&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,timeRange,durationSeconds);

@override
String toString() {
  return 'TimeBox(id: $id, title: $title, timeRange: $timeRange, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $TimeBoxCopyWith<$Res>  {
  factory $TimeBoxCopyWith(TimeBox value, $Res Function(TimeBox) _then) = _$TimeBoxCopyWithImpl;
@useResult
$Res call({
 String id, String title, String timeRange, int durationSeconds
});




}
/// @nodoc
class _$TimeBoxCopyWithImpl<$Res>
    implements $TimeBoxCopyWith<$Res> {
  _$TimeBoxCopyWithImpl(this._self, this._then);

  final TimeBox _self;
  final $Res Function(TimeBox) _then;

/// Create a copy of TimeBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? timeRange = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeBox].
extension TimeBoxPatterns on TimeBox {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeBox() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeBox value)  $default,){
final _that = this;
switch (_that) {
case _TimeBox():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeBox value)?  $default,){
final _that = this;
switch (_that) {
case _TimeBox() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String timeRange,  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeBox() when $default != null:
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String timeRange,  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _TimeBox():
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String timeRange,  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _TimeBox() when $default != null:
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _TimeBox extends TimeBox {
  const _TimeBox({required this.id, required this.title, required this.timeRange, required this.durationSeconds}): super._();
  

@override final  String id;
@override final  String title;
@override final  String timeRange;
@override final  int durationSeconds;

/// Create a copy of TimeBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeBoxCopyWith<_TimeBox> get copyWith => __$TimeBoxCopyWithImpl<_TimeBox>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeBox&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,timeRange,durationSeconds);

@override
String toString() {
  return 'TimeBox(id: $id, title: $title, timeRange: $timeRange, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$TimeBoxCopyWith<$Res> implements $TimeBoxCopyWith<$Res> {
  factory _$TimeBoxCopyWith(_TimeBox value, $Res Function(_TimeBox) _then) = __$TimeBoxCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String timeRange, int durationSeconds
});




}
/// @nodoc
class __$TimeBoxCopyWithImpl<$Res>
    implements _$TimeBoxCopyWith<$Res> {
  __$TimeBoxCopyWithImpl(this._self, this._then);

  final _TimeBox _self;
  final $Res Function(_TimeBox) _then;

/// Create a copy of TimeBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? timeRange = null,Object? durationSeconds = null,}) {
  return _then(_TimeBox(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TimerSnapshot {

 String get status; int get sessionCount; int get sessionGoal; PomodoroPhase get phase; int get remainingTime; bool get notificationsEnabled; bool get soundEnabled; List<String> get topPriorities; String get currentTimeBoxTitle; String get currentTimeBoxTimeRange;
/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerSnapshotCopyWith<TimerSnapshot> get copyWith => _$TimerSnapshotCopyWithImpl<TimerSnapshot>(this as TimerSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerSnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.sessionGoal, sessionGoal) || other.sessionGoal == sessionGoal)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other.topPriorities, topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange));
}


@override
int get hashCode => Object.hash(runtimeType,status,sessionCount,sessionGoal,phase,remainingTime,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange);

@override
String toString() {
  return 'TimerSnapshot(status: $status, sessionCount: $sessionCount, sessionGoal: $sessionGoal, phase: $phase, remainingTime: $remainingTime, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange)';
}


}

/// @nodoc
abstract mixin class $TimerSnapshotCopyWith<$Res>  {
  factory $TimerSnapshotCopyWith(TimerSnapshot value, $Res Function(TimerSnapshot) _then) = _$TimerSnapshotCopyWithImpl;
@useResult
$Res call({
 String status, int sessionCount, int sessionGoal, PomodoroPhase phase, int remainingTime, bool notificationsEnabled, bool soundEnabled, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange
});




}
/// @nodoc
class _$TimerSnapshotCopyWithImpl<$Res>
    implements $TimerSnapshotCopyWith<$Res> {
  _$TimerSnapshotCopyWithImpl(this._self, this._then);

  final TimerSnapshot _self;
  final $Res Function(TimerSnapshot) _then;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sessionCount = null,Object? sessionGoal = null,Object? phase = null,Object? remainingTime = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessionGoal: null == sessionGoal ? _self.sessionGoal : sessionGoal // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PomodoroPhase,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,topPriorities: null == topPriorities ? _self.topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerSnapshot].
extension TimerSnapshotPatterns on TimerSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TimerSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  int sessionCount,  int sessionGoal,  PomodoroPhase phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that.status,_that.sessionCount,_that.sessionGoal,_that.phase,_that.remainingTime,_that.notificationsEnabled,_that.soundEnabled,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  int sessionCount,  int sessionGoal,  PomodoroPhase phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)  $default,) {final _that = this;
switch (_that) {
case _TimerSnapshot():
return $default(_that.status,_that.sessionCount,_that.sessionGoal,_that.phase,_that.remainingTime,_that.notificationsEnabled,_that.soundEnabled,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  int sessionCount,  int sessionGoal,  PomodoroPhase phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)?  $default,) {final _that = this;
switch (_that) {
case _TimerSnapshot() when $default != null:
return $default(_that.status,_that.sessionCount,_that.sessionGoal,_that.phase,_that.remainingTime,_that.notificationsEnabled,_that.soundEnabled,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange);case _:
  return null;

}
}

}

/// @nodoc


class _TimerSnapshot implements TimerSnapshot {
  const _TimerSnapshot({this.status = 'idle', this.sessionCount = 0, this.sessionGoal = 5, this.phase = PomodoroPhase.focus, this.remainingTime = 25 * 60, this.notificationsEnabled = true, this.soundEnabled = true, final  List<String> topPriorities = const ['', '', ''], this.currentTimeBoxTitle = '', this.currentTimeBoxTimeRange = ''}): _topPriorities = topPriorities;
  

@override@JsonKey() final  String status;
@override@JsonKey() final  int sessionCount;
@override@JsonKey() final  int sessionGoal;
@override@JsonKey() final  PomodoroPhase phase;
@override@JsonKey() final  int remainingTime;
@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool soundEnabled;
 final  List<String> _topPriorities;
@override@JsonKey() List<String> get topPriorities {
  if (_topPriorities is EqualUnmodifiableListView) return _topPriorities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topPriorities);
}

@override@JsonKey() final  String currentTimeBoxTitle;
@override@JsonKey() final  String currentTimeBoxTimeRange;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerSnapshotCopyWith<_TimerSnapshot> get copyWith => __$TimerSnapshotCopyWithImpl<_TimerSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerSnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.sessionGoal, sessionGoal) || other.sessionGoal == sessionGoal)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other._topPriorities, _topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange));
}


@override
int get hashCode => Object.hash(runtimeType,status,sessionCount,sessionGoal,phase,remainingTime,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(_topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange);

@override
String toString() {
  return 'TimerSnapshot(status: $status, sessionCount: $sessionCount, sessionGoal: $sessionGoal, phase: $phase, remainingTime: $remainingTime, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange)';
}


}

/// @nodoc
abstract mixin class _$TimerSnapshotCopyWith<$Res> implements $TimerSnapshotCopyWith<$Res> {
  factory _$TimerSnapshotCopyWith(_TimerSnapshot value, $Res Function(_TimerSnapshot) _then) = __$TimerSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String status, int sessionCount, int sessionGoal, PomodoroPhase phase, int remainingTime, bool notificationsEnabled, bool soundEnabled, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange
});




}
/// @nodoc
class __$TimerSnapshotCopyWithImpl<$Res>
    implements _$TimerSnapshotCopyWith<$Res> {
  __$TimerSnapshotCopyWithImpl(this._self, this._then);

  final _TimerSnapshot _self;
  final $Res Function(_TimerSnapshot) _then;

/// Create a copy of TimerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sessionCount = null,Object? sessionGoal = null,Object? phase = null,Object? remainingTime = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,}) {
  return _then(_TimerSnapshot(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessionGoal: null == sessionGoal ? _self.sessionGoal : sessionGoal // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PomodoroPhase,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,topPriorities: null == topPriorities ? _self._topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Pomodoro {

 int get workDuration; int get breakDuration; int get longBreakDuration; int get sessionsUntilLongBreak; int get remainingTime; int get completedSessions; PomodoroStatus get status; PomodoroPhase get phase; PomodoroPreset get preset; bool get autoStartBreaks; bool get autoStartFocus; bool get notificationsEnabled; bool get soundEnabled; List<String> get brainDump; List<String> get reminders; List<String> get topPriorities; String get currentTimeBoxTitle; String get currentTimeBoxTimeRange; List<TimeBox> get timeBoxes; String get activeTimeBoxId;
/// Create a copy of Pomodoro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PomodoroCopyWith<Pomodoro> get copyWith => _$PomodoroCopyWithImpl<Pomodoro>(this as Pomodoro, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pomodoro&&(identical(other.workDuration, workDuration) || other.workDuration == workDuration)&&(identical(other.breakDuration, breakDuration) || other.breakDuration == breakDuration)&&(identical(other.longBreakDuration, longBreakDuration) || other.longBreakDuration == longBreakDuration)&&(identical(other.sessionsUntilLongBreak, sessionsUntilLongBreak) || other.sessionsUntilLongBreak == sessionsUntilLongBreak)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.status, status) || other.status == status)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.autoStartBreaks, autoStartBreaks) || other.autoStartBreaks == autoStartBreaks)&&(identical(other.autoStartFocus, autoStartFocus) || other.autoStartFocus == autoStartFocus)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other.brainDump, brainDump)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&const DeepCollectionEquality().equals(other.topPriorities, topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange)&&const DeepCollectionEquality().equals(other.timeBoxes, timeBoxes)&&(identical(other.activeTimeBoxId, activeTimeBoxId) || other.activeTimeBoxId == activeTimeBoxId));
}


@override
int get hashCode => Object.hashAll([runtimeType,workDuration,breakDuration,longBreakDuration,sessionsUntilLongBreak,remainingTime,completedSessions,status,phase,preset,autoStartBreaks,autoStartFocus,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(brainDump),const DeepCollectionEquality().hash(reminders),const DeepCollectionEquality().hash(topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange,const DeepCollectionEquality().hash(timeBoxes),activeTimeBoxId]);

@override
String toString() {
  return 'Pomodoro(workDuration: $workDuration, breakDuration: $breakDuration, longBreakDuration: $longBreakDuration, sessionsUntilLongBreak: $sessionsUntilLongBreak, remainingTime: $remainingTime, completedSessions: $completedSessions, status: $status, phase: $phase, preset: $preset, autoStartBreaks: $autoStartBreaks, autoStartFocus: $autoStartFocus, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, brainDump: $brainDump, reminders: $reminders, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange, timeBoxes: $timeBoxes, activeTimeBoxId: $activeTimeBoxId)';
}


}

/// @nodoc
abstract mixin class $PomodoroCopyWith<$Res>  {
  factory $PomodoroCopyWith(Pomodoro value, $Res Function(Pomodoro) _then) = _$PomodoroCopyWithImpl;
@useResult
$Res call({
 int workDuration, int breakDuration, int longBreakDuration, int sessionsUntilLongBreak, int remainingTime, int completedSessions, PomodoroStatus status, PomodoroPhase phase, PomodoroPreset preset, bool autoStartBreaks, bool autoStartFocus, bool notificationsEnabled, bool soundEnabled, List<String> brainDump, List<String> reminders, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange, List<TimeBox> timeBoxes, String activeTimeBoxId
});




}
/// @nodoc
class _$PomodoroCopyWithImpl<$Res>
    implements $PomodoroCopyWith<$Res> {
  _$PomodoroCopyWithImpl(this._self, this._then);

  final Pomodoro _self;
  final $Res Function(Pomodoro) _then;

/// Create a copy of Pomodoro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workDuration = null,Object? breakDuration = null,Object? longBreakDuration = null,Object? sessionsUntilLongBreak = null,Object? remainingTime = null,Object? completedSessions = null,Object? status = null,Object? phase = null,Object? preset = null,Object? autoStartBreaks = null,Object? autoStartFocus = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? brainDump = null,Object? reminders = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,Object? timeBoxes = null,Object? activeTimeBoxId = null,}) {
  return _then(_self.copyWith(
workDuration: null == workDuration ? _self.workDuration : workDuration // ignore: cast_nullable_to_non_nullable
as int,breakDuration: null == breakDuration ? _self.breakDuration : breakDuration // ignore: cast_nullable_to_non_nullable
as int,longBreakDuration: null == longBreakDuration ? _self.longBreakDuration : longBreakDuration // ignore: cast_nullable_to_non_nullable
as int,sessionsUntilLongBreak: null == sessionsUntilLongBreak ? _self.sessionsUntilLongBreak : sessionsUntilLongBreak // ignore: cast_nullable_to_non_nullable
as int,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PomodoroStatus,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PomodoroPhase,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PomodoroPreset,autoStartBreaks: null == autoStartBreaks ? _self.autoStartBreaks : autoStartBreaks // ignore: cast_nullable_to_non_nullable
as bool,autoStartFocus: null == autoStartFocus ? _self.autoStartFocus : autoStartFocus // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,brainDump: null == brainDump ? _self.brainDump : brainDump // ignore: cast_nullable_to_non_nullable
as List<String>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<String>,topPriorities: null == topPriorities ? _self.topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,timeBoxes: null == timeBoxes ? _self.timeBoxes : timeBoxes // ignore: cast_nullable_to_non_nullable
as List<TimeBox>,activeTimeBoxId: null == activeTimeBoxId ? _self.activeTimeBoxId : activeTimeBoxId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Pomodoro].
extension PomodoroPatterns on Pomodoro {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pomodoro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pomodoro() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pomodoro value)  $default,){
final _that = this;
switch (_that) {
case _Pomodoro():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pomodoro value)?  $default,){
final _that = this;
switch (_that) {
case _Pomodoro() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workDuration,  int breakDuration,  int longBreakDuration,  int sessionsUntilLongBreak,  int remainingTime,  int completedSessions,  PomodoroStatus status,  PomodoroPhase phase,  PomodoroPreset preset,  bool autoStartBreaks,  bool autoStartFocus,  bool notificationsEnabled,  bool soundEnabled,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange,  List<TimeBox> timeBoxes,  String activeTimeBoxId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pomodoro() when $default != null:
return $default(_that.workDuration,_that.breakDuration,_that.longBreakDuration,_that.sessionsUntilLongBreak,_that.remainingTime,_that.completedSessions,_that.status,_that.phase,_that.preset,_that.autoStartBreaks,_that.autoStartFocus,_that.notificationsEnabled,_that.soundEnabled,_that.brainDump,_that.reminders,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange,_that.timeBoxes,_that.activeTimeBoxId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workDuration,  int breakDuration,  int longBreakDuration,  int sessionsUntilLongBreak,  int remainingTime,  int completedSessions,  PomodoroStatus status,  PomodoroPhase phase,  PomodoroPreset preset,  bool autoStartBreaks,  bool autoStartFocus,  bool notificationsEnabled,  bool soundEnabled,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange,  List<TimeBox> timeBoxes,  String activeTimeBoxId)  $default,) {final _that = this;
switch (_that) {
case _Pomodoro():
return $default(_that.workDuration,_that.breakDuration,_that.longBreakDuration,_that.sessionsUntilLongBreak,_that.remainingTime,_that.completedSessions,_that.status,_that.phase,_that.preset,_that.autoStartBreaks,_that.autoStartFocus,_that.notificationsEnabled,_that.soundEnabled,_that.brainDump,_that.reminders,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange,_that.timeBoxes,_that.activeTimeBoxId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workDuration,  int breakDuration,  int longBreakDuration,  int sessionsUntilLongBreak,  int remainingTime,  int completedSessions,  PomodoroStatus status,  PomodoroPhase phase,  PomodoroPreset preset,  bool autoStartBreaks,  bool autoStartFocus,  bool notificationsEnabled,  bool soundEnabled,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange,  List<TimeBox> timeBoxes,  String activeTimeBoxId)?  $default,) {final _that = this;
switch (_that) {
case _Pomodoro() when $default != null:
return $default(_that.workDuration,_that.breakDuration,_that.longBreakDuration,_that.sessionsUntilLongBreak,_that.remainingTime,_that.completedSessions,_that.status,_that.phase,_that.preset,_that.autoStartBreaks,_that.autoStartFocus,_that.notificationsEnabled,_that.soundEnabled,_that.brainDump,_that.reminders,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange,_that.timeBoxes,_that.activeTimeBoxId);case _:
  return null;

}
}

}

/// @nodoc


class _Pomodoro extends Pomodoro {
  const _Pomodoro({this.workDuration = 25 * 60, this.breakDuration = 5 * 60, this.longBreakDuration = 15 * 60, this.sessionsUntilLongBreak = 5, this.remainingTime = 25 * 60, this.completedSessions = 0, this.status = PomodoroStatus.idle, this.phase = PomodoroPhase.focus, this.preset = PomodoroPreset.classic, this.autoStartBreaks = true, this.autoStartFocus = false, this.notificationsEnabled = true, this.soundEnabled = true, final  List<String> brainDump = const [], final  List<String> reminders = const [], final  List<String> topPriorities = const ['', '', ''], this.currentTimeBoxTitle = '', this.currentTimeBoxTimeRange = '', final  List<TimeBox> timeBoxes = TimeBox.defaultDay, this.activeTimeBoxId = 'box-0900'}): _brainDump = brainDump,_reminders = reminders,_topPriorities = topPriorities,_timeBoxes = timeBoxes,super._();
  

@override@JsonKey() final  int workDuration;
@override@JsonKey() final  int breakDuration;
@override@JsonKey() final  int longBreakDuration;
@override@JsonKey() final  int sessionsUntilLongBreak;
@override@JsonKey() final  int remainingTime;
@override@JsonKey() final  int completedSessions;
@override@JsonKey() final  PomodoroStatus status;
@override@JsonKey() final  PomodoroPhase phase;
@override@JsonKey() final  PomodoroPreset preset;
@override@JsonKey() final  bool autoStartBreaks;
@override@JsonKey() final  bool autoStartFocus;
@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool soundEnabled;
 final  List<String> _brainDump;
@override@JsonKey() List<String> get brainDump {
  if (_brainDump is EqualUnmodifiableListView) return _brainDump;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_brainDump);
}

 final  List<String> _reminders;
@override@JsonKey() List<String> get reminders {
  if (_reminders is EqualUnmodifiableListView) return _reminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminders);
}

 final  List<String> _topPriorities;
@override@JsonKey() List<String> get topPriorities {
  if (_topPriorities is EqualUnmodifiableListView) return _topPriorities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topPriorities);
}

@override@JsonKey() final  String currentTimeBoxTitle;
@override@JsonKey() final  String currentTimeBoxTimeRange;
 final  List<TimeBox> _timeBoxes;
@override@JsonKey() List<TimeBox> get timeBoxes {
  if (_timeBoxes is EqualUnmodifiableListView) return _timeBoxes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeBoxes);
}

@override@JsonKey() final  String activeTimeBoxId;

/// Create a copy of Pomodoro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PomodoroCopyWith<_Pomodoro> get copyWith => __$PomodoroCopyWithImpl<_Pomodoro>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pomodoro&&(identical(other.workDuration, workDuration) || other.workDuration == workDuration)&&(identical(other.breakDuration, breakDuration) || other.breakDuration == breakDuration)&&(identical(other.longBreakDuration, longBreakDuration) || other.longBreakDuration == longBreakDuration)&&(identical(other.sessionsUntilLongBreak, sessionsUntilLongBreak) || other.sessionsUntilLongBreak == sessionsUntilLongBreak)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.status, status) || other.status == status)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.autoStartBreaks, autoStartBreaks) || other.autoStartBreaks == autoStartBreaks)&&(identical(other.autoStartFocus, autoStartFocus) || other.autoStartFocus == autoStartFocus)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other._brainDump, _brainDump)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&const DeepCollectionEquality().equals(other._topPriorities, _topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange)&&const DeepCollectionEquality().equals(other._timeBoxes, _timeBoxes)&&(identical(other.activeTimeBoxId, activeTimeBoxId) || other.activeTimeBoxId == activeTimeBoxId));
}


@override
int get hashCode => Object.hashAll([runtimeType,workDuration,breakDuration,longBreakDuration,sessionsUntilLongBreak,remainingTime,completedSessions,status,phase,preset,autoStartBreaks,autoStartFocus,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(_brainDump),const DeepCollectionEquality().hash(_reminders),const DeepCollectionEquality().hash(_topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange,const DeepCollectionEquality().hash(_timeBoxes),activeTimeBoxId]);

@override
String toString() {
  return 'Pomodoro(workDuration: $workDuration, breakDuration: $breakDuration, longBreakDuration: $longBreakDuration, sessionsUntilLongBreak: $sessionsUntilLongBreak, remainingTime: $remainingTime, completedSessions: $completedSessions, status: $status, phase: $phase, preset: $preset, autoStartBreaks: $autoStartBreaks, autoStartFocus: $autoStartFocus, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, brainDump: $brainDump, reminders: $reminders, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange, timeBoxes: $timeBoxes, activeTimeBoxId: $activeTimeBoxId)';
}


}

/// @nodoc
abstract mixin class _$PomodoroCopyWith<$Res> implements $PomodoroCopyWith<$Res> {
  factory _$PomodoroCopyWith(_Pomodoro value, $Res Function(_Pomodoro) _then) = __$PomodoroCopyWithImpl;
@override @useResult
$Res call({
 int workDuration, int breakDuration, int longBreakDuration, int sessionsUntilLongBreak, int remainingTime, int completedSessions, PomodoroStatus status, PomodoroPhase phase, PomodoroPreset preset, bool autoStartBreaks, bool autoStartFocus, bool notificationsEnabled, bool soundEnabled, List<String> brainDump, List<String> reminders, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange, List<TimeBox> timeBoxes, String activeTimeBoxId
});




}
/// @nodoc
class __$PomodoroCopyWithImpl<$Res>
    implements _$PomodoroCopyWith<$Res> {
  __$PomodoroCopyWithImpl(this._self, this._then);

  final _Pomodoro _self;
  final $Res Function(_Pomodoro) _then;

/// Create a copy of Pomodoro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workDuration = null,Object? breakDuration = null,Object? longBreakDuration = null,Object? sessionsUntilLongBreak = null,Object? remainingTime = null,Object? completedSessions = null,Object? status = null,Object? phase = null,Object? preset = null,Object? autoStartBreaks = null,Object? autoStartFocus = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? brainDump = null,Object? reminders = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,Object? timeBoxes = null,Object? activeTimeBoxId = null,}) {
  return _then(_Pomodoro(
workDuration: null == workDuration ? _self.workDuration : workDuration // ignore: cast_nullable_to_non_nullable
as int,breakDuration: null == breakDuration ? _self.breakDuration : breakDuration // ignore: cast_nullable_to_non_nullable
as int,longBreakDuration: null == longBreakDuration ? _self.longBreakDuration : longBreakDuration // ignore: cast_nullable_to_non_nullable
as int,sessionsUntilLongBreak: null == sessionsUntilLongBreak ? _self.sessionsUntilLongBreak : sessionsUntilLongBreak // ignore: cast_nullable_to_non_nullable
as int,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PomodoroStatus,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as PomodoroPhase,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PomodoroPreset,autoStartBreaks: null == autoStartBreaks ? _self.autoStartBreaks : autoStartBreaks // ignore: cast_nullable_to_non_nullable
as bool,autoStartFocus: null == autoStartFocus ? _self.autoStartFocus : autoStartFocus // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,brainDump: null == brainDump ? _self._brainDump : brainDump // ignore: cast_nullable_to_non_nullable
as List<String>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<String>,topPriorities: null == topPriorities ? _self._topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,timeBoxes: null == timeBoxes ? _self._timeBoxes : timeBoxes // ignore: cast_nullable_to_non_nullable
as List<TimeBox>,activeTimeBoxId: null == activeTimeBoxId ? _self.activeTimeBoxId : activeTimeBoxId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
