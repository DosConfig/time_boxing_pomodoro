// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppPreferences {

 bool get isLoaded; bool get onboardingCompleted; int get awakeStartMinutes; int get awakeEndMinutes;
/// Create a copy of AppPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPreferencesCopyWith<AppPreferences> get copyWith => _$AppPreferencesCopyWithImpl<AppPreferences>(this as AppPreferences, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPreferences&&(identical(other.isLoaded, isLoaded) || other.isLoaded == isLoaded)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.awakeStartMinutes, awakeStartMinutes) || other.awakeStartMinutes == awakeStartMinutes)&&(identical(other.awakeEndMinutes, awakeEndMinutes) || other.awakeEndMinutes == awakeEndMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,isLoaded,onboardingCompleted,awakeStartMinutes,awakeEndMinutes);

@override
String toString() {
  return 'AppPreferences(isLoaded: $isLoaded, onboardingCompleted: $onboardingCompleted, awakeStartMinutes: $awakeStartMinutes, awakeEndMinutes: $awakeEndMinutes)';
}


}

/// @nodoc
abstract mixin class $AppPreferencesCopyWith<$Res>  {
  factory $AppPreferencesCopyWith(AppPreferences value, $Res Function(AppPreferences) _then) = _$AppPreferencesCopyWithImpl;
@useResult
$Res call({
 bool isLoaded, bool onboardingCompleted, int awakeStartMinutes, int awakeEndMinutes
});




}
/// @nodoc
class _$AppPreferencesCopyWithImpl<$Res>
    implements $AppPreferencesCopyWith<$Res> {
  _$AppPreferencesCopyWithImpl(this._self, this._then);

  final AppPreferences _self;
  final $Res Function(AppPreferences) _then;

/// Create a copy of AppPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoaded = null,Object? onboardingCompleted = null,Object? awakeStartMinutes = null,Object? awakeEndMinutes = null,}) {
  return _then(_self.copyWith(
isLoaded: null == isLoaded ? _self.isLoaded : isLoaded // ignore: cast_nullable_to_non_nullable
as bool,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,awakeStartMinutes: null == awakeStartMinutes ? _self.awakeStartMinutes : awakeStartMinutes // ignore: cast_nullable_to_non_nullable
as int,awakeEndMinutes: null == awakeEndMinutes ? _self.awakeEndMinutes : awakeEndMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppPreferences].
extension AppPreferencesPatterns on AppPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppPreferences value)  $default,){
final _that = this;
switch (_that) {
case _AppPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _AppPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoaded,  bool onboardingCompleted,  int awakeStartMinutes,  int awakeEndMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppPreferences() when $default != null:
return $default(_that.isLoaded,_that.onboardingCompleted,_that.awakeStartMinutes,_that.awakeEndMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoaded,  bool onboardingCompleted,  int awakeStartMinutes,  int awakeEndMinutes)  $default,) {final _that = this;
switch (_that) {
case _AppPreferences():
return $default(_that.isLoaded,_that.onboardingCompleted,_that.awakeStartMinutes,_that.awakeEndMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoaded,  bool onboardingCompleted,  int awakeStartMinutes,  int awakeEndMinutes)?  $default,) {final _that = this;
switch (_that) {
case _AppPreferences() when $default != null:
return $default(_that.isLoaded,_that.onboardingCompleted,_that.awakeStartMinutes,_that.awakeEndMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _AppPreferences implements AppPreferences {
  const _AppPreferences({this.isLoaded = false, this.onboardingCompleted = false, this.awakeStartMinutes = 7 * 60, this.awakeEndMinutes = 23 * 60});
  

@override@JsonKey() final  bool isLoaded;
@override@JsonKey() final  bool onboardingCompleted;
@override@JsonKey() final  int awakeStartMinutes;
@override@JsonKey() final  int awakeEndMinutes;

/// Create a copy of AppPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppPreferencesCopyWith<_AppPreferences> get copyWith => __$AppPreferencesCopyWithImpl<_AppPreferences>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppPreferences&&(identical(other.isLoaded, isLoaded) || other.isLoaded == isLoaded)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.awakeStartMinutes, awakeStartMinutes) || other.awakeStartMinutes == awakeStartMinutes)&&(identical(other.awakeEndMinutes, awakeEndMinutes) || other.awakeEndMinutes == awakeEndMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,isLoaded,onboardingCompleted,awakeStartMinutes,awakeEndMinutes);

@override
String toString() {
  return 'AppPreferences(isLoaded: $isLoaded, onboardingCompleted: $onboardingCompleted, awakeStartMinutes: $awakeStartMinutes, awakeEndMinutes: $awakeEndMinutes)';
}


}

/// @nodoc
abstract mixin class _$AppPreferencesCopyWith<$Res> implements $AppPreferencesCopyWith<$Res> {
  factory _$AppPreferencesCopyWith(_AppPreferences value, $Res Function(_AppPreferences) _then) = __$AppPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool isLoaded, bool onboardingCompleted, int awakeStartMinutes, int awakeEndMinutes
});




}
/// @nodoc
class __$AppPreferencesCopyWithImpl<$Res>
    implements _$AppPreferencesCopyWith<$Res> {
  __$AppPreferencesCopyWithImpl(this._self, this._then);

  final _AppPreferences _self;
  final $Res Function(_AppPreferences) _then;

/// Create a copy of AppPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoaded = null,Object? onboardingCompleted = null,Object? awakeStartMinutes = null,Object? awakeEndMinutes = null,}) {
  return _then(_AppPreferences(
isLoaded: null == isLoaded ? _self.isLoaded : isLoaded // ignore: cast_nullable_to_non_nullable
as bool,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,awakeStartMinutes: null == awakeStartMinutes ? _self.awakeStartMinutes : awakeStartMinutes // ignore: cast_nullable_to_non_nullable
as int,awakeEndMinutes: null == awakeEndMinutes ? _self.awakeEndMinutes : awakeEndMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
