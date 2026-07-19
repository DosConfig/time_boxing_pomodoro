// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_plan_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyPlanSummary {

 String get dateKey; int get priorityCount; int get plannedBoxCount; int get completedBoxCount;
/// Create a copy of DailyPlanSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyPlanSummaryCopyWith<DailyPlanSummary> get copyWith => _$DailyPlanSummaryCopyWithImpl<DailyPlanSummary>(this as DailyPlanSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyPlanSummary&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.priorityCount, priorityCount) || other.priorityCount == priorityCount)&&(identical(other.plannedBoxCount, plannedBoxCount) || other.plannedBoxCount == plannedBoxCount)&&(identical(other.completedBoxCount, completedBoxCount) || other.completedBoxCount == completedBoxCount));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,priorityCount,plannedBoxCount,completedBoxCount);

@override
String toString() {
  return 'DailyPlanSummary(dateKey: $dateKey, priorityCount: $priorityCount, plannedBoxCount: $plannedBoxCount, completedBoxCount: $completedBoxCount)';
}


}

/// @nodoc
abstract mixin class $DailyPlanSummaryCopyWith<$Res>  {
  factory $DailyPlanSummaryCopyWith(DailyPlanSummary value, $Res Function(DailyPlanSummary) _then) = _$DailyPlanSummaryCopyWithImpl;
@useResult
$Res call({
 String dateKey, int priorityCount, int plannedBoxCount, int completedBoxCount
});




}
/// @nodoc
class _$DailyPlanSummaryCopyWithImpl<$Res>
    implements $DailyPlanSummaryCopyWith<$Res> {
  _$DailyPlanSummaryCopyWithImpl(this._self, this._then);

  final DailyPlanSummary _self;
  final $Res Function(DailyPlanSummary) _then;

/// Create a copy of DailyPlanSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? priorityCount = null,Object? plannedBoxCount = null,Object? completedBoxCount = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,priorityCount: null == priorityCount ? _self.priorityCount : priorityCount // ignore: cast_nullable_to_non_nullable
as int,plannedBoxCount: null == plannedBoxCount ? _self.plannedBoxCount : plannedBoxCount // ignore: cast_nullable_to_non_nullable
as int,completedBoxCount: null == completedBoxCount ? _self.completedBoxCount : completedBoxCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyPlanSummary].
extension DailyPlanSummaryPatterns on DailyPlanSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyPlanSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyPlanSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyPlanSummary value)  $default,){
final _that = this;
switch (_that) {
case _DailyPlanSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyPlanSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailyPlanSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  int priorityCount,  int plannedBoxCount,  int completedBoxCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyPlanSummary() when $default != null:
return $default(_that.dateKey,_that.priorityCount,_that.plannedBoxCount,_that.completedBoxCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  int priorityCount,  int plannedBoxCount,  int completedBoxCount)  $default,) {final _that = this;
switch (_that) {
case _DailyPlanSummary():
return $default(_that.dateKey,_that.priorityCount,_that.plannedBoxCount,_that.completedBoxCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  int priorityCount,  int plannedBoxCount,  int completedBoxCount)?  $default,) {final _that = this;
switch (_that) {
case _DailyPlanSummary() when $default != null:
return $default(_that.dateKey,_that.priorityCount,_that.plannedBoxCount,_that.completedBoxCount);case _:
  return null;

}
}

}

/// @nodoc


class _DailyPlanSummary extends DailyPlanSummary {
  const _DailyPlanSummary({required this.dateKey, this.priorityCount = 0, this.plannedBoxCount = 0, this.completedBoxCount = 0}): super._();
  

@override final  String dateKey;
@override@JsonKey() final  int priorityCount;
@override@JsonKey() final  int plannedBoxCount;
@override@JsonKey() final  int completedBoxCount;

/// Create a copy of DailyPlanSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyPlanSummaryCopyWith<_DailyPlanSummary> get copyWith => __$DailyPlanSummaryCopyWithImpl<_DailyPlanSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyPlanSummary&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.priorityCount, priorityCount) || other.priorityCount == priorityCount)&&(identical(other.plannedBoxCount, plannedBoxCount) || other.plannedBoxCount == plannedBoxCount)&&(identical(other.completedBoxCount, completedBoxCount) || other.completedBoxCount == completedBoxCount));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,priorityCount,plannedBoxCount,completedBoxCount);

@override
String toString() {
  return 'DailyPlanSummary(dateKey: $dateKey, priorityCount: $priorityCount, plannedBoxCount: $plannedBoxCount, completedBoxCount: $completedBoxCount)';
}


}

/// @nodoc
abstract mixin class _$DailyPlanSummaryCopyWith<$Res> implements $DailyPlanSummaryCopyWith<$Res> {
  factory _$DailyPlanSummaryCopyWith(_DailyPlanSummary value, $Res Function(_DailyPlanSummary) _then) = __$DailyPlanSummaryCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, int priorityCount, int plannedBoxCount, int completedBoxCount
});




}
/// @nodoc
class __$DailyPlanSummaryCopyWithImpl<$Res>
    implements _$DailyPlanSummaryCopyWith<$Res> {
  __$DailyPlanSummaryCopyWithImpl(this._self, this._then);

  final _DailyPlanSummary _self;
  final $Res Function(_DailyPlanSummary) _then;

/// Create a copy of DailyPlanSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? priorityCount = null,Object? plannedBoxCount = null,Object? completedBoxCount = null,}) {
  return _then(_DailyPlanSummary(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,priorityCount: null == priorityCount ? _self.priorityCount : priorityCount // ignore: cast_nullable_to_non_nullable
as int,plannedBoxCount: null == plannedBoxCount ? _self.plannedBoxCount : plannedBoxCount // ignore: cast_nullable_to_non_nullable
as int,completedBoxCount: null == completedBoxCount ? _self.completedBoxCount : completedBoxCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
