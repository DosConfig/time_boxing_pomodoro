// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_timer_state_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NativeTimerStateDto {

 String get status; int get sessionCount; int get sessionGoal; String get phase; int get remainingTime; bool get notificationsEnabled; bool get soundEnabled; List<String> get topPriorities; String get currentTimeBoxTitle; String get currentTimeBoxTimeRange;
/// Create a copy of NativeTimerStateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeTimerStateDtoCopyWith<NativeTimerStateDto> get copyWith => _$NativeTimerStateDtoCopyWithImpl<NativeTimerStateDto>(this as NativeTimerStateDto, _$identity);

  /// Serializes this NativeTimerStateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeTimerStateDto&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.sessionGoal, sessionGoal) || other.sessionGoal == sessionGoal)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other.topPriorities, topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,sessionCount,sessionGoal,phase,remainingTime,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange);

@override
String toString() {
  return 'NativeTimerStateDto(status: $status, sessionCount: $sessionCount, sessionGoal: $sessionGoal, phase: $phase, remainingTime: $remainingTime, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange)';
}


}

/// @nodoc
abstract mixin class $NativeTimerStateDtoCopyWith<$Res>  {
  factory $NativeTimerStateDtoCopyWith(NativeTimerStateDto value, $Res Function(NativeTimerStateDto) _then) = _$NativeTimerStateDtoCopyWithImpl;
@useResult
$Res call({
 String status, int sessionCount, int sessionGoal, String phase, int remainingTime, bool notificationsEnabled, bool soundEnabled, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange
});




}
/// @nodoc
class _$NativeTimerStateDtoCopyWithImpl<$Res>
    implements $NativeTimerStateDtoCopyWith<$Res> {
  _$NativeTimerStateDtoCopyWithImpl(this._self, this._then);

  final NativeTimerStateDto _self;
  final $Res Function(NativeTimerStateDto) _then;

/// Create a copy of NativeTimerStateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sessionCount = null,Object? sessionGoal = null,Object? phase = null,Object? remainingTime = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessionGoal: null == sessionGoal ? _self.sessionGoal : sessionGoal // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,topPriorities: null == topPriorities ? _self.topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeTimerStateDto].
extension NativeTimerStateDtoPatterns on NativeTimerStateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeTimerStateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeTimerStateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeTimerStateDto value)  $default,){
final _that = this;
switch (_that) {
case _NativeTimerStateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeTimerStateDto value)?  $default,){
final _that = this;
switch (_that) {
case _NativeTimerStateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  int sessionCount,  int sessionGoal,  String phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeTimerStateDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  int sessionCount,  int sessionGoal,  String phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)  $default,) {final _that = this;
switch (_that) {
case _NativeTimerStateDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  int sessionCount,  int sessionGoal,  String phase,  int remainingTime,  bool notificationsEnabled,  bool soundEnabled,  List<String> topPriorities,  String currentTimeBoxTitle,  String currentTimeBoxTimeRange)?  $default,) {final _that = this;
switch (_that) {
case _NativeTimerStateDto() when $default != null:
return $default(_that.status,_that.sessionCount,_that.sessionGoal,_that.phase,_that.remainingTime,_that.notificationsEnabled,_that.soundEnabled,_that.topPriorities,_that.currentTimeBoxTitle,_that.currentTimeBoxTimeRange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NativeTimerStateDto extends NativeTimerStateDto {
  const _NativeTimerStateDto({this.status = 'idle', this.sessionCount = 0, this.sessionGoal = 5, this.phase = 'focus', this.remainingTime = 25 * 60, this.notificationsEnabled = true, this.soundEnabled = true, final  List<String> topPriorities = const <String>[], this.currentTimeBoxTitle = '', this.currentTimeBoxTimeRange = ''}): _topPriorities = topPriorities,super._();
  factory _NativeTimerStateDto.fromJson(Map<String, dynamic> json) => _$NativeTimerStateDtoFromJson(json);

@override@JsonKey() final  String status;
@override@JsonKey() final  int sessionCount;
@override@JsonKey() final  int sessionGoal;
@override@JsonKey() final  String phase;
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

/// Create a copy of NativeTimerStateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeTimerStateDtoCopyWith<_NativeTimerStateDto> get copyWith => __$NativeTimerStateDtoCopyWithImpl<_NativeTimerStateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NativeTimerStateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeTimerStateDto&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.sessionGoal, sessionGoal) || other.sessionGoal == sessionGoal)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&const DeepCollectionEquality().equals(other._topPriorities, _topPriorities)&&(identical(other.currentTimeBoxTitle, currentTimeBoxTitle) || other.currentTimeBoxTitle == currentTimeBoxTitle)&&(identical(other.currentTimeBoxTimeRange, currentTimeBoxTimeRange) || other.currentTimeBoxTimeRange == currentTimeBoxTimeRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,sessionCount,sessionGoal,phase,remainingTime,notificationsEnabled,soundEnabled,const DeepCollectionEquality().hash(_topPriorities),currentTimeBoxTitle,currentTimeBoxTimeRange);

@override
String toString() {
  return 'NativeTimerStateDto(status: $status, sessionCount: $sessionCount, sessionGoal: $sessionGoal, phase: $phase, remainingTime: $remainingTime, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, topPriorities: $topPriorities, currentTimeBoxTitle: $currentTimeBoxTitle, currentTimeBoxTimeRange: $currentTimeBoxTimeRange)';
}


}

/// @nodoc
abstract mixin class _$NativeTimerStateDtoCopyWith<$Res> implements $NativeTimerStateDtoCopyWith<$Res> {
  factory _$NativeTimerStateDtoCopyWith(_NativeTimerStateDto value, $Res Function(_NativeTimerStateDto) _then) = __$NativeTimerStateDtoCopyWithImpl;
@override @useResult
$Res call({
 String status, int sessionCount, int sessionGoal, String phase, int remainingTime, bool notificationsEnabled, bool soundEnabled, List<String> topPriorities, String currentTimeBoxTitle, String currentTimeBoxTimeRange
});




}
/// @nodoc
class __$NativeTimerStateDtoCopyWithImpl<$Res>
    implements _$NativeTimerStateDtoCopyWith<$Res> {
  __$NativeTimerStateDtoCopyWithImpl(this._self, this._then);

  final _NativeTimerStateDto _self;
  final $Res Function(_NativeTimerStateDto) _then;

/// Create a copy of NativeTimerStateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sessionCount = null,Object? sessionGoal = null,Object? phase = null,Object? remainingTime = null,Object? notificationsEnabled = null,Object? soundEnabled = null,Object? topPriorities = null,Object? currentTimeBoxTitle = null,Object? currentTimeBoxTimeRange = null,}) {
  return _then(_NativeTimerStateDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessionGoal: null == sessionGoal ? _self.sessionGoal : sessionGoal // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,topPriorities: null == topPriorities ? _self._topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,currentTimeBoxTitle: null == currentTimeBoxTitle ? _self.currentTimeBoxTitle : currentTimeBoxTitle // ignore: cast_nullable_to_non_nullable
as String,currentTimeBoxTimeRange: null == currentTimeBoxTimeRange ? _self.currentTimeBoxTimeRange : currentTimeBoxTimeRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
