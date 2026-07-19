// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_export_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarExportItemDto {

 String get timeBoxId; String get title; int get startAtMillis; int get endAtMillis; String get notes;
/// Create a copy of CalendarExportItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarExportItemDtoCopyWith<CalendarExportItemDto> get copyWith => _$CalendarExportItemDtoCopyWithImpl<CalendarExportItemDto>(this as CalendarExportItemDto, _$identity);

  /// Serializes this CalendarExportItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarExportItemDto&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAtMillis, startAtMillis) || other.startAtMillis == startAtMillis)&&(identical(other.endAtMillis, endAtMillis) || other.endAtMillis == endAtMillis)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeBoxId,title,startAtMillis,endAtMillis,notes);

@override
String toString() {
  return 'CalendarExportItemDto(timeBoxId: $timeBoxId, title: $title, startAtMillis: $startAtMillis, endAtMillis: $endAtMillis, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CalendarExportItemDtoCopyWith<$Res>  {
  factory $CalendarExportItemDtoCopyWith(CalendarExportItemDto value, $Res Function(CalendarExportItemDto) _then) = _$CalendarExportItemDtoCopyWithImpl;
@useResult
$Res call({
 String timeBoxId, String title, int startAtMillis, int endAtMillis, String notes
});




}
/// @nodoc
class _$CalendarExportItemDtoCopyWithImpl<$Res>
    implements $CalendarExportItemDtoCopyWith<$Res> {
  _$CalendarExportItemDtoCopyWithImpl(this._self, this._then);

  final CalendarExportItemDto _self;
  final $Res Function(CalendarExportItemDto) _then;

/// Create a copy of CalendarExportItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeBoxId = null,Object? title = null,Object? startAtMillis = null,Object? endAtMillis = null,Object? notes = null,}) {
  return _then(_self.copyWith(
timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAtMillis: null == startAtMillis ? _self.startAtMillis : startAtMillis // ignore: cast_nullable_to_non_nullable
as int,endAtMillis: null == endAtMillis ? _self.endAtMillis : endAtMillis // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarExportItemDto].
extension CalendarExportItemDtoPatterns on CalendarExportItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarExportItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarExportItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarExportItemDto value)  $default,){
final _that = this;
switch (_that) {
case _CalendarExportItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarExportItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarExportItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String timeBoxId,  String title,  int startAtMillis,  int endAtMillis,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarExportItemDto() when $default != null:
return $default(_that.timeBoxId,_that.title,_that.startAtMillis,_that.endAtMillis,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String timeBoxId,  String title,  int startAtMillis,  int endAtMillis,  String notes)  $default,) {final _that = this;
switch (_that) {
case _CalendarExportItemDto():
return $default(_that.timeBoxId,_that.title,_that.startAtMillis,_that.endAtMillis,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String timeBoxId,  String title,  int startAtMillis,  int endAtMillis,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _CalendarExportItemDto() when $default != null:
return $default(_that.timeBoxId,_that.title,_that.startAtMillis,_that.endAtMillis,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarExportItemDto extends CalendarExportItemDto {
  const _CalendarExportItemDto({required this.timeBoxId, required this.title, required this.startAtMillis, required this.endAtMillis, this.notes = ''}): super._();
  factory _CalendarExportItemDto.fromJson(Map<String, dynamic> json) => _$CalendarExportItemDtoFromJson(json);

@override final  String timeBoxId;
@override final  String title;
@override final  int startAtMillis;
@override final  int endAtMillis;
@override@JsonKey() final  String notes;

/// Create a copy of CalendarExportItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarExportItemDtoCopyWith<_CalendarExportItemDto> get copyWith => __$CalendarExportItemDtoCopyWithImpl<_CalendarExportItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarExportItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarExportItemDto&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAtMillis, startAtMillis) || other.startAtMillis == startAtMillis)&&(identical(other.endAtMillis, endAtMillis) || other.endAtMillis == endAtMillis)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeBoxId,title,startAtMillis,endAtMillis,notes);

@override
String toString() {
  return 'CalendarExportItemDto(timeBoxId: $timeBoxId, title: $title, startAtMillis: $startAtMillis, endAtMillis: $endAtMillis, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CalendarExportItemDtoCopyWith<$Res> implements $CalendarExportItemDtoCopyWith<$Res> {
  factory _$CalendarExportItemDtoCopyWith(_CalendarExportItemDto value, $Res Function(_CalendarExportItemDto) _then) = __$CalendarExportItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String timeBoxId, String title, int startAtMillis, int endAtMillis, String notes
});




}
/// @nodoc
class __$CalendarExportItemDtoCopyWithImpl<$Res>
    implements _$CalendarExportItemDtoCopyWith<$Res> {
  __$CalendarExportItemDtoCopyWithImpl(this._self, this._then);

  final _CalendarExportItemDto _self;
  final $Res Function(_CalendarExportItemDto) _then;

/// Create a copy of CalendarExportItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeBoxId = null,Object? title = null,Object? startAtMillis = null,Object? endAtMillis = null,Object? notes = null,}) {
  return _then(_CalendarExportItemDto(
timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAtMillis: null == startAtMillis ? _self.startAtMillis : startAtMillis // ignore: cast_nullable_to_non_nullable
as int,endAtMillis: null == endAtMillis ? _self.endAtMillis : endAtMillis // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CalendarEventMappingDto {

 String get dateKey; String get provider; String get timeBoxId; String get eventId; String get exportedAtIso;
/// Create a copy of CalendarEventMappingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventMappingDtoCopyWith<CalendarEventMappingDto> get copyWith => _$CalendarEventMappingDtoCopyWithImpl<CalendarEventMappingDto>(this as CalendarEventMappingDto, _$identity);

  /// Serializes this CalendarEventMappingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEventMappingDto&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.exportedAtIso, exportedAtIso) || other.exportedAtIso == exportedAtIso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,provider,timeBoxId,eventId,exportedAtIso);

@override
String toString() {
  return 'CalendarEventMappingDto(dateKey: $dateKey, provider: $provider, timeBoxId: $timeBoxId, eventId: $eventId, exportedAtIso: $exportedAtIso)';
}


}

/// @nodoc
abstract mixin class $CalendarEventMappingDtoCopyWith<$Res>  {
  factory $CalendarEventMappingDtoCopyWith(CalendarEventMappingDto value, $Res Function(CalendarEventMappingDto) _then) = _$CalendarEventMappingDtoCopyWithImpl;
@useResult
$Res call({
 String dateKey, String provider, String timeBoxId, String eventId, String exportedAtIso
});




}
/// @nodoc
class _$CalendarEventMappingDtoCopyWithImpl<$Res>
    implements $CalendarEventMappingDtoCopyWith<$Res> {
  _$CalendarEventMappingDtoCopyWithImpl(this._self, this._then);

  final CalendarEventMappingDto _self;
  final $Res Function(CalendarEventMappingDto) _then;

/// Create a copy of CalendarEventMappingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? provider = null,Object? timeBoxId = null,Object? eventId = null,Object? exportedAtIso = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,exportedAtIso: null == exportedAtIso ? _self.exportedAtIso : exportedAtIso // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarEventMappingDto].
extension CalendarEventMappingDtoPatterns on CalendarEventMappingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEventMappingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEventMappingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEventMappingDto value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEventMappingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEventMappingDto value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEventMappingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  String provider,  String timeBoxId,  String eventId,  String exportedAtIso)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEventMappingDto() when $default != null:
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAtIso);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  String provider,  String timeBoxId,  String eventId,  String exportedAtIso)  $default,) {final _that = this;
switch (_that) {
case _CalendarEventMappingDto():
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAtIso);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  String provider,  String timeBoxId,  String eventId,  String exportedAtIso)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEventMappingDto() when $default != null:
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAtIso);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEventMappingDto extends CalendarEventMappingDto {
  const _CalendarEventMappingDto({required this.dateKey, required this.provider, required this.timeBoxId, required this.eventId, required this.exportedAtIso}): super._();
  factory _CalendarEventMappingDto.fromJson(Map<String, dynamic> json) => _$CalendarEventMappingDtoFromJson(json);

@override final  String dateKey;
@override final  String provider;
@override final  String timeBoxId;
@override final  String eventId;
@override final  String exportedAtIso;

/// Create a copy of CalendarEventMappingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventMappingDtoCopyWith<_CalendarEventMappingDto> get copyWith => __$CalendarEventMappingDtoCopyWithImpl<_CalendarEventMappingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventMappingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEventMappingDto&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.exportedAtIso, exportedAtIso) || other.exportedAtIso == exportedAtIso));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateKey,provider,timeBoxId,eventId,exportedAtIso);

@override
String toString() {
  return 'CalendarEventMappingDto(dateKey: $dateKey, provider: $provider, timeBoxId: $timeBoxId, eventId: $eventId, exportedAtIso: $exportedAtIso)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventMappingDtoCopyWith<$Res> implements $CalendarEventMappingDtoCopyWith<$Res> {
  factory _$CalendarEventMappingDtoCopyWith(_CalendarEventMappingDto value, $Res Function(_CalendarEventMappingDto) _then) = __$CalendarEventMappingDtoCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, String provider, String timeBoxId, String eventId, String exportedAtIso
});




}
/// @nodoc
class __$CalendarEventMappingDtoCopyWithImpl<$Res>
    implements _$CalendarEventMappingDtoCopyWith<$Res> {
  __$CalendarEventMappingDtoCopyWithImpl(this._self, this._then);

  final _CalendarEventMappingDto _self;
  final $Res Function(_CalendarEventMappingDto) _then;

/// Create a copy of CalendarEventMappingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? provider = null,Object? timeBoxId = null,Object? eventId = null,Object? exportedAtIso = null,}) {
  return _then(_CalendarEventMappingDto(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,exportedAtIso: null == exportedAtIso ? _self.exportedAtIso : exportedAtIso // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CalendarExportResultDto {

 String get status; List<CalendarEventMappingDto> get events; String get message;
/// Create a copy of CalendarExportResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarExportResultDtoCopyWith<CalendarExportResultDto> get copyWith => _$CalendarExportResultDtoCopyWithImpl<CalendarExportResultDto>(this as CalendarExportResultDto, _$identity);

  /// Serializes this CalendarExportResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarExportResultDto&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(events),message);

@override
String toString() {
  return 'CalendarExportResultDto(status: $status, events: $events, message: $message)';
}


}

/// @nodoc
abstract mixin class $CalendarExportResultDtoCopyWith<$Res>  {
  factory $CalendarExportResultDtoCopyWith(CalendarExportResultDto value, $Res Function(CalendarExportResultDto) _then) = _$CalendarExportResultDtoCopyWithImpl;
@useResult
$Res call({
 String status, List<CalendarEventMappingDto> events, String message
});




}
/// @nodoc
class _$CalendarExportResultDtoCopyWithImpl<$Res>
    implements $CalendarExportResultDtoCopyWith<$Res> {
  _$CalendarExportResultDtoCopyWithImpl(this._self, this._then);

  final CalendarExportResultDto _self;
  final $Res Function(CalendarExportResultDto) _then;

/// Create a copy of CalendarExportResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? events = null,Object? message = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<CalendarEventMappingDto>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarExportResultDto].
extension CalendarExportResultDtoPatterns on CalendarExportResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarExportResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarExportResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarExportResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CalendarExportResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarExportResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarExportResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  List<CalendarEventMappingDto> events,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarExportResultDto() when $default != null:
return $default(_that.status,_that.events,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  List<CalendarEventMappingDto> events,  String message)  $default,) {final _that = this;
switch (_that) {
case _CalendarExportResultDto():
return $default(_that.status,_that.events,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  List<CalendarEventMappingDto> events,  String message)?  $default,) {final _that = this;
switch (_that) {
case _CalendarExportResultDto() when $default != null:
return $default(_that.status,_that.events,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarExportResultDto extends CalendarExportResultDto {
  const _CalendarExportResultDto({this.status = 'failed', final  List<CalendarEventMappingDto> events = const <CalendarEventMappingDto>[], this.message = ''}): _events = events,super._();
  factory _CalendarExportResultDto.fromJson(Map<String, dynamic> json) => _$CalendarExportResultDtoFromJson(json);

@override@JsonKey() final  String status;
 final  List<CalendarEventMappingDto> _events;
@override@JsonKey() List<CalendarEventMappingDto> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override@JsonKey() final  String message;

/// Create a copy of CalendarExportResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarExportResultDtoCopyWith<_CalendarExportResultDto> get copyWith => __$CalendarExportResultDtoCopyWithImpl<_CalendarExportResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarExportResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarExportResultDto&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_events),message);

@override
String toString() {
  return 'CalendarExportResultDto(status: $status, events: $events, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CalendarExportResultDtoCopyWith<$Res> implements $CalendarExportResultDtoCopyWith<$Res> {
  factory _$CalendarExportResultDtoCopyWith(_CalendarExportResultDto value, $Res Function(_CalendarExportResultDto) _then) = __$CalendarExportResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String status, List<CalendarEventMappingDto> events, String message
});




}
/// @nodoc
class __$CalendarExportResultDtoCopyWithImpl<$Res>
    implements _$CalendarExportResultDtoCopyWith<$Res> {
  __$CalendarExportResultDtoCopyWithImpl(this._self, this._then);

  final _CalendarExportResultDto _self;
  final $Res Function(_CalendarExportResultDto) _then;

/// Create a copy of CalendarExportResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? events = null,Object? message = null,}) {
  return _then(_CalendarExportResultDto(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<CalendarEventMappingDto>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
