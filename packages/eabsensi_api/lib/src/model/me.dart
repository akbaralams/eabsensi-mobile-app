// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/me_employee_one_of_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Me extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Me({
    required this.id,
    required this.name,
    required this.username,
    required this.employee,
    required this.timezone,
    required this.requiresPhoto,
    required this.requiresApproval,
  });

  factory Me.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Me: contains complex types',
    );
  }

  factory Me.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Me');
    return Me(
      id: _$map[r'id'].decodeJsonInt(context: r'Me.id'),
      name: _$map[r'name'].decodeJsonString(context: r'Me.name'),
      username: _$map[r'username'].decodeJsonNullableString(
        context: r'Me.username',
      ),
      employee: _$map[r'employee'] == null
          ? null
          : _i4.MeEmployeeOneOfModel.fromJson(_$map[r'employee']),
      timezone: _$map[r'timezone'].decodeJsonString(context: r'Me.timezone'),
      requiresPhoto: _$map[r'requires_photo'].decodeJsonBool(
        context: r'Me.requires_photo',
      ),
      requiresApproval: _$map[r'requires_approval'].decodeJsonBool(
        context: r'Me.requires_approval',
      ),
    );
  }

  factory Me.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Me: contains complex types',
    );
  }

  final _i3.int id;

  final _i3.String name;

  /// Null bila akun tidak punya username (login dengan email)
  final _i3.String? username;

  final _i4.MeEmployeeOneOfModel employee;

  /// **Example**:
  /// ```
  /// Asia/Jakarta
  /// ```
  final _i3.String timezone;

  /// Foto wajib pada punch dan check-in
  final _i3.bool requiresPhoto;

  /// Punch berstatus pending sampai disetujui
  final _i3.bool requiresApproval;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'username': this.username,
    r'employee': this.employee?.toJson(),
    r'timezone': this.timezone,
    r'requires_photo': this.requiresPhoto,
    r'requires_approval': this.requiresApproval,
  };

  Me Function({
    _i3.int? id,
    _i3.String? name,
    _i3.String? username,
    _i4.MeEmployeeOneOfModel? employee,
    _i3.String? timezone,
    _i3.bool? requiresPhoto,
    _i3.bool? requiresApproval,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? id,
      _i3.String? name,
      _i3.Object? username = _sentinel,
      _i3.Object? employee = _sentinel,
      _i3.String? timezone,
      _i3.bool? requiresPhoto,
      _i3.bool? requiresApproval,
    }) => Me(
      id: id ?? this.id,
      name: name ?? this.name,
      username: _i3.identical(username, _sentinel)
          ? this.username
          : (username as _i3.String?),
      employee: _i3.identical(employee, _sentinel)
          ? this.employee
          : (employee as _i4.MeEmployeeOneOfModel),
      timezone: timezone ?? this.timezone,
      requiresPhoto: requiresPhoto ?? this.requiresPhoto,
      requiresApproval: requiresApproval ?? this.requiresApproval,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Me &&
        other.id == this.id &&
        other.name == this.name &&
        other.username == this.username &&
        other.employee == this.employee &&
        other.timezone == this.timezone &&
        other.requiresPhoto == this.requiresPhoto &&
        other.requiresApproval == this.requiresApproval;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.name,
      this.username,
      this.employee,
      this.timezone,
      this.requiresPhoto,
      this.requiresApproval,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.username != null) {
      _$result[r'username'] = _i1.PropertyValue.scalar(this.username!);
    }
    if (this.employee != null) {
      _$result[r'employee'] = _i1.encodeAnyValueToPropertyValue(
        this.employee!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    _$result[r'timezone'] = _i1.PropertyValue.scalar(this.timezone);
    _$result[r'requires_photo'] = _i1.PropertyValue.scalar(
      this.requiresPhoto.toString(),
    );
    _$result[r'requires_approval'] = _i1.PropertyValue.scalar(
      this.requiresApproval.toString(),
    );
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Me: complex types cannot be URI-encoded',
    );
  }
}
