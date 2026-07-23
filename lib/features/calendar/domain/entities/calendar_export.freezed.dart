// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_export.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarExportItem {

 String get timeBoxId; String get title; DateTime get startAt; DateTime get endAt; String get notes;
/// Create a copy of CalendarExportItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarExportItemCopyWith<CalendarExportItem> get copyWith => _$CalendarExportItemCopyWithImpl<CalendarExportItem>(this as CalendarExportItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarExportItem&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,timeBoxId,title,startAt,endAt,notes);

@override
String toString() {
  return 'CalendarExportItem(timeBoxId: $timeBoxId, title: $title, startAt: $startAt, endAt: $endAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CalendarExportItemCopyWith<$Res>  {
  factory $CalendarExportItemCopyWith(CalendarExportItem value, $Res Function(CalendarExportItem) _then) = _$CalendarExportItemCopyWithImpl;
@useResult
$Res call({
 String timeBoxId, String title, DateTime startAt, DateTime endAt, String notes
});




}
/// @nodoc
class _$CalendarExportItemCopyWithImpl<$Res>
    implements $CalendarExportItemCopyWith<$Res> {
  _$CalendarExportItemCopyWithImpl(this._self, this._then);

  final CalendarExportItem _self;
  final $Res Function(CalendarExportItem) _then;

/// Create a copy of CalendarExportItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeBoxId = null,Object? title = null,Object? startAt = null,Object? endAt = null,Object? notes = null,}) {
  return _then(_self.copyWith(
timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarExportItem].
extension CalendarExportItemPatterns on CalendarExportItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarExportItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarExportItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarExportItem value)  $default,){
final _that = this;
switch (_that) {
case _CalendarExportItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarExportItem value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarExportItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String timeBoxId,  String title,  DateTime startAt,  DateTime endAt,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarExportItem() when $default != null:
return $default(_that.timeBoxId,_that.title,_that.startAt,_that.endAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String timeBoxId,  String title,  DateTime startAt,  DateTime endAt,  String notes)  $default,) {final _that = this;
switch (_that) {
case _CalendarExportItem():
return $default(_that.timeBoxId,_that.title,_that.startAt,_that.endAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String timeBoxId,  String title,  DateTime startAt,  DateTime endAt,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _CalendarExportItem() when $default != null:
return $default(_that.timeBoxId,_that.title,_that.startAt,_that.endAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarExportItem implements CalendarExportItem {
  const _CalendarExportItem({required this.timeBoxId, required this.title, required this.startAt, required this.endAt, this.notes = ''});
  

@override final  String timeBoxId;
@override final  String title;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override@JsonKey() final  String notes;

/// Create a copy of CalendarExportItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarExportItemCopyWith<_CalendarExportItem> get copyWith => __$CalendarExportItemCopyWithImpl<_CalendarExportItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarExportItem&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,timeBoxId,title,startAt,endAt,notes);

@override
String toString() {
  return 'CalendarExportItem(timeBoxId: $timeBoxId, title: $title, startAt: $startAt, endAt: $endAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CalendarExportItemCopyWith<$Res> implements $CalendarExportItemCopyWith<$Res> {
  factory _$CalendarExportItemCopyWith(_CalendarExportItem value, $Res Function(_CalendarExportItem) _then) = __$CalendarExportItemCopyWithImpl;
@override @useResult
$Res call({
 String timeBoxId, String title, DateTime startAt, DateTime endAt, String notes
});




}
/// @nodoc
class __$CalendarExportItemCopyWithImpl<$Res>
    implements _$CalendarExportItemCopyWith<$Res> {
  __$CalendarExportItemCopyWithImpl(this._self, this._then);

  final _CalendarExportItem _self;
  final $Res Function(_CalendarExportItem) _then;

/// Create a copy of CalendarExportItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeBoxId = null,Object? title = null,Object? startAt = null,Object? endAt = null,Object? notes = null,}) {
  return _then(_CalendarExportItem(
timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CalendarExportRequest {

 CalendarProvider get provider; String get dateKey; List<CalendarExportItem> get items;
/// Create a copy of CalendarExportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarExportRequestCopyWith<CalendarExportRequest> get copyWith => _$CalendarExportRequestCopyWithImpl<CalendarExportRequest>(this as CalendarExportRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarExportRequest&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,provider,dateKey,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CalendarExportRequest(provider: $provider, dateKey: $dateKey, items: $items)';
}


}

/// @nodoc
abstract mixin class $CalendarExportRequestCopyWith<$Res>  {
  factory $CalendarExportRequestCopyWith(CalendarExportRequest value, $Res Function(CalendarExportRequest) _then) = _$CalendarExportRequestCopyWithImpl;
@useResult
$Res call({
 CalendarProvider provider, String dateKey, List<CalendarExportItem> items
});




}
/// @nodoc
class _$CalendarExportRequestCopyWithImpl<$Res>
    implements $CalendarExportRequestCopyWith<$Res> {
  _$CalendarExportRequestCopyWithImpl(this._self, this._then);

  final CalendarExportRequest _self;
  final $Res Function(CalendarExportRequest) _then;

/// Create a copy of CalendarExportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? dateKey = null,Object? items = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CalendarExportItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarExportRequest].
extension CalendarExportRequestPatterns on CalendarExportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarExportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarExportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarExportRequest value)  $default,){
final _that = this;
switch (_that) {
case _CalendarExportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarExportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarExportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarProvider provider,  String dateKey,  List<CalendarExportItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarExportRequest() when $default != null:
return $default(_that.provider,_that.dateKey,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarProvider provider,  String dateKey,  List<CalendarExportItem> items)  $default,) {final _that = this;
switch (_that) {
case _CalendarExportRequest():
return $default(_that.provider,_that.dateKey,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarProvider provider,  String dateKey,  List<CalendarExportItem> items)?  $default,) {final _that = this;
switch (_that) {
case _CalendarExportRequest() when $default != null:
return $default(_that.provider,_that.dateKey,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarExportRequest implements CalendarExportRequest {
  const _CalendarExportRequest({required this.provider, required this.dateKey, required final  List<CalendarExportItem> items}): _items = items;
  

@override final  CalendarProvider provider;
@override final  String dateKey;
 final  List<CalendarExportItem> _items;
@override List<CalendarExportItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of CalendarExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarExportRequestCopyWith<_CalendarExportRequest> get copyWith => __$CalendarExportRequestCopyWithImpl<_CalendarExportRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarExportRequest&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,provider,dateKey,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'CalendarExportRequest(provider: $provider, dateKey: $dateKey, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CalendarExportRequestCopyWith<$Res> implements $CalendarExportRequestCopyWith<$Res> {
  factory _$CalendarExportRequestCopyWith(_CalendarExportRequest value, $Res Function(_CalendarExportRequest) _then) = __$CalendarExportRequestCopyWithImpl;
@override @useResult
$Res call({
 CalendarProvider provider, String dateKey, List<CalendarExportItem> items
});




}
/// @nodoc
class __$CalendarExportRequestCopyWithImpl<$Res>
    implements _$CalendarExportRequestCopyWith<$Res> {
  __$CalendarExportRequestCopyWithImpl(this._self, this._then);

  final _CalendarExportRequest _self;
  final $Res Function(_CalendarExportRequest) _then;

/// Create a copy of CalendarExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? dateKey = null,Object? items = null,}) {
  return _then(_CalendarExportRequest(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CalendarExportItem>,
  ));
}


}

/// @nodoc
mixin _$TimeBoxCalendarEventMapping {

 String get dateKey; CalendarProvider get provider; String get timeBoxId; String get eventId; DateTime get exportedAt;
/// Create a copy of TimeBoxCalendarEventMapping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeBoxCalendarEventMappingCopyWith<TimeBoxCalendarEventMapping> get copyWith => _$TimeBoxCalendarEventMappingCopyWithImpl<TimeBoxCalendarEventMapping>(this as TimeBoxCalendarEventMapping, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeBoxCalendarEventMapping&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,provider,timeBoxId,eventId,exportedAt);

@override
String toString() {
  return 'TimeBoxCalendarEventMapping(dateKey: $dateKey, provider: $provider, timeBoxId: $timeBoxId, eventId: $eventId, exportedAt: $exportedAt)';
}


}

/// @nodoc
abstract mixin class $TimeBoxCalendarEventMappingCopyWith<$Res>  {
  factory $TimeBoxCalendarEventMappingCopyWith(TimeBoxCalendarEventMapping value, $Res Function(TimeBoxCalendarEventMapping) _then) = _$TimeBoxCalendarEventMappingCopyWithImpl;
@useResult
$Res call({
 String dateKey, CalendarProvider provider, String timeBoxId, String eventId, DateTime exportedAt
});




}
/// @nodoc
class _$TimeBoxCalendarEventMappingCopyWithImpl<$Res>
    implements $TimeBoxCalendarEventMappingCopyWith<$Res> {
  _$TimeBoxCalendarEventMappingCopyWithImpl(this._self, this._then);

  final TimeBoxCalendarEventMapping _self;
  final $Res Function(TimeBoxCalendarEventMapping) _then;

/// Create a copy of TimeBoxCalendarEventMapping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? provider = null,Object? timeBoxId = null,Object? eventId = null,Object? exportedAt = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeBoxCalendarEventMapping].
extension TimeBoxCalendarEventMappingPatterns on TimeBoxCalendarEventMapping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeBoxCalendarEventMapping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeBoxCalendarEventMapping value)  $default,){
final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeBoxCalendarEventMapping value)?  $default,){
final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dateKey,  CalendarProvider provider,  String timeBoxId,  String eventId,  DateTime exportedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping() when $default != null:
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dateKey,  CalendarProvider provider,  String timeBoxId,  String eventId,  DateTime exportedAt)  $default,) {final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping():
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dateKey,  CalendarProvider provider,  String timeBoxId,  String eventId,  DateTime exportedAt)?  $default,) {final _that = this;
switch (_that) {
case _TimeBoxCalendarEventMapping() when $default != null:
return $default(_that.dateKey,_that.provider,_that.timeBoxId,_that.eventId,_that.exportedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TimeBoxCalendarEventMapping implements TimeBoxCalendarEventMapping {
  const _TimeBoxCalendarEventMapping({required this.dateKey, required this.provider, required this.timeBoxId, required this.eventId, required this.exportedAt});
  

@override final  String dateKey;
@override final  CalendarProvider provider;
@override final  String timeBoxId;
@override final  String eventId;
@override final  DateTime exportedAt;

/// Create a copy of TimeBoxCalendarEventMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeBoxCalendarEventMappingCopyWith<_TimeBoxCalendarEventMapping> get copyWith => __$TimeBoxCalendarEventMappingCopyWithImpl<_TimeBoxCalendarEventMapping>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeBoxCalendarEventMapping&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timeBoxId, timeBoxId) || other.timeBoxId == timeBoxId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,provider,timeBoxId,eventId,exportedAt);

@override
String toString() {
  return 'TimeBoxCalendarEventMapping(dateKey: $dateKey, provider: $provider, timeBoxId: $timeBoxId, eventId: $eventId, exportedAt: $exportedAt)';
}


}

/// @nodoc
abstract mixin class _$TimeBoxCalendarEventMappingCopyWith<$Res> implements $TimeBoxCalendarEventMappingCopyWith<$Res> {
  factory _$TimeBoxCalendarEventMappingCopyWith(_TimeBoxCalendarEventMapping value, $Res Function(_TimeBoxCalendarEventMapping) _then) = __$TimeBoxCalendarEventMappingCopyWithImpl;
@override @useResult
$Res call({
 String dateKey, CalendarProvider provider, String timeBoxId, String eventId, DateTime exportedAt
});




}
/// @nodoc
class __$TimeBoxCalendarEventMappingCopyWithImpl<$Res>
    implements _$TimeBoxCalendarEventMappingCopyWith<$Res> {
  __$TimeBoxCalendarEventMappingCopyWithImpl(this._self, this._then);

  final _TimeBoxCalendarEventMapping _self;
  final $Res Function(_TimeBoxCalendarEventMapping) _then;

/// Create a copy of TimeBoxCalendarEventMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? provider = null,Object? timeBoxId = null,Object? eventId = null,Object? exportedAt = null,}) {
  return _then(_TimeBoxCalendarEventMapping(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as CalendarProvider,timeBoxId: null == timeBoxId ? _self.timeBoxId : timeBoxId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CalendarExportResult {

 CalendarExportStatus get status; int get exportedCount; List<TimeBoxCalendarEventMapping> get mappings; String get message;
/// Create a copy of CalendarExportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarExportResultCopyWith<CalendarExportResult> get copyWith => _$CalendarExportResultCopyWithImpl<CalendarExportResult>(this as CalendarExportResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarExportResult&&(identical(other.status, status) || other.status == status)&&(identical(other.exportedCount, exportedCount) || other.exportedCount == exportedCount)&&const DeepCollectionEquality().equals(other.mappings, mappings)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,exportedCount,const DeepCollectionEquality().hash(mappings),message);

@override
String toString() {
  return 'CalendarExportResult(status: $status, exportedCount: $exportedCount, mappings: $mappings, message: $message)';
}


}

/// @nodoc
abstract mixin class $CalendarExportResultCopyWith<$Res>  {
  factory $CalendarExportResultCopyWith(CalendarExportResult value, $Res Function(CalendarExportResult) _then) = _$CalendarExportResultCopyWithImpl;
@useResult
$Res call({
 CalendarExportStatus status, int exportedCount, List<TimeBoxCalendarEventMapping> mappings, String message
});




}
/// @nodoc
class _$CalendarExportResultCopyWithImpl<$Res>
    implements $CalendarExportResultCopyWith<$Res> {
  _$CalendarExportResultCopyWithImpl(this._self, this._then);

  final CalendarExportResult _self;
  final $Res Function(CalendarExportResult) _then;

/// Create a copy of CalendarExportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? exportedCount = null,Object? mappings = null,Object? message = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CalendarExportStatus,exportedCount: null == exportedCount ? _self.exportedCount : exportedCount // ignore: cast_nullable_to_non_nullable
as int,mappings: null == mappings ? _self.mappings : mappings // ignore: cast_nullable_to_non_nullable
as List<TimeBoxCalendarEventMapping>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarExportResult].
extension CalendarExportResultPatterns on CalendarExportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarExportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarExportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarExportResult value)  $default,){
final _that = this;
switch (_that) {
case _CalendarExportResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarExportResult value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarExportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarExportStatus status,  int exportedCount,  List<TimeBoxCalendarEventMapping> mappings,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarExportResult() when $default != null:
return $default(_that.status,_that.exportedCount,_that.mappings,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarExportStatus status,  int exportedCount,  List<TimeBoxCalendarEventMapping> mappings,  String message)  $default,) {final _that = this;
switch (_that) {
case _CalendarExportResult():
return $default(_that.status,_that.exportedCount,_that.mappings,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarExportStatus status,  int exportedCount,  List<TimeBoxCalendarEventMapping> mappings,  String message)?  $default,) {final _that = this;
switch (_that) {
case _CalendarExportResult() when $default != null:
return $default(_that.status,_that.exportedCount,_that.mappings,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarExportResult extends CalendarExportResult {
  const _CalendarExportResult({this.status = CalendarExportStatus.idle, this.exportedCount = 0, final  List<TimeBoxCalendarEventMapping> mappings = const <TimeBoxCalendarEventMapping>[], this.message = ''}): _mappings = mappings,super._();
  

@override@JsonKey() final  CalendarExportStatus status;
@override@JsonKey() final  int exportedCount;
 final  List<TimeBoxCalendarEventMapping> _mappings;
@override@JsonKey() List<TimeBoxCalendarEventMapping> get mappings {
  if (_mappings is EqualUnmodifiableListView) return _mappings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mappings);
}

@override@JsonKey() final  String message;

/// Create a copy of CalendarExportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarExportResultCopyWith<_CalendarExportResult> get copyWith => __$CalendarExportResultCopyWithImpl<_CalendarExportResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarExportResult&&(identical(other.status, status) || other.status == status)&&(identical(other.exportedCount, exportedCount) || other.exportedCount == exportedCount)&&const DeepCollectionEquality().equals(other._mappings, _mappings)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,exportedCount,const DeepCollectionEquality().hash(_mappings),message);

@override
String toString() {
  return 'CalendarExportResult(status: $status, exportedCount: $exportedCount, mappings: $mappings, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CalendarExportResultCopyWith<$Res> implements $CalendarExportResultCopyWith<$Res> {
  factory _$CalendarExportResultCopyWith(_CalendarExportResult value, $Res Function(_CalendarExportResult) _then) = __$CalendarExportResultCopyWithImpl;
@override @useResult
$Res call({
 CalendarExportStatus status, int exportedCount, List<TimeBoxCalendarEventMapping> mappings, String message
});




}
/// @nodoc
class __$CalendarExportResultCopyWithImpl<$Res>
    implements _$CalendarExportResultCopyWith<$Res> {
  __$CalendarExportResultCopyWithImpl(this._self, this._then);

  final _CalendarExportResult _self;
  final $Res Function(_CalendarExportResult) _then;

/// Create a copy of CalendarExportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? exportedCount = null,Object? mappings = null,Object? message = null,}) {
  return _then(_CalendarExportResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CalendarExportStatus,exportedCount: null == exportedCount ? _self.exportedCount : exportedCount // ignore: cast_nullable_to_non_nullable
as int,mappings: null == mappings ? _self._mappings : mappings // ignore: cast_nullable_to_non_nullable
as List<TimeBoxCalendarEventMapping>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CalendarAppOpenResult {

 CalendarAppOpenStatus get status;
/// Create a copy of CalendarAppOpenResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarAppOpenResultCopyWith<CalendarAppOpenResult> get copyWith => _$CalendarAppOpenResultCopyWithImpl<CalendarAppOpenResult>(this as CalendarAppOpenResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarAppOpenResult&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'CalendarAppOpenResult(status: $status)';
}


}

/// @nodoc
abstract mixin class $CalendarAppOpenResultCopyWith<$Res>  {
  factory $CalendarAppOpenResultCopyWith(CalendarAppOpenResult value, $Res Function(CalendarAppOpenResult) _then) = _$CalendarAppOpenResultCopyWithImpl;
@useResult
$Res call({
 CalendarAppOpenStatus status
});




}
/// @nodoc
class _$CalendarAppOpenResultCopyWithImpl<$Res>
    implements $CalendarAppOpenResultCopyWith<$Res> {
  _$CalendarAppOpenResultCopyWithImpl(this._self, this._then);

  final CalendarAppOpenResult _self;
  final $Res Function(CalendarAppOpenResult) _then;

/// Create a copy of CalendarAppOpenResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CalendarAppOpenStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarAppOpenResult].
extension CalendarAppOpenResultPatterns on CalendarAppOpenResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarAppOpenResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarAppOpenResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarAppOpenResult value)  $default,){
final _that = this;
switch (_that) {
case _CalendarAppOpenResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarAppOpenResult value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarAppOpenResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarAppOpenStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarAppOpenResult() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarAppOpenStatus status)  $default,) {final _that = this;
switch (_that) {
case _CalendarAppOpenResult():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarAppOpenStatus status)?  $default,) {final _that = this;
switch (_that) {
case _CalendarAppOpenResult() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarAppOpenResult implements CalendarAppOpenResult {
  const _CalendarAppOpenResult({this.status = CalendarAppOpenStatus.failed});
  

@override@JsonKey() final  CalendarAppOpenStatus status;

/// Create a copy of CalendarAppOpenResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarAppOpenResultCopyWith<_CalendarAppOpenResult> get copyWith => __$CalendarAppOpenResultCopyWithImpl<_CalendarAppOpenResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarAppOpenResult&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'CalendarAppOpenResult(status: $status)';
}


}

/// @nodoc
abstract mixin class _$CalendarAppOpenResultCopyWith<$Res> implements $CalendarAppOpenResultCopyWith<$Res> {
  factory _$CalendarAppOpenResultCopyWith(_CalendarAppOpenResult value, $Res Function(_CalendarAppOpenResult) _then) = __$CalendarAppOpenResultCopyWithImpl;
@override @useResult
$Res call({
 CalendarAppOpenStatus status
});




}
/// @nodoc
class __$CalendarAppOpenResultCopyWithImpl<$Res>
    implements _$CalendarAppOpenResultCopyWith<$Res> {
  __$CalendarAppOpenResultCopyWithImpl(this._self, this._then);

  final _CalendarAppOpenResult _self;
  final $Res Function(_CalendarAppOpenResult) _then;

/// Create a copy of CalendarAppOpenResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_CalendarAppOpenResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CalendarAppOpenStatus,
  ));
}


}

// dart format on
