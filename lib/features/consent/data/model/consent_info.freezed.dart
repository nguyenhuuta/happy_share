// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsentInfo {

@JsonKey(unknownEnumValue: ConsentStatus.unknown) ConsentStatus? get status; String get consentVersion; DateTime? get updatedAt;
/// Create a copy of ConsentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentInfoCopyWith<ConsentInfo> get copyWith => _$ConsentInfoCopyWithImpl<ConsentInfo>(this as ConsentInfo, _$identity);

  /// Serializes this ConsentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentInfo&&(identical(other.status, status) || other.status == status)&&(identical(other.consentVersion, consentVersion) || other.consentVersion == consentVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,consentVersion,updatedAt);

@override
String toString() {
  return 'ConsentInfo(status: $status, consentVersion: $consentVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ConsentInfoCopyWith<$Res>  {
  factory $ConsentInfoCopyWith(ConsentInfo value, $Res Function(ConsentInfo) _then) = _$ConsentInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ConsentStatus.unknown) ConsentStatus? status, String consentVersion, DateTime? updatedAt
});




}
/// @nodoc
class _$ConsentInfoCopyWithImpl<$Res>
    implements $ConsentInfoCopyWith<$Res> {
  _$ConsentInfoCopyWithImpl(this._self, this._then);

  final ConsentInfo _self;
  final $Res Function(ConsentInfo) _then;

/// Create a copy of ConsentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? consentVersion = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsentStatus?,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentInfo].
extension ConsentInfoPatterns on ConsentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentInfo value)  $default,){
final _that = this;
switch (_that) {
case _ConsentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ConsentStatus.unknown)  ConsentStatus? status,  String consentVersion,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentInfo() when $default != null:
return $default(_that.status,_that.consentVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ConsentStatus.unknown)  ConsentStatus? status,  String consentVersion,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsentInfo():
return $default(_that.status,_that.consentVersion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ConsentStatus.unknown)  ConsentStatus? status,  String consentVersion,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsentInfo() when $default != null:
return $default(_that.status,_that.consentVersion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsentInfo extends ConsentInfo {
  const _ConsentInfo({@JsonKey(unknownEnumValue: ConsentStatus.unknown) this.status, required this.consentVersion, this.updatedAt}): super._();
  factory _ConsentInfo.fromJson(Map<String, dynamic> json) => _$ConsentInfoFromJson(json);

@override@JsonKey(unknownEnumValue: ConsentStatus.unknown) final  ConsentStatus? status;
@override final  String consentVersion;
@override final  DateTime? updatedAt;

/// Create a copy of ConsentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentInfoCopyWith<_ConsentInfo> get copyWith => __$ConsentInfoCopyWithImpl<_ConsentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentInfo&&(identical(other.status, status) || other.status == status)&&(identical(other.consentVersion, consentVersion) || other.consentVersion == consentVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,consentVersion,updatedAt);

@override
String toString() {
  return 'ConsentInfo(status: $status, consentVersion: $consentVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsentInfoCopyWith<$Res> implements $ConsentInfoCopyWith<$Res> {
  factory _$ConsentInfoCopyWith(_ConsentInfo value, $Res Function(_ConsentInfo) _then) = __$ConsentInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ConsentStatus.unknown) ConsentStatus? status, String consentVersion, DateTime? updatedAt
});




}
/// @nodoc
class __$ConsentInfoCopyWithImpl<$Res>
    implements _$ConsentInfoCopyWith<$Res> {
  __$ConsentInfoCopyWithImpl(this._self, this._then);

  final _ConsentInfo _self;
  final $Res Function(_ConsentInfo) _then;

/// Create a copy of ConsentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? consentVersion = null,Object? updatedAt = freezed,}) {
  return _then(_ConsentInfo(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsentStatus?,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
