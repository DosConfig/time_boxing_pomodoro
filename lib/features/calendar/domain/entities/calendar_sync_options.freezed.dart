// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_sync_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarSyncOptions {

 CalendarSyncMode get mode; bool get topPrioritiesOnly; bool get conflictCheck; bool get dedicatedCalendar; bool get includeBreaks;
/// Create a copy of CalendarSyncOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarSyncOptionsCopyWith<CalendarSyncOptions> get copyWith => _$CalendarSyncOptionsCopyWithImpl<CalendarSyncOptions>(this as CalendarSyncOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarSyncOptions&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.topPrioritiesOnly, topPrioritiesOnly) || other.topPrioritiesOnly == topPrioritiesOnly)&&(identical(other.conflictCheck, conflictCheck) || other.conflictCheck == conflictCheck)&&(identical(other.dedicatedCalendar, dedicatedCalendar) || other.dedicatedCalendar == dedicatedCalendar)&&(identical(other.includeBreaks, includeBreaks) || other.includeBreaks == includeBreaks));
}


@override
int get hashCode => Object.hash(runtimeType,mode,topPrioritiesOnly,conflictCheck,dedicatedCalendar,includeBreaks);

@override
String toString() {
  return 'CalendarSyncOptions(mode: $mode, topPrioritiesOnly: $topPrioritiesOnly, conflictCheck: $conflictCheck, dedicatedCalendar: $dedicatedCalendar, includeBreaks: $includeBreaks)';
}


}

/// @nodoc
abstract mixin class $CalendarSyncOptionsCopyWith<$Res>  {
  factory $CalendarSyncOptionsCopyWith(CalendarSyncOptions value, $Res Function(CalendarSyncOptions) _then) = _$CalendarSyncOptionsCopyWithImpl;
@useResult
$Res call({
 CalendarSyncMode mode, bool topPrioritiesOnly, bool conflictCheck, bool dedicatedCalendar, bool includeBreaks
});




}
/// @nodoc
class _$CalendarSyncOptionsCopyWithImpl<$Res>
    implements $CalendarSyncOptionsCopyWith<$Res> {
  _$CalendarSyncOptionsCopyWithImpl(this._self, this._then);

  final CalendarSyncOptions _self;
  final $Res Function(CalendarSyncOptions) _then;

/// Create a copy of CalendarSyncOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? topPrioritiesOnly = null,Object? conflictCheck = null,Object? dedicatedCalendar = null,Object? includeBreaks = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CalendarSyncMode,topPrioritiesOnly: null == topPrioritiesOnly ? _self.topPrioritiesOnly : topPrioritiesOnly // ignore: cast_nullable_to_non_nullable
as bool,conflictCheck: null == conflictCheck ? _self.conflictCheck : conflictCheck // ignore: cast_nullable_to_non_nullable
as bool,dedicatedCalendar: null == dedicatedCalendar ? _self.dedicatedCalendar : dedicatedCalendar // ignore: cast_nullable_to_non_nullable
as bool,includeBreaks: null == includeBreaks ? _self.includeBreaks : includeBreaks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarSyncOptions].
extension CalendarSyncOptionsPatterns on CalendarSyncOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarSyncOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarSyncOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarSyncOptions value)  $default,){
final _that = this;
switch (_that) {
case _CalendarSyncOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarSyncOptions value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarSyncOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarSyncMode mode,  bool topPrioritiesOnly,  bool conflictCheck,  bool dedicatedCalendar,  bool includeBreaks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarSyncOptions() when $default != null:
return $default(_that.mode,_that.topPrioritiesOnly,_that.conflictCheck,_that.dedicatedCalendar,_that.includeBreaks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarSyncMode mode,  bool topPrioritiesOnly,  bool conflictCheck,  bool dedicatedCalendar,  bool includeBreaks)  $default,) {final _that = this;
switch (_that) {
case _CalendarSyncOptions():
return $default(_that.mode,_that.topPrioritiesOnly,_that.conflictCheck,_that.dedicatedCalendar,_that.includeBreaks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarSyncMode mode,  bool topPrioritiesOnly,  bool conflictCheck,  bool dedicatedCalendar,  bool includeBreaks)?  $default,) {final _that = this;
switch (_that) {
case _CalendarSyncOptions() when $default != null:
return $default(_that.mode,_that.topPrioritiesOnly,_that.conflictCheck,_that.dedicatedCalendar,_that.includeBreaks);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarSyncOptions implements CalendarSyncOptions {
  const _CalendarSyncOptions({this.mode = CalendarSyncMode.manual, this.topPrioritiesOnly = false, this.conflictCheck = true, this.dedicatedCalendar = true, this.includeBreaks = false});
  

@override@JsonKey() final  CalendarSyncMode mode;
@override@JsonKey() final  bool topPrioritiesOnly;
@override@JsonKey() final  bool conflictCheck;
@override@JsonKey() final  bool dedicatedCalendar;
@override@JsonKey() final  bool includeBreaks;

/// Create a copy of CalendarSyncOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarSyncOptionsCopyWith<_CalendarSyncOptions> get copyWith => __$CalendarSyncOptionsCopyWithImpl<_CalendarSyncOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarSyncOptions&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.topPrioritiesOnly, topPrioritiesOnly) || other.topPrioritiesOnly == topPrioritiesOnly)&&(identical(other.conflictCheck, conflictCheck) || other.conflictCheck == conflictCheck)&&(identical(other.dedicatedCalendar, dedicatedCalendar) || other.dedicatedCalendar == dedicatedCalendar)&&(identical(other.includeBreaks, includeBreaks) || other.includeBreaks == includeBreaks));
}


@override
int get hashCode => Object.hash(runtimeType,mode,topPrioritiesOnly,conflictCheck,dedicatedCalendar,includeBreaks);

@override
String toString() {
  return 'CalendarSyncOptions(mode: $mode, topPrioritiesOnly: $topPrioritiesOnly, conflictCheck: $conflictCheck, dedicatedCalendar: $dedicatedCalendar, includeBreaks: $includeBreaks)';
}


}

/// @nodoc
abstract mixin class _$CalendarSyncOptionsCopyWith<$Res> implements $CalendarSyncOptionsCopyWith<$Res> {
  factory _$CalendarSyncOptionsCopyWith(_CalendarSyncOptions value, $Res Function(_CalendarSyncOptions) _then) = __$CalendarSyncOptionsCopyWithImpl;
@override @useResult
$Res call({
 CalendarSyncMode mode, bool topPrioritiesOnly, bool conflictCheck, bool dedicatedCalendar, bool includeBreaks
});




}
/// @nodoc
class __$CalendarSyncOptionsCopyWithImpl<$Res>
    implements _$CalendarSyncOptionsCopyWith<$Res> {
  __$CalendarSyncOptionsCopyWithImpl(this._self, this._then);

  final _CalendarSyncOptions _self;
  final $Res Function(_CalendarSyncOptions) _then;

/// Create a copy of CalendarSyncOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? topPrioritiesOnly = null,Object? conflictCheck = null,Object? dedicatedCalendar = null,Object? includeBreaks = null,}) {
  return _then(_CalendarSyncOptions(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CalendarSyncMode,topPrioritiesOnly: null == topPrioritiesOnly ? _self.topPrioritiesOnly : topPrioritiesOnly // ignore: cast_nullable_to_non_nullable
as bool,conflictCheck: null == conflictCheck ? _self.conflictCheck : conflictCheck // ignore: cast_nullable_to_non_nullable
as bool,dedicatedCalendar: null == dedicatedCalendar ? _self.dedicatedCalendar : dedicatedCalendar // ignore: cast_nullable_to_non_nullable
as bool,includeBreaks: null == includeBreaks ? _self.includeBreaks : includeBreaks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
