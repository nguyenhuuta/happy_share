// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_with_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyWithMember {

 Family get family; Member get member;
/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyWithMemberCopyWith<FamilyWithMember> get copyWith => _$FamilyWithMemberCopyWithImpl<FamilyWithMember>(this as FamilyWithMember, _$identity);

  /// Serializes this FamilyWithMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyWithMember&&(identical(other.family, family) || other.family == family)&&(identical(other.member, member) || other.member == member));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,family,member);

@override
String toString() {
  return 'FamilyWithMember(family: $family, member: $member)';
}


}

/// @nodoc
abstract mixin class $FamilyWithMemberCopyWith<$Res>  {
  factory $FamilyWithMemberCopyWith(FamilyWithMember value, $Res Function(FamilyWithMember) _then) = _$FamilyWithMemberCopyWithImpl;
@useResult
$Res call({
 Family family, Member member
});


$FamilyCopyWith<$Res> get family;$MemberCopyWith<$Res> get member;

}
/// @nodoc
class _$FamilyWithMemberCopyWithImpl<$Res>
    implements $FamilyWithMemberCopyWith<$Res> {
  _$FamilyWithMemberCopyWithImpl(this._self, this._then);

  final FamilyWithMember _self;
  final $Res Function(FamilyWithMember) _then;

/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? family = null,Object? member = null,}) {
  return _then(_self.copyWith(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member,
  ));
}
/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyCopyWith<$Res> get family {
  
  return $FamilyCopyWith<$Res>(_self.family, (value) {
    return _then(_self.copyWith(family: value));
  });
}/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res> get member {
  
  return $MemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [FamilyWithMember].
extension FamilyWithMemberPatterns on FamilyWithMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyWithMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyWithMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyWithMember value)  $default,){
final _that = this;
switch (_that) {
case _FamilyWithMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyWithMember value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyWithMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Family family,  Member member)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyWithMember() when $default != null:
return $default(_that.family,_that.member);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Family family,  Member member)  $default,) {final _that = this;
switch (_that) {
case _FamilyWithMember():
return $default(_that.family,_that.member);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Family family,  Member member)?  $default,) {final _that = this;
switch (_that) {
case _FamilyWithMember() when $default != null:
return $default(_that.family,_that.member);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyWithMember implements FamilyWithMember {
  const _FamilyWithMember({required this.family, required this.member});
  factory _FamilyWithMember.fromJson(Map<String, dynamic> json) => _$FamilyWithMemberFromJson(json);

@override final  Family family;
@override final  Member member;

/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyWithMemberCopyWith<_FamilyWithMember> get copyWith => __$FamilyWithMemberCopyWithImpl<_FamilyWithMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyWithMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyWithMember&&(identical(other.family, family) || other.family == family)&&(identical(other.member, member) || other.member == member));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,family,member);

@override
String toString() {
  return 'FamilyWithMember(family: $family, member: $member)';
}


}

/// @nodoc
abstract mixin class _$FamilyWithMemberCopyWith<$Res> implements $FamilyWithMemberCopyWith<$Res> {
  factory _$FamilyWithMemberCopyWith(_FamilyWithMember value, $Res Function(_FamilyWithMember) _then) = __$FamilyWithMemberCopyWithImpl;
@override @useResult
$Res call({
 Family family, Member member
});


@override $FamilyCopyWith<$Res> get family;@override $MemberCopyWith<$Res> get member;

}
/// @nodoc
class __$FamilyWithMemberCopyWithImpl<$Res>
    implements _$FamilyWithMemberCopyWith<$Res> {
  __$FamilyWithMemberCopyWithImpl(this._self, this._then);

  final _FamilyWithMember _self;
  final $Res Function(_FamilyWithMember) _then;

/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? family = null,Object? member = null,}) {
  return _then(_FamilyWithMember(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member,
  ));
}

/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FamilyCopyWith<$Res> get family {
  
  return $FamilyCopyWith<$Res>(_self.family, (value) {
    return _then(_self.copyWith(family: value));
  });
}/// Create a copy of FamilyWithMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res> get member {
  
  return $MemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}

// dart format on
