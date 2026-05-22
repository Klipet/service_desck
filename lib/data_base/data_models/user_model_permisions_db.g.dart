// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_permisions_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserModelPermissionsDBCollection on Isar {
  IsarCollection<UserModelPermissionsDB> get userModelPermissionsDBs =>
      this.collection();
}

const UserModelPermissionsDBSchema = CollectionSchema(
  name: r'UserModelPermissionsDB',
  id: 6970421634755612812,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    ),
    r'oid': PropertySchema(
      id: 1,
      name: r'oid',
      type: IsarType.long,
    )
  },
  estimateSize: _userModelPermissionsDBEstimateSize,
  serialize: _userModelPermissionsDBSerialize,
  deserialize: _userModelPermissionsDBDeserialize,
  deserializeProp: _userModelPermissionsDBDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userModelPermissionsDBGetId,
  getLinks: _userModelPermissionsDBGetLinks,
  attach: _userModelPermissionsDBAttach,
  version: '3.1.0+1',
);

int _userModelPermissionsDBEstimateSize(
  UserModelPermissionsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _userModelPermissionsDBSerialize(
  UserModelPermissionsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeLong(offsets[1], object.oid);
}

UserModelPermissionsDB _userModelPermissionsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserModelPermissionsDB();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  object.oid = reader.readLong(offsets[1]);
  return object;
}

P _userModelPermissionsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userModelPermissionsDBGetId(UserModelPermissionsDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userModelPermissionsDBGetLinks(
    UserModelPermissionsDB object) {
  return [];
}

void _userModelPermissionsDBAttach(
    IsarCollection<dynamic> col, Id id, UserModelPermissionsDB object) {
  object.id = id;
}

extension UserModelPermissionsDBQueryWhereSort
    on QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QWhere> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserModelPermissionsDBQueryWhere on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QWhereClause> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserModelPermissionsDBQueryFilter on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QFilterCondition> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> oidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oid',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> oidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oid',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> oidLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oid',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB,
      QAfterFilterCondition> oidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserModelPermissionsDBQueryObject on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QFilterCondition> {}

extension UserModelPermissionsDBQueryLinks on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QFilterCondition> {}

extension UserModelPermissionsDBQuerySortBy
    on QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QSortBy> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      sortByOid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oid', Sort.asc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      sortByOidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oid', Sort.desc);
    });
  }
}

extension UserModelPermissionsDBQuerySortThenBy on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QSortThenBy> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenByOid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oid', Sort.asc);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QAfterSortBy>
      thenByOidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oid', Sort.desc);
    });
  }
}

extension UserModelPermissionsDBQueryWhereDistinct
    on QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QDistinct> {
  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserModelPermissionsDB, UserModelPermissionsDB, QDistinct>
      distinctByOid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oid');
    });
  }
}

extension UserModelPermissionsDBQueryProperty on QueryBuilder<
    UserModelPermissionsDB, UserModelPermissionsDB, QQueryProperty> {
  QueryBuilder<UserModelPermissionsDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserModelPermissionsDB, String, QQueryOperations>
      nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<UserModelPermissionsDB, int, QQueryOperations> oidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oid');
    });
  }
}
