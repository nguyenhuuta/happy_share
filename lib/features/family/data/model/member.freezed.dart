// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Member {

 String get memberId; String get userId; String get displayName; String? get nickname; String? get avatarUrl;@JsonKey(unknownEnumValue: MemberRole.unknown) MemberRole get role;@JsonKey(unknownEnumValue: MemberStatus.unknown) MemberStatus get status; DateTime get joinedAt;@JsonKey(unknownEnumValue: SharingState.unknown) SharingState get sharingState; bool get isMe;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.sharingState, sharingState) || other.sharingState == sharingState)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,userId,displayName,nickname,avatarUrl,role,status,joinedAt,sharingState,isMe);

@override
String toString() {
  return 'Member(memberId: $memberId, userId: $userId, displayName: $displayName, nickname: $nickname, avatarUrl: $avatarUrl, role: $role, status: $status, joinedAt: $joinedAt, sharingState: $sharingState, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String memberId, String userId, String displayName, String? nickname, String? avatarUrl,@JsonKey(unknownEnumValue: MemberRole.unknown) MemberRole role,@JsonKey(unknownEnumValue: MemberStatus.unknown) MemberStatus status, DateTime joinedAt,@JsonKey(unknownEnumValue: SharingState.unknown) SharingState sharingState, bool isMe
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? userId = null,Object? displayName = null,Object? nickname = freezed,Object? avatarUrl = freezed,Object? role = null,Object? status = null,Object? joinedAt = null,Object? sharingState = null,Object? isMe = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sharingState: null == sharingState ? _self.sharingState : sharingState // ignore: cast_nullable_to_non_nullable
as SharingState,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String userId,  String displayName,  String? nickname,  String? avatarUrl, @JsonKey(unknownEnumValue: MemberRole.unknown)  MemberRole role, @JsonKey(unknownEnumValue: MemberStatus.unknown)  MemberStatus status,  DateTime joinedAt, @JsonKey(unknownEnumValue: SharingState.unknown)  SharingState sharingState,  bool isMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.memberId,_that.userId,_that.displayName,_that.nickname,_that.avatarUrl,_that.role,_that.status,_that.joinedAt,_that.sharingState,_that.isMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String userId,  String displayName,  String? nickname,  String? avatarUrl, @JsonKey(unknownEnumValue: MemberRole.unknown)  MemberRole role, @JsonKey(unknownEnumValue: MemberStatus.unknown)  MemberStatus status,  DateTime joinedAt, @JsonKey(unknownEnumValue: SharingState.unknown)  SharingState sharingState,  bool isMe)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.memberId,_that.userId,_that.displayName,_that.nickname,_that.avatarUrl,_that.role,_that.status,_that.joinedAt,_that.sharingState,_that.isMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String userId,  String displayName,  String? nickname,  String? avatarUrl, @JsonKey(unknownEnumValue: MemberRole.unknown)  MemberRole role, @JsonKey(unknownEnumValue: MemberStatus.unknown)  MemberStatus status,  DateTime joinedAt, @JsonKey(unknownEnumValue: SharingState.unknown)  SharingState sharingState,  bool isMe)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.memberId,_that.userId,_that.displayName,_that.nickname,_that.avatarUrl,_that.role,_that.status,_that.joinedAt,_that.sharingState,_that.isMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member extends Member {
  const _Member({required this.memberId, required this.userId, required this.displayName, this.nickname, this.avatarUrl, @JsonKey(unknownEnumValue: MemberRole.unknown) required this.role, @JsonKey(unknownEnumValue: MemberStatus.unknown) required this.status, required this.joinedAt, @JsonKey(unknownEnumValue: SharingState.unknown) required this.sharingState, required this.isMe}): super._();
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String memberId;
@override final  String userId;
@override final  String displayName;
@override final  String? nickname;
@override final  String? avatarUrl;
@override@JsonKey(unknownEnumValue: MemberRole.unknown) final  MemberRole role;
@override@JsonKey(unknownEnumValue: MemberStatus.unknown) final  MemberStatus status;
@override final  DateTime joinedAt;
@override@JsonKey(unknownEnumValue: SharingState.unknown) final  SharingState sharingState;
@override final  bool isMe;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.sharingState, sharingState) || other.sharingState == sharingState)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,userId,displayName,nickname,avatarUrl,role,status,joinedAt,sharingState,isMe);

@override
String toString() {
  return 'Member(memberId: $memberId, userId: $userId, displayName: $displayName, nickname: $nickname, avatarUrl: $avatarUrl, role: $role, status: $status, joinedAt: $joinedAt, sharingState: $sharingState, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String userId, String displayName, String? nickname, String? avatarUrl,@JsonKey(unknownEnumValue: MemberRole.unknown) MemberRole role,@JsonKey(unknownEnumValue: MemberStatus.unknown) MemberStatus status, DateTime joinedAt,@JsonKey(unknownEnumValue: SharingState.unknown) SharingState sharingState, bool isMe
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? userId = null,Object? displayName = null,Object? nickname = freezed,Object? avatarUrl = freezed,Object? role = null,Object? status = null,Object? joinedAt = null,Object? sharingState = null,Object? isMe = null,}) {
  return _then(_Member(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sharingState: null == sharingState ? _self.sharingState : sharingState // ignore: cast_nullable_to_non_nullable
as SharingState,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
