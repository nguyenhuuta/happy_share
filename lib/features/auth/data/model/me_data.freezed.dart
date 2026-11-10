// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeData {

 User get user; List<FamilyWithMember> get families; ConsentInfo get consent;
/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeDataCopyWith<MeData> get copyWith => _$MeDataCopyWithImpl<MeData>(this as MeData, _$identity);

  /// Serializes this MeData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeData&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.families, families)&&(identical(other.consent, consent) || other.consent == consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(families),consent);

@override
String toString() {
  return 'MeData(user: $user, families: $families, consent: $consent)';
}


}

/// @nodoc
abstract mixin class $MeDataCopyWith<$Res>  {
  factory $MeDataCopyWith(MeData value, $Res Function(MeData) _then) = _$MeDataCopyWithImpl;
@useResult
$Res call({
 User user, List<FamilyWithMember> families, ConsentInfo consent
});


$UserCopyWith<$Res> get user;$ConsentInfoCopyWith<$Res> get consent;

}
/// @nodoc
class _$MeDataCopyWithImpl<$Res>
    implements $MeDataCopyWith<$Res> {
  _$MeDataCopyWithImpl(this._self, this._then);

  final MeData _self;
  final $Res Function(MeData) _then;

/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? families = null,Object? consent = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,families: null == families ? _self.families : families // ignore: cast_nullable_to_non_nullable
as List<FamilyWithMember>,consent: null == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as ConsentInfo,
  ));
}
/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsentInfoCopyWith<$Res> get consent {
  
  return $ConsentInfoCopyWith<$Res>(_self.consent, (value) {
    return _then(_self.copyWith(consent: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeData].
extension MeDataPatterns on MeData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeData value)  $default,){
final _that = this;
switch (_that) {
case _MeData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeData value)?  $default,){
final _that = this;
switch (_that) {
case _MeData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  List<FamilyWithMember> families,  ConsentInfo consent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeData() when $default != null:
return $default(_that.user,_that.families,_that.consent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  List<FamilyWithMember> families,  ConsentInfo consent)  $default,) {final _that = this;
switch (_that) {
case _MeData():
return $default(_that.user,_that.families,_that.consent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  List<FamilyWithMember> families,  ConsentInfo consent)?  $default,) {final _that = this;
switch (_that) {
case _MeData() when $default != null:
return $default(_that.user,_that.families,_that.consent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeData implements MeData {
  const _MeData({required this.user, final  List<FamilyWithMember> families = const <FamilyWithMember>[], required this.consent}): _families = families;
  factory _MeData.fromJson(Map<String, dynamic> json) => _$MeDataFromJson(json);

@override final  User user;
 final  List<FamilyWithMember> _families;
@override@JsonKey() List<FamilyWithMember> get families {
  if (_families is EqualUnmodifiableListView) return _families;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_families);
}

@override final  ConsentInfo consent;

/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeDataCopyWith<_MeData> get copyWith => __$MeDataCopyWithImpl<_MeData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeData&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other._families, _families)&&(identical(other.consent, consent) || other.consent == consent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(_families),consent);

@override
String toString() {
  return 'MeData(user: $user, families: $families, consent: $consent)';
}


}

/// @nodoc
abstract mixin class _$MeDataCopyWith<$Res> implements $MeDataCopyWith<$Res> {
  factory _$MeDataCopyWith(_MeData value, $Res Function(_MeData) _then) = __$MeDataCopyWithImpl;
@override @useResult
$Res call({
 User user, List<FamilyWithMember> families, ConsentInfo consent
});


@override $UserCopyWith<$Res> get user;@override $ConsentInfoCopyWith<$Res> get consent;

}
/// @nodoc
class __$MeDataCopyWithImpl<$Res>
    implements _$MeDataCopyWith<$Res> {
  __$MeDataCopyWithImpl(this._self, this._then);

  final _MeData _self;
  final $Res Function(_MeData) _then;

/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? families = null,Object? consent = null,}) {
  return _then(_MeData(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,families: null == families ? _self._families : families // ignore: cast_nullable_to_non_nullable
as List<FamilyWithMember>,consent: null == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as ConsentInfo,
  ));
}

/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MeData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsentInfoCopyWith<$Res> get consent {
  
  return $ConsentInfoCopyWith<$Res>(_self.consent, (value) {
    return _then(_self.copyWith(consent: value));
  });
}
}

// dart format on
