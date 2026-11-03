// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class EmployeeSummary extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const EmployeeSummary({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.department,
  });

  factory EmployeeSummary.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'employee_number', r'name', r'department'},
      listKeys: {},
      context: r'EmployeeSummary',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return EmployeeSummary(
      id: _$values[r'id'].decodeSimpleInt(context: r'EmployeeSummary.id'),
      employeeNumber: _$values[r'employee_number'].decodeSimpleString(
        context: r'EmployeeSummary.employee_number',
      ),
      name: _$values[r'name'].decodeSimpleString(
        context: r'EmployeeSummary.name',
      ),
      department: _$values[r'department'].decodeSimpleNullableString(
        context: r'EmployeeSummary.department',
      ),
    );
  }

  factory EmployeeSummary.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'EmployeeSummary');
    return EmployeeSummary(
      id: _$map[r'id'].decodeJsonInt(context: r'EmployeeSummary.id'),
      employeeNumber: _$map[r'employee_number'].decodeJsonString(
        context: r'EmployeeSummary.employee_number',
      ),
      name: _$map[r'name'].decodeJsonString(context: r'EmployeeSummary.name'),
      department: _$map[r'department'].decodeJsonNullableString(
        context: r'EmployeeSummary.department',
      ),
    );
  }

  factory EmployeeSummary.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'employee_number', r'name', r'department'},
      listKeys: {},
      context: r'EmployeeSummary',
    );
    return EmployeeSummary(
      id: _$values[r'id'].decodeFormInt(context: r'EmployeeSummary.id'),
      employeeNumber: _$values[r'employee_number'].decodeFormString(
        context: r'EmployeeSummary.employee_number',
      ),
      name: _$values[r'name'].decodeFormString(
        context: r'EmployeeSummary.name',
      ),
      department: _$values[r'department'].decodeFormNullableString(
        context: r'EmployeeSummary.department',
      ),
    );
  }

  final _i3.int id;

  final _i3.String employeeNumber;

  final _i3.String name;

  /// Nama department
  final _i3.String? department;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'employee_number': this.employeeNumber,
    r'name': this.name,
    r'department': this.department,
  };

  EmployeeSummary Function({
    _i3.int? id,
    _i3.String? employeeNumber,
    _i3.String? name,
    _i3.String? department,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? id,
      _i3.String? employeeNumber,
      _i3.String? name,
      _i3.Object? department = _sentinel,
    }) => EmployeeSummary(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      name: name ?? this.name,
      department: _i3.identical(department, _sentinel)
          ? this.department
          : (department as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is EmployeeSummary &&
        other.id == this.id &&
        other.employeeNumber == this.employeeNumber &&
        other.name == this.name &&
        other.department == this.department;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.employeeNumber,
      this.name,
      this.department,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'employee_number'] = _i1.PropertyValue.scalar(
      this.employeeNumber,
    );
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.department != null) {
      _$result[r'department'] = _i1.PropertyValue.scalar(this.department!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode EmployeeSummary: complex types cannot be URI-encoded',
    );
  }
}
