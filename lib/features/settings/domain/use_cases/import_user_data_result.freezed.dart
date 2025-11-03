// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_user_data_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportUserDataResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUserDataResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportUserDataResult()';
}


}

/// @nodoc
class $ImportUserDataResultCopyWith<$Res>  {
$ImportUserDataResultCopyWith(ImportUserDataResult _, $Res Function(ImportUserDataResult) __);
}


/// Adds pattern-matching-related methods to [ImportUserDataResult].
extension ImportUserDataResultPatterns on ImportUserDataResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImportUserDataResultSuccess value)?  success,TResult Function( ImportUserDataResultCancelled value)?  cancelled,TResult Function( ImportUserDataResultFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImportUserDataResultSuccess() when success != null:
return success(_that);case ImportUserDataResultCancelled() when cancelled != null:
return cancelled(_that);case ImportUserDataResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImportUserDataResultSuccess value)  success,required TResult Function( ImportUserDataResultCancelled value)  cancelled,required TResult Function( ImportUserDataResultFailure value)  failure,}){
final _that = this;
switch (_that) {
case ImportUserDataResultSuccess():
return success(_that);case ImportUserDataResultCancelled():
return cancelled(_that);case ImportUserDataResultFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImportUserDataResultSuccess value)?  success,TResult? Function( ImportUserDataResultCancelled value)?  cancelled,TResult? Function( ImportUserDataResultFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ImportUserDataResultSuccess() when success != null:
return success(_that);case ImportUserDataResultCancelled() when cancelled != null:
return cancelled(_that);case ImportUserDataResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int accounts,  int categories,  int transactions)?  success,TResult Function()?  cancelled,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImportUserDataResultSuccess() when success != null:
return success(_that.accounts,_that.categories,_that.transactions);case ImportUserDataResultCancelled() when cancelled != null:
return cancelled();case ImportUserDataResultFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int accounts,  int categories,  int transactions)  success,required TResult Function()  cancelled,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case ImportUserDataResultSuccess():
return success(_that.accounts,_that.categories,_that.transactions);case ImportUserDataResultCancelled():
return cancelled();case ImportUserDataResultFailure():
return failure(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int accounts,  int categories,  int transactions)?  success,TResult? Function()?  cancelled,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case ImportUserDataResultSuccess() when success != null:
return success(_that.accounts,_that.categories,_that.transactions);case ImportUserDataResultCancelled() when cancelled != null:
return cancelled();case ImportUserDataResultFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ImportUserDataResultSuccess implements ImportUserDataResult {
  const ImportUserDataResultSuccess({required this.accounts, required this.categories, required this.transactions});
  

 final  int accounts;
 final  int categories;
 final  int transactions;

/// Create a copy of ImportUserDataResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportUserDataResultSuccessCopyWith<ImportUserDataResultSuccess> get copyWith => _$ImportUserDataResultSuccessCopyWithImpl<ImportUserDataResultSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUserDataResultSuccess&&(identical(other.accounts, accounts) || other.accounts == accounts)&&(identical(other.categories, categories) || other.categories == categories)&&(identical(other.transactions, transactions) || other.transactions == transactions));
}


@override
int get hashCode => Object.hash(runtimeType,accounts,categories,transactions);

@override
String toString() {
  return 'ImportUserDataResult.success(accounts: $accounts, categories: $categories, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $ImportUserDataResultSuccessCopyWith<$Res> implements $ImportUserDataResultCopyWith<$Res> {
  factory $ImportUserDataResultSuccessCopyWith(ImportUserDataResultSuccess value, $Res Function(ImportUserDataResultSuccess) _then) = _$ImportUserDataResultSuccessCopyWithImpl;
@useResult
$Res call({
 int accounts, int categories, int transactions
});




}
/// @nodoc
class _$ImportUserDataResultSuccessCopyWithImpl<$Res>
    implements $ImportUserDataResultSuccessCopyWith<$Res> {
  _$ImportUserDataResultSuccessCopyWithImpl(this._self, this._then);

  final ImportUserDataResultSuccess _self;
  final $Res Function(ImportUserDataResultSuccess) _then;

/// Create a copy of ImportUserDataResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accounts = null,Object? categories = null,Object? transactions = null,}) {
  return _then(ImportUserDataResultSuccess(
accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as int,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ImportUserDataResultCancelled implements ImportUserDataResult {
  const ImportUserDataResultCancelled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUserDataResultCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportUserDataResult.cancelled()';
}


}




/// @nodoc


class ImportUserDataResultFailure implements ImportUserDataResult {
  const ImportUserDataResultFailure(this.message);
  

 final  String message;

/// Create a copy of ImportUserDataResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportUserDataResultFailureCopyWith<ImportUserDataResultFailure> get copyWith => _$ImportUserDataResultFailureCopyWithImpl<ImportUserDataResultFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUserDataResultFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ImportUserDataResult.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $ImportUserDataResultFailureCopyWith<$Res> implements $ImportUserDataResultCopyWith<$Res> {
  factory $ImportUserDataResultFailureCopyWith(ImportUserDataResultFailure value, $Res Function(ImportUserDataResultFailure) _then) = _$ImportUserDataResultFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ImportUserDataResultFailureCopyWithImpl<$Res>
    implements $ImportUserDataResultFailureCopyWith<$Res> {
  _$ImportUserDataResultFailureCopyWithImpl(this._self, this._then);

  final ImportUserDataResultFailure _self;
  final $Res Function(ImportUserDataResultFailure) _then;

/// Create a copy of ImportUserDataResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ImportUserDataResultFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
