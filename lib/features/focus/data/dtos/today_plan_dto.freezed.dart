// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_plan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeBoxDto {

 String get id; String get title; String get timeRange; int get durationSeconds; List<int> get repeatWeekdays;
/// Create a copy of TimeBoxDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeBoxDtoCopyWith<TimeBoxDto> get copyWith => _$TimeBoxDtoCopyWithImpl<TimeBoxDto>(this as TimeBoxDto, _$identity);

  /// Serializes this TimeBoxDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeBoxDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.repeatWeekdays, repeatWeekdays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,timeRange,durationSeconds,const DeepCollectionEquality().hash(repeatWeekdays));

@override
String toString() {
  return 'TimeBoxDto(id: $id, title: $title, timeRange: $timeRange, durationSeconds: $durationSeconds, repeatWeekdays: $repeatWeekdays)';
}


}

/// @nodoc
abstract mixin class $TimeBoxDtoCopyWith<$Res>  {
  factory $TimeBoxDtoCopyWith(TimeBoxDto value, $Res Function(TimeBoxDto) _then) = _$TimeBoxDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String timeRange, int durationSeconds, List<int> repeatWeekdays
});




}
/// @nodoc
class _$TimeBoxDtoCopyWithImpl<$Res>
    implements $TimeBoxDtoCopyWith<$Res> {
  _$TimeBoxDtoCopyWithImpl(this._self, this._then);

  final TimeBoxDto _self;
  final $Res Function(TimeBoxDto) _then;

/// Create a copy of TimeBoxDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? timeRange = null,Object? durationSeconds = null,Object? repeatWeekdays = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,repeatWeekdays: null == repeatWeekdays ? _self.repeatWeekdays : repeatWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeBoxDto].
extension TimeBoxDtoPatterns on TimeBoxDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeBoxDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeBoxDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeBoxDto value)  $default,){
final _that = this;
switch (_that) {
case _TimeBoxDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeBoxDto value)?  $default,){
final _that = this;
switch (_that) {
case _TimeBoxDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String timeRange,  int durationSeconds,  List<int> repeatWeekdays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeBoxDto() when $default != null:
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds,_that.repeatWeekdays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String timeRange,  int durationSeconds,  List<int> repeatWeekdays)  $default,) {final _that = this;
switch (_that) {
case _TimeBoxDto():
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds,_that.repeatWeekdays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String timeRange,  int durationSeconds,  List<int> repeatWeekdays)?  $default,) {final _that = this;
switch (_that) {
case _TimeBoxDto() when $default != null:
return $default(_that.id,_that.title,_that.timeRange,_that.durationSeconds,_that.repeatWeekdays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeBoxDto extends TimeBoxDto {
  const _TimeBoxDto({this.id = '', this.title = '', this.timeRange = '', this.durationSeconds = 30 * 60, final  List<int> repeatWeekdays = const <int>[]}): _repeatWeekdays = repeatWeekdays,super._();
  factory _TimeBoxDto.fromJson(Map<String, dynamic> json) => _$TimeBoxDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String timeRange;
@override@JsonKey() final  int durationSeconds;
 final  List<int> _repeatWeekdays;
@override@JsonKey() List<int> get repeatWeekdays {
  if (_repeatWeekdays is EqualUnmodifiableListView) return _repeatWeekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repeatWeekdays);
}


/// Create a copy of TimeBoxDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeBoxDtoCopyWith<_TimeBoxDto> get copyWith => __$TimeBoxDtoCopyWithImpl<_TimeBoxDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeBoxDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeBoxDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other._repeatWeekdays, _repeatWeekdays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,timeRange,durationSeconds,const DeepCollectionEquality().hash(_repeatWeekdays));

@override
String toString() {
  return 'TimeBoxDto(id: $id, title: $title, timeRange: $timeRange, durationSeconds: $durationSeconds, repeatWeekdays: $repeatWeekdays)';
}


}

/// @nodoc
abstract mixin class _$TimeBoxDtoCopyWith<$Res> implements $TimeBoxDtoCopyWith<$Res> {
  factory _$TimeBoxDtoCopyWith(_TimeBoxDto value, $Res Function(_TimeBoxDto) _then) = __$TimeBoxDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String timeRange, int durationSeconds, List<int> repeatWeekdays
});




}
/// @nodoc
class __$TimeBoxDtoCopyWithImpl<$Res>
    implements _$TimeBoxDtoCopyWith<$Res> {
  __$TimeBoxDtoCopyWithImpl(this._self, this._then);

  final _TimeBoxDto _self;
  final $Res Function(_TimeBoxDto) _then;

/// Create a copy of TimeBoxDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? timeRange = null,Object? durationSeconds = null,Object? repeatWeekdays = null,}) {
  return _then(_TimeBoxDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,repeatWeekdays: null == repeatWeekdays ? _self._repeatWeekdays : repeatWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$TodayPlanDto {

 int get schemaVersion; String get dateKey; int get updatedAtEpochMs; List<String> get brainDump; List<String> get reminders; List<String> get topPriorities; List<TimeBoxDto> get timeBoxes; String get activeTimeBoxId; int get completedSessions;
/// Create a copy of TodayPlanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayPlanDtoCopyWith<TodayPlanDto> get copyWith => _$TodayPlanDtoCopyWithImpl<TodayPlanDto>(this as TodayPlanDto, _$identity);

  /// Serializes this TodayPlanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayPlanDto&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs)&&const DeepCollectionEquality().equals(other.brainDump, brainDump)&&const DeepCollectionEquality().equals(other.reminders, reminders)&&const DeepCollectionEquality().equals(other.topPriorities, topPriorities)&&const DeepCollectionEquality().equals(other.timeBoxes, timeBoxes)&&(identical(other.activeTimeBoxId, activeTimeBoxId) || other.activeTimeBoxId == activeTimeBoxId)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,dateKey,updatedAtEpochMs,const DeepCollectionEquality().hash(brainDump),const DeepCollectionEquality().hash(reminders),const DeepCollectionEquality().hash(topPriorities),const DeepCollectionEquality().hash(timeBoxes),activeTimeBoxId,completedSessions);

@override
String toString() {
  return 'TodayPlanDto(schemaVersion: $schemaVersion, dateKey: $dateKey, updatedAtEpochMs: $updatedAtEpochMs, brainDump: $brainDump, reminders: $reminders, topPriorities: $topPriorities, timeBoxes: $timeBoxes, activeTimeBoxId: $activeTimeBoxId, completedSessions: $completedSessions)';
}


}

/// @nodoc
abstract mixin class $TodayPlanDtoCopyWith<$Res>  {
  factory $TodayPlanDtoCopyWith(TodayPlanDto value, $Res Function(TodayPlanDto) _then) = _$TodayPlanDtoCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String dateKey, int updatedAtEpochMs, List<String> brainDump, List<String> reminders, List<String> topPriorities, List<TimeBoxDto> timeBoxes, String activeTimeBoxId, int completedSessions
});




}
/// @nodoc
class _$TodayPlanDtoCopyWithImpl<$Res>
    implements $TodayPlanDtoCopyWith<$Res> {
  _$TodayPlanDtoCopyWithImpl(this._self, this._then);

  final TodayPlanDto _self;
  final $Res Function(TodayPlanDto) _then;

/// Create a copy of TodayPlanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? dateKey = null,Object? updatedAtEpochMs = null,Object? brainDump = null,Object? reminders = null,Object? topPriorities = null,Object? timeBoxes = null,Object? activeTimeBoxId = null,Object? completedSessions = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,brainDump: null == brainDump ? _self.brainDump : brainDump // ignore: cast_nullable_to_non_nullable
as List<String>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<String>,topPriorities: null == topPriorities ? _self.topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,timeBoxes: null == timeBoxes ? _self.timeBoxes : timeBoxes // ignore: cast_nullable_to_non_nullable
as List<TimeBoxDto>,activeTimeBoxId: null == activeTimeBoxId ? _self.activeTimeBoxId : activeTimeBoxId // ignore: cast_nullable_to_non_nullable
as String,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayPlanDto].
extension TodayPlanDtoPatterns on TodayPlanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayPlanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayPlanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayPlanDto value)  $default,){
final _that = this;
switch (_that) {
case _TodayPlanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayPlanDto value)?  $default,){
final _that = this;
switch (_that) {
case _TodayPlanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String dateKey,  int updatedAtEpochMs,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  List<TimeBoxDto> timeBoxes,  String activeTimeBoxId,  int completedSessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayPlanDto() when $default != null:
return $default(_that.schemaVersion,_that.dateKey,_that.updatedAtEpochMs,_that.brainDump,_that.reminders,_that.topPriorities,_that.timeBoxes,_that.activeTimeBoxId,_that.completedSessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String dateKey,  int updatedAtEpochMs,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  List<TimeBoxDto> timeBoxes,  String activeTimeBoxId,  int completedSessions)  $default,) {final _that = this;
switch (_that) {
case _TodayPlanDto():
return $default(_that.schemaVersion,_that.dateKey,_that.updatedAtEpochMs,_that.brainDump,_that.reminders,_that.topPriorities,_that.timeBoxes,_that.activeTimeBoxId,_that.completedSessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String dateKey,  int updatedAtEpochMs,  List<String> brainDump,  List<String> reminders,  List<String> topPriorities,  List<TimeBoxDto> timeBoxes,  String activeTimeBoxId,  int completedSessions)?  $default,) {final _that = this;
switch (_that) {
case _TodayPlanDto() when $default != null:
return $default(_that.schemaVersion,_that.dateKey,_that.updatedAtEpochMs,_that.brainDump,_that.reminders,_that.topPriorities,_that.timeBoxes,_that.activeTimeBoxId,_that.completedSessions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayPlanDto extends TodayPlanDto {
  const _TodayPlanDto({this.schemaVersion = 1, this.dateKey = '', this.updatedAtEpochMs = 0, final  List<String> brainDump = const <String>[], final  List<String> reminders = const <String>[], final  List<String> topPriorities = const <String>['', '', ''], final  List<TimeBoxDto> timeBoxes = const <TimeBoxDto>[], this.activeTimeBoxId = '', this.completedSessions = 0}): _brainDump = brainDump,_reminders = reminders,_topPriorities = topPriorities,_timeBoxes = timeBoxes,super._();
  factory _TodayPlanDto.fromJson(Map<String, dynamic> json) => _$TodayPlanDtoFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  String dateKey;
@override@JsonKey() final  int updatedAtEpochMs;
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

 final  List<TimeBoxDto> _timeBoxes;
@override@JsonKey() List<TimeBoxDto> get timeBoxes {
  if (_timeBoxes is EqualUnmodifiableListView) return _timeBoxes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeBoxes);
}

@override@JsonKey() final  String activeTimeBoxId;
@override@JsonKey() final  int completedSessions;

/// Create a copy of TodayPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayPlanDtoCopyWith<_TodayPlanDto> get copyWith => __$TodayPlanDtoCopyWithImpl<_TodayPlanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayPlanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayPlanDto&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs)&&const DeepCollectionEquality().equals(other._brainDump, _brainDump)&&const DeepCollectionEquality().equals(other._reminders, _reminders)&&const DeepCollectionEquality().equals(other._topPriorities, _topPriorities)&&const DeepCollectionEquality().equals(other._timeBoxes, _timeBoxes)&&(identical(other.activeTimeBoxId, activeTimeBoxId) || other.activeTimeBoxId == activeTimeBoxId)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,dateKey,updatedAtEpochMs,const DeepCollectionEquality().hash(_brainDump),const DeepCollectionEquality().hash(_reminders),const DeepCollectionEquality().hash(_topPriorities),const DeepCollectionEquality().hash(_timeBoxes),activeTimeBoxId,completedSessions);

@override
String toString() {
  return 'TodayPlanDto(schemaVersion: $schemaVersion, dateKey: $dateKey, updatedAtEpochMs: $updatedAtEpochMs, brainDump: $brainDump, reminders: $reminders, topPriorities: $topPriorities, timeBoxes: $timeBoxes, activeTimeBoxId: $activeTimeBoxId, completedSessions: $completedSessions)';
}


}

/// @nodoc
abstract mixin class _$TodayPlanDtoCopyWith<$Res> implements $TodayPlanDtoCopyWith<$Res> {
  factory _$TodayPlanDtoCopyWith(_TodayPlanDto value, $Res Function(_TodayPlanDto) _then) = __$TodayPlanDtoCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String dateKey, int updatedAtEpochMs, List<String> brainDump, List<String> reminders, List<String> topPriorities, List<TimeBoxDto> timeBoxes, String activeTimeBoxId, int completedSessions
});




}
/// @nodoc
class __$TodayPlanDtoCopyWithImpl<$Res>
    implements _$TodayPlanDtoCopyWith<$Res> {
  __$TodayPlanDtoCopyWithImpl(this._self, this._then);

  final _TodayPlanDto _self;
  final $Res Function(_TodayPlanDto) _then;

/// Create a copy of TodayPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? dateKey = null,Object? updatedAtEpochMs = null,Object? brainDump = null,Object? reminders = null,Object? topPriorities = null,Object? timeBoxes = null,Object? activeTimeBoxId = null,Object? completedSessions = null,}) {
  return _then(_TodayPlanDto(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,brainDump: null == brainDump ? _self._brainDump : brainDump // ignore: cast_nullable_to_non_nullable
as List<String>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<String>,topPriorities: null == topPriorities ? _self._topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,timeBoxes: null == timeBoxes ? _self._timeBoxes : timeBoxes // ignore: cast_nullable_to_non_nullable
as List<TimeBoxDto>,activeTimeBoxId: null == activeTimeBoxId ? _self.activeTimeBoxId : activeTimeBoxId // ignore: cast_nullable_to_non_nullable
as String,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
