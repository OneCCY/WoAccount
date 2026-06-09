// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountBooksTable extends AccountBooks
    with TableInfo<$AccountBooksTable, AccountBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    description,
    icon,
    isDefault,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountBooksTable createAlias(String alias) {
    return $AccountBooksTable(attachedDatabase, alias);
  }
}

class AccountBook extends DataClass implements Insertable<AccountBook> {
  final int id;
  final String name;
  final String type;
  final String? description;
  final String? icon;
  final bool isDefault;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AccountBook({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.icon,
    required this.isDefault,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountBooksCompanion toCompanion(bool nullToAbsent) {
    return AccountBooksCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      isDefault: Value(isDefault),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountBook(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String?>(json['icon']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String?>(icon),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountBook copyWith({
    int? id,
    String? name,
    String? type,
    Value<String?> description = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    bool? isDefault,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AccountBook(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    isDefault: isDefault ?? this.isDefault,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AccountBook copyWithCompanion(AccountBooksCompanion data) {
    return AccountBook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountBook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    description,
    icon,
    isDefault,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountBook &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.isDefault == this.isDefault &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountBooksCompanion extends UpdateCompanion<AccountBook> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<bool> isDefault;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AccountBooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AccountBooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<AccountBook> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<bool>? isDefault,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (isDefault != null) 'is_default': isDefault,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AccountBooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? description,
    Value<String?>? icon,
    Value<bool>? isDefault,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AccountBooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountBooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('isDefault: $isDefault, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 9),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#607D8B'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    parentId,
    level,
    isSystem,
    isExpense,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? icon;
  final String color;
  final int? parentId;
  final int level;
  final bool isSystem;
  final bool isExpense;
  final int sortOrder;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    this.icon,
    required this.color,
    this.parentId,
    required this.level,
    required this.isSystem,
    required this.isExpense,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['level'] = Variable<int>(level);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_expense'] = Variable<bool>(isExpense);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      level: Value(level),
      isSystem: Value(isSystem),
      isExpense: Value(isExpense),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      level: serializer.fromJson<int>(json['level']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String>(color),
      'parentId': serializer.toJson<int?>(parentId),
      'level': serializer.toJson<int>(level),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isExpense': serializer.toJson<bool>(isExpense),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    String? color,
    Value<int?> parentId = const Value.absent(),
    int? level,
    bool? isSystem,
    bool? isExpense,
    int? sortOrder,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    color: color ?? this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    level: level ?? this.level,
    isSystem: isSystem ?? this.isSystem,
    isExpense: isExpense ?? this.isExpense,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      level: data.level.present ? data.level.value : this.level,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('isSystem: $isSystem, ')
          ..write('isExpense: $isExpense, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    color,
    parentId,
    level,
    isSystem,
    isExpense,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.level == this.level &&
          other.isSystem == this.isSystem &&
          other.isExpense == this.isExpense &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String> color;
  final Value<int?> parentId;
  final Value<int> level;
  final Value<bool> isSystem;
  final Value<bool> isExpense;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? parentId,
    Expression<int>? level,
    Expression<bool>? isSystem,
    Expression<bool>? isExpense,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (level != null) 'level': level,
      if (isSystem != null) 'is_system': isSystem,
      if (isExpense != null) 'is_expense': isExpense,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<String>? color,
    Value<int?>? parentId,
    Value<int>? level,
    Value<bool>? isSystem,
    Value<bool>? isExpense,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      isSystem: isSystem ?? this.isSystem,
      isExpense: isExpense ?? this.isExpense,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('isSystem: $isSystem, ')
          ..write('isExpense: $isExpense, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
    'subcategory_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originalInputMeta = const VerificationMeta(
    'originalInput',
  );
  @override
  late final GeneratedColumn<String> originalInput = GeneratedColumn<String>(
    'original_input',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaFilePathMeta = const VerificationMeta(
    'mediaFilePath',
  );
  @override
  late final GeneratedColumn<String> mediaFilePath = GeneratedColumn<String>(
    'media_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiConfidenceMeta = const VerificationMeta(
    'aiConfidence',
  );
  @override
  late final GeneratedColumn<double> aiConfidence = GeneratedColumn<double>(
    'ai_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiSourceMeta = const VerificationMeta(
    'aiSource',
  );
  @override
  late final GeneratedColumn<String> aiSource = GeneratedColumn<String>(
    'ai_source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _userConfirmedMeta = const VerificationMeta(
    'userConfirmed',
  );
  @override
  late final GeneratedColumn<bool> userConfirmed = GeneratedColumn<bool>(
    'user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _accountBookIdMeta = const VerificationMeta(
    'accountBookId',
  );
  @override
  late final GeneratedColumn<int> accountBookId = GeneratedColumn<int>(
    'account_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_books (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    description,
    categoryId,
    subcategoryId,
    transactionDate,
    originalInput,
    mediaFilePath,
    mediaType,
    aiConfidence,
    aiSource,
    userConfirmed,
    isDeleted,
    createdAt,
    updatedAt,
    accountBookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('original_input')) {
      context.handle(
        _originalInputMeta,
        originalInput.isAcceptableOrUnknown(
          data['original_input']!,
          _originalInputMeta,
        ),
      );
    }
    if (data.containsKey('media_file_path')) {
      context.handle(
        _mediaFilePathMeta,
        mediaFilePath.isAcceptableOrUnknown(
          data['media_file_path']!,
          _mediaFilePathMeta,
        ),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('ai_confidence')) {
      context.handle(
        _aiConfidenceMeta,
        aiConfidence.isAcceptableOrUnknown(
          data['ai_confidence']!,
          _aiConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('ai_source')) {
      context.handle(
        _aiSourceMeta,
        aiSource.isAcceptableOrUnknown(data['ai_source']!, _aiSourceMeta),
      );
    }
    if (data.containsKey('user_confirmed')) {
      context.handle(
        _userConfirmedMeta,
        userConfirmed.isAcceptableOrUnknown(
          data['user_confirmed']!,
          _userConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
        _accountBookIdMeta,
        accountBookId.isAcceptableOrUnknown(
          data['account_book_id']!,
          _accountBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategory_id'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      originalInput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_input'],
      ),
      mediaFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_file_path'],
      ),
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      ),
      aiConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ai_confidence'],
      ),
      aiSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_source'],
      )!,
      userConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_confirmed'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      accountBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_book_id'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final String description;
  final int categoryId;
  final int? subcategoryId;
  final DateTime transactionDate;
  final String? originalInput;
  final String? mediaFilePath;
  final String? mediaType;
  final double? aiConfidence;
  final String aiSource;
  final bool userConfirmed;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 所属账本
  final int accountBookId;
  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    this.subcategoryId,
    required this.transactionDate,
    this.originalInput,
    this.mediaFilePath,
    this.mediaType,
    this.aiConfidence,
    required this.aiSource,
    required this.userConfirmed,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.accountBookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || originalInput != null) {
      map['original_input'] = Variable<String>(originalInput);
    }
    if (!nullToAbsent || mediaFilePath != null) {
      map['media_file_path'] = Variable<String>(mediaFilePath);
    }
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    if (!nullToAbsent || aiConfidence != null) {
      map['ai_confidence'] = Variable<double>(aiConfidence);
    }
    map['ai_source'] = Variable<String>(aiSource);
    map['user_confirmed'] = Variable<bool>(userConfirmed);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['account_book_id'] = Variable<int>(accountBookId);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      description: Value(description),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      transactionDate: Value(transactionDate),
      originalInput: originalInput == null && nullToAbsent
          ? const Value.absent()
          : Value(originalInput),
      mediaFilePath: mediaFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaFilePath),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      aiConfidence: aiConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(aiConfidence),
      aiSource: Value(aiSource),
      userConfirmed: Value(userConfirmed),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      accountBookId: Value(accountBookId),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      originalInput: serializer.fromJson<String?>(json['originalInput']),
      mediaFilePath: serializer.fromJson<String?>(json['mediaFilePath']),
      mediaType: serializer.fromJson<String?>(json['mediaType']),
      aiConfidence: serializer.fromJson<double?>(json['aiConfidence']),
      aiSource: serializer.fromJson<String>(json['aiSource']),
      userConfirmed: serializer.fromJson<bool>(json['userConfirmed']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      accountBookId: serializer.fromJson<int>(json['accountBookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<int>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'originalInput': serializer.toJson<String?>(originalInput),
      'mediaFilePath': serializer.toJson<String?>(mediaFilePath),
      'mediaType': serializer.toJson<String?>(mediaType),
      'aiConfidence': serializer.toJson<double?>(aiConfidence),
      'aiSource': serializer.toJson<String>(aiSource),
      'userConfirmed': serializer.toJson<bool>(userConfirmed),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'accountBookId': serializer.toJson<int>(accountBookId),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    Value<int?> subcategoryId = const Value.absent(),
    DateTime? transactionDate,
    Value<String?> originalInput = const Value.absent(),
    Value<String?> mediaFilePath = const Value.absent(),
    Value<String?> mediaType = const Value.absent(),
    Value<double?> aiConfidence = const Value.absent(),
    String? aiSource,
    bool? userConfirmed,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? accountBookId,
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    subcategoryId: subcategoryId.present
        ? subcategoryId.value
        : this.subcategoryId,
    transactionDate: transactionDate ?? this.transactionDate,
    originalInput: originalInput.present
        ? originalInput.value
        : this.originalInput,
    mediaFilePath: mediaFilePath.present
        ? mediaFilePath.value
        : this.mediaFilePath,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    aiConfidence: aiConfidence.present ? aiConfidence.value : this.aiConfidence,
    aiSource: aiSource ?? this.aiSource,
    userConfirmed: userConfirmed ?? this.userConfirmed,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    accountBookId: accountBookId ?? this.accountBookId,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      originalInput: data.originalInput.present
          ? data.originalInput.value
          : this.originalInput,
      mediaFilePath: data.mediaFilePath.present
          ? data.mediaFilePath.value
          : this.mediaFilePath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      aiConfidence: data.aiConfidence.present
          ? data.aiConfidence.value
          : this.aiConfidence,
      aiSource: data.aiSource.present ? data.aiSource.value : this.aiSource,
      userConfirmed: data.userConfirmed.present
          ? data.userConfirmed.value
          : this.userConfirmed,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('originalInput: $originalInput, ')
          ..write('mediaFilePath: $mediaFilePath, ')
          ..write('mediaType: $mediaType, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('aiSource: $aiSource, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    description,
    categoryId,
    subcategoryId,
    transactionDate,
    originalInput,
    mediaFilePath,
    mediaType,
    aiConfidence,
    aiSource,
    userConfirmed,
    isDeleted,
    createdAt,
    updatedAt,
    accountBookId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.transactionDate == this.transactionDate &&
          other.originalInput == this.originalInput &&
          other.mediaFilePath == this.mediaFilePath &&
          other.mediaType == this.mediaType &&
          other.aiConfidence == this.aiConfidence &&
          other.aiSource == this.aiSource &&
          other.userConfirmed == this.userConfirmed &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.accountBookId == this.accountBookId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> description;
  final Value<int> categoryId;
  final Value<int?> subcategoryId;
  final Value<DateTime> transactionDate;
  final Value<String?> originalInput;
  final Value<String?> mediaFilePath;
  final Value<String?> mediaType;
  final Value<double?> aiConfidence;
  final Value<String> aiSource;
  final Value<bool> userConfirmed;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> accountBookId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.originalInput = const Value.absent(),
    this.mediaFilePath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.aiSource = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String description,
    required int categoryId,
    this.subcategoryId = const Value.absent(),
    required DateTime transactionDate,
    this.originalInput = const Value.absent(),
    this.mediaFilePath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.aiSource = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required int accountBookId,
  }) : amount = Value(amount),
       description = Value(description),
       categoryId = Value(categoryId),
       transactionDate = Value(transactionDate),
       accountBookId = Value(accountBookId);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<DateTime>? transactionDate,
    Expression<String>? originalInput,
    Expression<String>? mediaFilePath,
    Expression<String>? mediaType,
    Expression<double>? aiConfidence,
    Expression<String>? aiSource,
    Expression<bool>? userConfirmed,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? accountBookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (originalInput != null) 'original_input': originalInput,
      if (mediaFilePath != null) 'media_file_path': mediaFilePath,
      if (mediaType != null) 'media_type': mediaType,
      if (aiConfidence != null) 'ai_confidence': aiConfidence,
      if (aiSource != null) 'ai_source': aiSource,
      if (userConfirmed != null) 'user_confirmed': userConfirmed,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<String>? description,
    Value<int>? categoryId,
    Value<int?>? subcategoryId,
    Value<DateTime>? transactionDate,
    Value<String?>? originalInput,
    Value<String?>? mediaFilePath,
    Value<String?>? mediaType,
    Value<double?>? aiConfidence,
    Value<String>? aiSource,
    Value<bool>? userConfirmed,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? accountBookId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      transactionDate: transactionDate ?? this.transactionDate,
      originalInput: originalInput ?? this.originalInput,
      mediaFilePath: mediaFilePath ?? this.mediaFilePath,
      mediaType: mediaType ?? this.mediaType,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiSource: aiSource ?? this.aiSource,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountBookId: accountBookId ?? this.accountBookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (originalInput.present) {
      map['original_input'] = Variable<String>(originalInput.value);
    }
    if (mediaFilePath.present) {
      map['media_file_path'] = Variable<String>(mediaFilePath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (aiConfidence.present) {
      map['ai_confidence'] = Variable<double>(aiConfidence.value);
    }
    if (aiSource.present) {
      map['ai_source'] = Variable<String>(aiSource.value);
    }
    if (userConfirmed.present) {
      map['user_confirmed'] = Variable<bool>(userConfirmed.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<int>(accountBookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('originalInput: $originalInput, ')
          ..write('mediaFilePath: $mediaFilePath, ')
          ..write('mediaType: $mediaType, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('aiSource: $aiSource, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _accountBookIdMeta = const VerificationMeta(
    'accountBookId',
  );
  @override
  late final GeneratedColumn<int> accountBookId = GeneratedColumn<int>(
    'account_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_books (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    amount,
    period,
    year,
    month,
    createdAt,
    accountBookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
        _accountBookIdMeta,
        accountBookId.isAcceptableOrUnknown(
          data['account_book_id']!,
          _accountBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountBookId, categoryId, year, month},
  ];
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      accountBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_book_id'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final int? categoryId;
  final double amount;
  final String period;
  final int year;
  final int month;
  final DateTime createdAt;

  /// 所属账本
  final int accountBookId;
  const Budget({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.period,
    required this.year,
    required this.month,
    required this.createdAt,
    required this.accountBookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['account_book_id'] = Variable<int>(accountBookId);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      period: Value(period),
      year: Value(year),
      month: Value(month),
      createdAt: Value(createdAt),
      accountBookId: Value(accountBookId),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      accountBookId: serializer.fromJson<int>(json['accountBookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'accountBookId': serializer.toJson<int>(accountBookId),
    };
  }

  Budget copyWith({
    int? id,
    Value<int?> categoryId = const Value.absent(),
    double? amount,
    String? period,
    int? year,
    int? month,
    DateTime? createdAt,
    int? accountBookId,
  }) => Budget(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    year: year ?? this.year,
    month: month ?? this.month,
    createdAt: createdAt ?? this.createdAt,
    accountBookId: accountBookId ?? this.accountBookId,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    amount,
    period,
    year,
    month,
    createdAt,
    accountBookId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.year == this.year &&
          other.month == this.month &&
          other.createdAt == this.createdAt &&
          other.accountBookId == this.accountBookId);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<int?> categoryId;
  final Value<double> amount;
  final Value<String> period;
  final Value<int> year;
  final Value<int> month;
  final Value<DateTime> createdAt;
  final Value<int> accountBookId;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double amount,
    this.period = const Value.absent(),
    required int year,
    required int month,
    this.createdAt = const Value.absent(),
    required int accountBookId,
  }) : amount = Value(amount),
       year = Value(year),
       month = Value(month),
       accountBookId = Value(accountBookId);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<int>? year,
    Expression<int>? month,
    Expression<DateTime>? createdAt,
    Expression<int>? accountBookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (createdAt != null) 'created_at': createdAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<int?>? categoryId,
    Value<double>? amount,
    Value<String>? period,
    Value<int>? year,
    Value<int>? month,
    Value<DateTime>? createdAt,
    Value<int>? accountBookId,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      accountBookId: accountBookId ?? this.accountBookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<int>(accountBookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }
}

class $AiTrainingRecordsTable extends AiTrainingRecords
    with TableInfo<$AiTrainingRecordsTable, AiTrainingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiTrainingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inputTextMeta = const VerificationMeta(
    'inputText',
  );
  @override
  late final GeneratedColumn<String> inputText = GeneratedColumn<String>(
    'input_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictedCategoryIdMeta =
      const VerificationMeta('predictedCategoryId');
  @override
  late final GeneratedColumn<int> predictedCategoryId = GeneratedColumn<int>(
    'predicted_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualCategoryIdMeta = const VerificationMeta(
    'actualCategoryId',
  );
  @override
  late final GeneratedColumn<int> actualCategoryId = GeneratedColumn<int>(
    'actual_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasCorrectMeta = const VerificationMeta(
    'wasCorrect',
  );
  @override
  late final GeneratedColumn<bool> wasCorrect = GeneratedColumn<bool>(
    'was_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _accountBookIdMeta = const VerificationMeta(
    'accountBookId',
  );
  @override
  late final GeneratedColumn<int> accountBookId = GeneratedColumn<int>(
    'account_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_books (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inputText,
    predictedCategoryId,
    actualCategoryId,
    wasCorrect,
    createdAt,
    accountBookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_training_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiTrainingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('input_text')) {
      context.handle(
        _inputTextMeta,
        inputText.isAcceptableOrUnknown(data['input_text']!, _inputTextMeta),
      );
    } else if (isInserting) {
      context.missing(_inputTextMeta);
    }
    if (data.containsKey('predicted_category_id')) {
      context.handle(
        _predictedCategoryIdMeta,
        predictedCategoryId.isAcceptableOrUnknown(
          data['predicted_category_id']!,
          _predictedCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('actual_category_id')) {
      context.handle(
        _actualCategoryIdMeta,
        actualCategoryId.isAcceptableOrUnknown(
          data['actual_category_id']!,
          _actualCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('was_correct')) {
      context.handle(
        _wasCorrectMeta,
        wasCorrect.isAcceptableOrUnknown(data['was_correct']!, _wasCorrectMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
        _accountBookIdMeta,
        accountBookId.isAcceptableOrUnknown(
          data['account_book_id']!,
          _accountBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiTrainingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiTrainingRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inputText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_text'],
      )!,
      predictedCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predicted_category_id'],
      ),
      actualCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_category_id'],
      ),
      wasCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_correct'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      accountBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_book_id'],
      )!,
    );
  }

  @override
  $AiTrainingRecordsTable createAlias(String alias) {
    return $AiTrainingRecordsTable(attachedDatabase, alias);
  }
}

class AiTrainingRecord extends DataClass
    implements Insertable<AiTrainingRecord> {
  final int id;
  final String inputText;
  final int? predictedCategoryId;
  final int? actualCategoryId;
  final bool? wasCorrect;
  final DateTime createdAt;

  /// 所属账本
  final int accountBookId;
  const AiTrainingRecord({
    required this.id,
    required this.inputText,
    this.predictedCategoryId,
    this.actualCategoryId,
    this.wasCorrect,
    required this.createdAt,
    required this.accountBookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['input_text'] = Variable<String>(inputText);
    if (!nullToAbsent || predictedCategoryId != null) {
      map['predicted_category_id'] = Variable<int>(predictedCategoryId);
    }
    if (!nullToAbsent || actualCategoryId != null) {
      map['actual_category_id'] = Variable<int>(actualCategoryId);
    }
    if (!nullToAbsent || wasCorrect != null) {
      map['was_correct'] = Variable<bool>(wasCorrect);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['account_book_id'] = Variable<int>(accountBookId);
    return map;
  }

  AiTrainingRecordsCompanion toCompanion(bool nullToAbsent) {
    return AiTrainingRecordsCompanion(
      id: Value(id),
      inputText: Value(inputText),
      predictedCategoryId: predictedCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedCategoryId),
      actualCategoryId: actualCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(actualCategoryId),
      wasCorrect: wasCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(wasCorrect),
      createdAt: Value(createdAt),
      accountBookId: Value(accountBookId),
    );
  }

  factory AiTrainingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiTrainingRecord(
      id: serializer.fromJson<int>(json['id']),
      inputText: serializer.fromJson<String>(json['inputText']),
      predictedCategoryId: serializer.fromJson<int?>(
        json['predictedCategoryId'],
      ),
      actualCategoryId: serializer.fromJson<int?>(json['actualCategoryId']),
      wasCorrect: serializer.fromJson<bool?>(json['wasCorrect']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      accountBookId: serializer.fromJson<int>(json['accountBookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inputText': serializer.toJson<String>(inputText),
      'predictedCategoryId': serializer.toJson<int?>(predictedCategoryId),
      'actualCategoryId': serializer.toJson<int?>(actualCategoryId),
      'wasCorrect': serializer.toJson<bool?>(wasCorrect),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'accountBookId': serializer.toJson<int>(accountBookId),
    };
  }

  AiTrainingRecord copyWith({
    int? id,
    String? inputText,
    Value<int?> predictedCategoryId = const Value.absent(),
    Value<int?> actualCategoryId = const Value.absent(),
    Value<bool?> wasCorrect = const Value.absent(),
    DateTime? createdAt,
    int? accountBookId,
  }) => AiTrainingRecord(
    id: id ?? this.id,
    inputText: inputText ?? this.inputText,
    predictedCategoryId: predictedCategoryId.present
        ? predictedCategoryId.value
        : this.predictedCategoryId,
    actualCategoryId: actualCategoryId.present
        ? actualCategoryId.value
        : this.actualCategoryId,
    wasCorrect: wasCorrect.present ? wasCorrect.value : this.wasCorrect,
    createdAt: createdAt ?? this.createdAt,
    accountBookId: accountBookId ?? this.accountBookId,
  );
  AiTrainingRecord copyWithCompanion(AiTrainingRecordsCompanion data) {
    return AiTrainingRecord(
      id: data.id.present ? data.id.value : this.id,
      inputText: data.inputText.present ? data.inputText.value : this.inputText,
      predictedCategoryId: data.predictedCategoryId.present
          ? data.predictedCategoryId.value
          : this.predictedCategoryId,
      actualCategoryId: data.actualCategoryId.present
          ? data.actualCategoryId.value
          : this.actualCategoryId,
      wasCorrect: data.wasCorrect.present
          ? data.wasCorrect.value
          : this.wasCorrect,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiTrainingRecord(')
          ..write('id: $id, ')
          ..write('inputText: $inputText, ')
          ..write('predictedCategoryId: $predictedCategoryId, ')
          ..write('actualCategoryId: $actualCategoryId, ')
          ..write('wasCorrect: $wasCorrect, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inputText,
    predictedCategoryId,
    actualCategoryId,
    wasCorrect,
    createdAt,
    accountBookId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiTrainingRecord &&
          other.id == this.id &&
          other.inputText == this.inputText &&
          other.predictedCategoryId == this.predictedCategoryId &&
          other.actualCategoryId == this.actualCategoryId &&
          other.wasCorrect == this.wasCorrect &&
          other.createdAt == this.createdAt &&
          other.accountBookId == this.accountBookId);
}

class AiTrainingRecordsCompanion extends UpdateCompanion<AiTrainingRecord> {
  final Value<int> id;
  final Value<String> inputText;
  final Value<int?> predictedCategoryId;
  final Value<int?> actualCategoryId;
  final Value<bool?> wasCorrect;
  final Value<DateTime> createdAt;
  final Value<int> accountBookId;
  const AiTrainingRecordsCompanion({
    this.id = const Value.absent(),
    this.inputText = const Value.absent(),
    this.predictedCategoryId = const Value.absent(),
    this.actualCategoryId = const Value.absent(),
    this.wasCorrect = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
  });
  AiTrainingRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String inputText,
    this.predictedCategoryId = const Value.absent(),
    this.actualCategoryId = const Value.absent(),
    this.wasCorrect = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int accountBookId,
  }) : inputText = Value(inputText),
       accountBookId = Value(accountBookId);
  static Insertable<AiTrainingRecord> custom({
    Expression<int>? id,
    Expression<String>? inputText,
    Expression<int>? predictedCategoryId,
    Expression<int>? actualCategoryId,
    Expression<bool>? wasCorrect,
    Expression<DateTime>? createdAt,
    Expression<int>? accountBookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inputText != null) 'input_text': inputText,
      if (predictedCategoryId != null)
        'predicted_category_id': predictedCategoryId,
      if (actualCategoryId != null) 'actual_category_id': actualCategoryId,
      if (wasCorrect != null) 'was_correct': wasCorrect,
      if (createdAt != null) 'created_at': createdAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
    });
  }

  AiTrainingRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? inputText,
    Value<int?>? predictedCategoryId,
    Value<int?>? actualCategoryId,
    Value<bool?>? wasCorrect,
    Value<DateTime>? createdAt,
    Value<int>? accountBookId,
  }) {
    return AiTrainingRecordsCompanion(
      id: id ?? this.id,
      inputText: inputText ?? this.inputText,
      predictedCategoryId: predictedCategoryId ?? this.predictedCategoryId,
      actualCategoryId: actualCategoryId ?? this.actualCategoryId,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      createdAt: createdAt ?? this.createdAt,
      accountBookId: accountBookId ?? this.accountBookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inputText.present) {
      map['input_text'] = Variable<String>(inputText.value);
    }
    if (predictedCategoryId.present) {
      map['predicted_category_id'] = Variable<int>(predictedCategoryId.value);
    }
    if (actualCategoryId.present) {
      map['actual_category_id'] = Variable<int>(actualCategoryId.value);
    }
    if (wasCorrect.present) {
      map['was_correct'] = Variable<bool>(wasCorrect.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<int>(accountBookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiTrainingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('inputText: $inputText, ')
          ..write('predictedCategoryId: $predictedCategoryId, ')
          ..write('actualCategoryId: $actualCategoryId, ')
          ..write('wasCorrect: $wasCorrect, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }
}

class $ConversationMessagesTable extends ConversationMessages
    with TableInfo<$ConversationMessagesTable, ConversationMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaFilePathMeta = const VerificationMeta(
    'mediaFilePath',
  );
  @override
  late final GeneratedColumn<String> mediaFilePath = GeneratedColumn<String>(
    'media_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionNameMeta = const VerificationMeta(
    'functionName',
  );
  @override
  late final GeneratedColumn<String> functionName = GeneratedColumn<String>(
    'function_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionArgsMeta = const VerificationMeta(
    'functionArgs',
  );
  @override
  late final GeneratedColumn<String> functionArgs = GeneratedColumn<String>(
    'function_args',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionResultMeta = const VerificationMeta(
    'functionResult',
  );
  @override
  late final GeneratedColumn<String> functionResult = GeneratedColumn<String>(
    'function_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _accountBookIdMeta = const VerificationMeta(
    'accountBookId',
  );
  @override
  late final GeneratedColumn<int> accountBookId = GeneratedColumn<int>(
    'account_book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_books (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    mediaType,
    mediaFilePath,
    functionName,
    functionArgs,
    functionResult,
    createdAt,
    accountBookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('media_file_path')) {
      context.handle(
        _mediaFilePathMeta,
        mediaFilePath.isAcceptableOrUnknown(
          data['media_file_path']!,
          _mediaFilePathMeta,
        ),
      );
    }
    if (data.containsKey('function_name')) {
      context.handle(
        _functionNameMeta,
        functionName.isAcceptableOrUnknown(
          data['function_name']!,
          _functionNameMeta,
        ),
      );
    }
    if (data.containsKey('function_args')) {
      context.handle(
        _functionArgsMeta,
        functionArgs.isAcceptableOrUnknown(
          data['function_args']!,
          _functionArgsMeta,
        ),
      );
    }
    if (data.containsKey('function_result')) {
      context.handle(
        _functionResultMeta,
        functionResult.isAcceptableOrUnknown(
          data['function_result']!,
          _functionResultMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
        _accountBookIdMeta,
        accountBookId.isAcceptableOrUnknown(
          data['account_book_id']!,
          _accountBookIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      ),
      mediaFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_file_path'],
      ),
      functionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}function_name'],
      ),
      functionArgs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}function_args'],
      ),
      functionResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}function_result'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      accountBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_book_id'],
      )!,
    );
  }

  @override
  $ConversationMessagesTable createAlias(String alias) {
    return $ConversationMessagesTable(attachedDatabase, alias);
  }
}

class ConversationMessage extends DataClass
    implements Insertable<ConversationMessage> {
  final int id;
  final String conversationId;
  final String role;
  final String content;
  final String? mediaType;
  final String? mediaFilePath;
  final String? functionName;
  final String? functionArgs;
  final String? functionResult;
  final DateTime createdAt;

  /// 所属账本
  final int accountBookId;
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.mediaType,
    this.mediaFilePath,
    this.functionName,
    this.functionArgs,
    this.functionResult,
    required this.createdAt,
    required this.accountBookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    if (!nullToAbsent || mediaFilePath != null) {
      map['media_file_path'] = Variable<String>(mediaFilePath);
    }
    if (!nullToAbsent || functionName != null) {
      map['function_name'] = Variable<String>(functionName);
    }
    if (!nullToAbsent || functionArgs != null) {
      map['function_args'] = Variable<String>(functionArgs);
    }
    if (!nullToAbsent || functionResult != null) {
      map['function_result'] = Variable<String>(functionResult);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['account_book_id'] = Variable<int>(accountBookId);
    return map;
  }

  ConversationMessagesCompanion toCompanion(bool nullToAbsent) {
    return ConversationMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      mediaFilePath: mediaFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaFilePath),
      functionName: functionName == null && nullToAbsent
          ? const Value.absent()
          : Value(functionName),
      functionArgs: functionArgs == null && nullToAbsent
          ? const Value.absent()
          : Value(functionArgs),
      functionResult: functionResult == null && nullToAbsent
          ? const Value.absent()
          : Value(functionResult),
      createdAt: Value(createdAt),
      accountBookId: Value(accountBookId),
    );
  }

  factory ConversationMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationMessage(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      mediaType: serializer.fromJson<String?>(json['mediaType']),
      mediaFilePath: serializer.fromJson<String?>(json['mediaFilePath']),
      functionName: serializer.fromJson<String?>(json['functionName']),
      functionArgs: serializer.fromJson<String?>(json['functionArgs']),
      functionResult: serializer.fromJson<String?>(json['functionResult']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      accountBookId: serializer.fromJson<int>(json['accountBookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'mediaType': serializer.toJson<String?>(mediaType),
      'mediaFilePath': serializer.toJson<String?>(mediaFilePath),
      'functionName': serializer.toJson<String?>(functionName),
      'functionArgs': serializer.toJson<String?>(functionArgs),
      'functionResult': serializer.toJson<String?>(functionResult),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'accountBookId': serializer.toJson<int>(accountBookId),
    };
  }

  ConversationMessage copyWith({
    int? id,
    String? conversationId,
    String? role,
    String? content,
    Value<String?> mediaType = const Value.absent(),
    Value<String?> mediaFilePath = const Value.absent(),
    Value<String?> functionName = const Value.absent(),
    Value<String?> functionArgs = const Value.absent(),
    Value<String?> functionResult = const Value.absent(),
    DateTime? createdAt,
    int? accountBookId,
  }) => ConversationMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    mediaFilePath: mediaFilePath.present
        ? mediaFilePath.value
        : this.mediaFilePath,
    functionName: functionName.present ? functionName.value : this.functionName,
    functionArgs: functionArgs.present ? functionArgs.value : this.functionArgs,
    functionResult: functionResult.present
        ? functionResult.value
        : this.functionResult,
    createdAt: createdAt ?? this.createdAt,
    accountBookId: accountBookId ?? this.accountBookId,
  );
  ConversationMessage copyWithCompanion(ConversationMessagesCompanion data) {
    return ConversationMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mediaFilePath: data.mediaFilePath.present
          ? data.mediaFilePath.value
          : this.mediaFilePath,
      functionName: data.functionName.present
          ? data.functionName.value
          : this.functionName,
      functionArgs: data.functionArgs.present
          ? data.functionArgs.value
          : this.functionArgs,
      functionResult: data.functionResult.present
          ? data.functionResult.value
          : this.functionResult,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaFilePath: $mediaFilePath, ')
          ..write('functionName: $functionName, ')
          ..write('functionArgs: $functionArgs, ')
          ..write('functionResult: $functionResult, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    mediaType,
    mediaFilePath,
    functionName,
    functionArgs,
    functionResult,
    createdAt,
    accountBookId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.mediaType == this.mediaType &&
          other.mediaFilePath == this.mediaFilePath &&
          other.functionName == this.functionName &&
          other.functionArgs == this.functionArgs &&
          other.functionResult == this.functionResult &&
          other.createdAt == this.createdAt &&
          other.accountBookId == this.accountBookId);
}

class ConversationMessagesCompanion
    extends UpdateCompanion<ConversationMessage> {
  final Value<int> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> mediaType;
  final Value<String?> mediaFilePath;
  final Value<String?> functionName;
  final Value<String?> functionArgs;
  final Value<String?> functionResult;
  final Value<DateTime> createdAt;
  final Value<int> accountBookId;
  const ConversationMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaFilePath = const Value.absent(),
    this.functionName = const Value.absent(),
    this.functionArgs = const Value.absent(),
    this.functionResult = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
  });
  ConversationMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String conversationId,
    required String role,
    required String content,
    this.mediaType = const Value.absent(),
    this.mediaFilePath = const Value.absent(),
    this.functionName = const Value.absent(),
    this.functionArgs = const Value.absent(),
    this.functionResult = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int accountBookId,
  }) : conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       accountBookId = Value(accountBookId);
  static Insertable<ConversationMessage> custom({
    Expression<int>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? mediaType,
    Expression<String>? mediaFilePath,
    Expression<String>? functionName,
    Expression<String>? functionArgs,
    Expression<String>? functionResult,
    Expression<DateTime>? createdAt,
    Expression<int>? accountBookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaFilePath != null) 'media_file_path': mediaFilePath,
      if (functionName != null) 'function_name': functionName,
      if (functionArgs != null) 'function_args': functionArgs,
      if (functionResult != null) 'function_result': functionResult,
      if (createdAt != null) 'created_at': createdAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
    });
  }

  ConversationMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? mediaType,
    Value<String?>? mediaFilePath,
    Value<String?>? functionName,
    Value<String?>? functionArgs,
    Value<String?>? functionResult,
    Value<DateTime>? createdAt,
    Value<int>? accountBookId,
  }) {
    return ConversationMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaFilePath: mediaFilePath ?? this.mediaFilePath,
      functionName: functionName ?? this.functionName,
      functionArgs: functionArgs ?? this.functionArgs,
      functionResult: functionResult ?? this.functionResult,
      createdAt: createdAt ?? this.createdAt,
      accountBookId: accountBookId ?? this.accountBookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mediaFilePath.present) {
      map['media_file_path'] = Variable<String>(mediaFilePath.value);
    }
    if (functionName.present) {
      map['function_name'] = Variable<String>(functionName.value);
    }
    if (functionArgs.present) {
      map['function_args'] = Variable<String>(functionArgs.value);
    }
    if (functionResult.present) {
      map['function_result'] = Variable<String>(functionResult.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<int>(accountBookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaFilePath: $mediaFilePath, ')
          ..write('functionName: $functionName, ')
          ..write('functionArgs: $functionArgs, ')
          ..write('functionResult: $functionResult, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountBookId: $accountBookId')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('用户'),
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    avatarPath,
    gender,
    email,
    phone,
    uid,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String nickname;
  final String? avatarPath;
  final String? gender;
  final String? email;
  final String? phone;
  final String uid;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.nickname,
    this.avatarPath,
    this.gender,
    this.email,
    this.phone,
    required this.uid,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['uid'] = Variable<String>(uid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      uid: Value(uid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      gender: serializer.fromJson<String?>(json['gender']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      uid: serializer.fromJson<String>(json['uid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'gender': serializer.toJson<String?>(gender),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'uid': serializer.toJson<String>(uid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? nickname,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    gender: gender.present ? gender.value : this.gender,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    uid: uid ?? this.uid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      gender: data.gender.present ? data.gender.value : this.gender,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      uid: data.uid.present ? data.uid.value : this.uid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('gender: $gender, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('uid: $uid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    avatarPath,
    gender,
    email,
    phone,
    uid,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avatarPath == this.avatarPath &&
          other.gender == this.gender &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.uid == this.uid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String?> avatarPath;
  final Value<String?> gender;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> uid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.gender = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.uid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.gender = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.uid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? avatarPath,
    Expression<String>? gender,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? uid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (gender != null) 'gender': gender,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (uid != null) 'uid': uid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<String?>? avatarPath,
    Value<String?>? gender,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? uid,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('gender: $gender, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('uid: $uid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CheckInRecordsTable extends CheckInRecords
    with TableInfo<$CheckInRecordsTable, CheckInRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _checkInDateMeta = const VerificationMeta(
    'checkInDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkInDate = GeneratedColumn<DateTime>(
    'check_in_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMakeupMeta = const VerificationMeta(
    'isMakeup',
  );
  @override
  late final GeneratedColumn<bool> isMakeup = GeneratedColumn<bool>(
    'is_makeup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_makeup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    checkInDate,
    isMakeup,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_in_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckInRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('check_in_date')) {
      context.handle(
        _checkInDateMeta,
        checkInDate.isAcceptableOrUnknown(
          data['check_in_date']!,
          _checkInDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInDateMeta);
    }
    if (data.containsKey('is_makeup')) {
      context.handle(
        _isMakeupMeta,
        isMakeup.isAcceptableOrUnknown(data['is_makeup']!, _isMakeupMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {checkInDate},
  ];
  @override
  CheckInRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckInRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      checkInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_date'],
      )!,
      isMakeup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_makeup'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CheckInRecordsTable createAlias(String alias) {
    return $CheckInRecordsTable(attachedDatabase, alias);
  }
}

class CheckInRecord extends DataClass implements Insertable<CheckInRecord> {
  final int id;
  final int userId;
  final DateTime checkInDate;
  final bool isMakeup;
  final DateTime createdAt;
  const CheckInRecord({
    required this.id,
    required this.userId,
    required this.checkInDate,
    required this.isMakeup,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['check_in_date'] = Variable<DateTime>(checkInDate);
    map['is_makeup'] = Variable<bool>(isMakeup);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CheckInRecordsCompanion toCompanion(bool nullToAbsent) {
    return CheckInRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      checkInDate: Value(checkInDate),
      isMakeup: Value(isMakeup),
      createdAt: Value(createdAt),
    );
  }

  factory CheckInRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckInRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      checkInDate: serializer.fromJson<DateTime>(json['checkInDate']),
      isMakeup: serializer.fromJson<bool>(json['isMakeup']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'checkInDate': serializer.toJson<DateTime>(checkInDate),
      'isMakeup': serializer.toJson<bool>(isMakeup),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CheckInRecord copyWith({
    int? id,
    int? userId,
    DateTime? checkInDate,
    bool? isMakeup,
    DateTime? createdAt,
  }) => CheckInRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    checkInDate: checkInDate ?? this.checkInDate,
    isMakeup: isMakeup ?? this.isMakeup,
    createdAt: createdAt ?? this.createdAt,
  );
  CheckInRecord copyWithCompanion(CheckInRecordsCompanion data) {
    return CheckInRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      checkInDate: data.checkInDate.present
          ? data.checkInDate.value
          : this.checkInDate,
      isMakeup: data.isMakeup.present ? data.isMakeup.value : this.isMakeup,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('isMakeup: $isMakeup, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, checkInDate, isMakeup, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckInRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.checkInDate == this.checkInDate &&
          other.isMakeup == this.isMakeup &&
          other.createdAt == this.createdAt);
}

class CheckInRecordsCompanion extends UpdateCompanion<CheckInRecord> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> checkInDate;
  final Value<bool> isMakeup;
  final Value<DateTime> createdAt;
  const CheckInRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.checkInDate = const Value.absent(),
    this.isMakeup = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CheckInRecordsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime checkInDate,
    this.isMakeup = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : checkInDate = Value(checkInDate);
  static Insertable<CheckInRecord> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? checkInDate,
    Expression<bool>? isMakeup,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (checkInDate != null) 'check_in_date': checkInDate,
      if (isMakeup != null) 'is_makeup': isMakeup,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CheckInRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? checkInDate,
    Value<bool>? isMakeup,
    Value<DateTime>? createdAt,
  }) {
    return CheckInRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkInDate: checkInDate ?? this.checkInDate,
      isMakeup: isMakeup ?? this.isMakeup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (checkInDate.present) {
      map['check_in_date'] = Variable<DateTime>(checkInDate.value);
    }
    if (isMakeup.present) {
      map['is_makeup'] = Variable<bool>(isMakeup.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('isMakeup: $isMakeup, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AcCoinBalancesTable extends AcCoinBalances
    with TableInfo<$AcCoinBalancesTable, AcCoinBalance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcCoinBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, balance, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ac_coin_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcCoinBalance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcCoinBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcCoinBalance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AcCoinBalancesTable createAlias(String alias) {
    return $AcCoinBalancesTable(attachedDatabase, alias);
  }
}

class AcCoinBalance extends DataClass implements Insertable<AcCoinBalance> {
  final int id;
  final int userId;
  final int balance;
  final DateTime updatedAt;
  const AcCoinBalance({
    required this.id,
    required this.userId,
    required this.balance,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['balance'] = Variable<int>(balance);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AcCoinBalancesCompanion toCompanion(bool nullToAbsent) {
    return AcCoinBalancesCompanion(
      id: Value(id),
      userId: Value(userId),
      balance: Value(balance),
      updatedAt: Value(updatedAt),
    );
  }

  factory AcCoinBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcCoinBalance(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      balance: serializer.fromJson<int>(json['balance']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'balance': serializer.toJson<int>(balance),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AcCoinBalance copyWith({
    int? id,
    int? userId,
    int? balance,
    DateTime? updatedAt,
  }) => AcCoinBalance(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    balance: balance ?? this.balance,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AcCoinBalance copyWithCompanion(AcCoinBalancesCompanion data) {
    return AcCoinBalance(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      balance: data.balance.present ? data.balance.value : this.balance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcCoinBalance(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, balance, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcCoinBalance &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.balance == this.balance &&
          other.updatedAt == this.updatedAt);
}

class AcCoinBalancesCompanion extends UpdateCompanion<AcCoinBalance> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> balance;
  final Value<DateTime> updatedAt;
  const AcCoinBalancesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AcCoinBalancesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<AcCoinBalance> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? balance,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (balance != null) 'balance': balance,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AcCoinBalancesCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? balance,
    Value<DateTime>? updatedAt,
  }) {
    return AcCoinBalancesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcCoinBalancesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AcCoinTransactionsTable extends AcCoinTransactions
    with TableInfo<$AcCoinTransactionsTable, AcCoinTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcCoinTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 30),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _relatedDateMeta = const VerificationMeta(
    'relatedDate',
  );
  @override
  late final GeneratedColumn<int> relatedDate = GeneratedColumn<int>(
    'related_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amount,
    type,
    description,
    relatedDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ac_coin_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcCoinTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('related_date')) {
      context.handle(
        _relatedDateMeta,
        relatedDate.isAcceptableOrUnknown(
          data['related_date']!,
          _relatedDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcCoinTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcCoinTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      relatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AcCoinTransactionsTable createAlias(String alias) {
    return $AcCoinTransactionsTable(attachedDatabase, alias);
  }
}

class AcCoinTransaction extends DataClass
    implements Insertable<AcCoinTransaction> {
  final int id;
  final int userId;
  final int amount;
  final String type;
  final String description;
  final int? relatedDate;
  final DateTime createdAt;
  const AcCoinTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.relatedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['amount'] = Variable<int>(amount);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || relatedDate != null) {
      map['related_date'] = Variable<int>(relatedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AcCoinTransactionsCompanion toCompanion(bool nullToAbsent) {
    return AcCoinTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      type: Value(type),
      description: Value(description),
      relatedDate: relatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedDate),
      createdAt: Value(createdAt),
    );
  }

  factory AcCoinTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcCoinTransaction(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      amount: serializer.fromJson<int>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      relatedDate: serializer.fromJson<int?>(json['relatedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'amount': serializer.toJson<int>(amount),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'relatedDate': serializer.toJson<int?>(relatedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AcCoinTransaction copyWith({
    int? id,
    int? userId,
    int? amount,
    String? type,
    String? description,
    Value<int?> relatedDate = const Value.absent(),
    DateTime? createdAt,
  }) => AcCoinTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    description: description ?? this.description,
    relatedDate: relatedDate.present ? relatedDate.value : this.relatedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  AcCoinTransaction copyWithCompanion(AcCoinTransactionsCompanion data) {
    return AcCoinTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      relatedDate: data.relatedDate.present
          ? data.relatedDate.value
          : this.relatedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcCoinTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('relatedDate: $relatedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    amount,
    type,
    description,
    relatedDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcCoinTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.description == this.description &&
          other.relatedDate == this.relatedDate &&
          other.createdAt == this.createdAt);
}

class AcCoinTransactionsCompanion extends UpdateCompanion<AcCoinTransaction> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> amount;
  final Value<String> type;
  final Value<String> description;
  final Value<int?> relatedDate;
  final Value<DateTime> createdAt;
  const AcCoinTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.relatedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AcCoinTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required int amount,
    required String type,
    this.description = const Value.absent(),
    this.relatedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amount = Value(amount),
       type = Value(type);
  static Insertable<AcCoinTransaction> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? amount,
    Expression<String>? type,
    Expression<String>? description,
    Expression<int>? relatedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (relatedDate != null) 'related_date': relatedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AcCoinTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? amount,
    Value<String>? type,
    Value<String>? description,
    Value<int?>? relatedDate,
    Value<DateTime>? createdAt,
  }) {
    return AcCoinTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      relatedDate: relatedDate ?? this.relatedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (relatedDate.present) {
      map['related_date'] = Variable<int>(relatedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcCoinTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('relatedDate: $relatedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountBooksTable accountBooks = $AccountBooksTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $AiTrainingRecordsTable aiTrainingRecords =
      $AiTrainingRecordsTable(this);
  late final $ConversationMessagesTable conversationMessages =
      $ConversationMessagesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $CheckInRecordsTable checkInRecords = $CheckInRecordsTable(this);
  late final $AcCoinBalancesTable acCoinBalances = $AcCoinBalancesTable(this);
  late final $AcCoinTransactionsTable acCoinTransactions =
      $AcCoinTransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountBooks,
    categories,
    transactions,
    budgets,
    aiTrainingRecords,
    conversationMessages,
    userProfiles,
    checkInRecords,
    acCoinBalances,
    acCoinTransactions,
  ];
}

typedef $$AccountBooksTableCreateCompanionBuilder =
    AccountBooksCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<String?> description,
      Value<String?> icon,
      Value<bool> isDefault,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AccountBooksTableUpdateCompanionBuilder =
    AccountBooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String?> description,
      Value<String?> icon,
      Value<bool> isDefault,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AccountBooksTableReferences
    extends BaseReferences<_$AppDatabase, $AccountBooksTable, AccountBook> {
  $$AccountBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.accountBooks.id,
      db.transactions.accountBookId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: $_aliasNameGenerator(
      db.accountBooks.id,
      db.budgets.accountBookId,
    ),
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.accountBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiTrainingRecordsTable, List<AiTrainingRecord>>
  _aiTrainingRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.aiTrainingRecords,
        aliasName: $_aliasNameGenerator(
          db.accountBooks.id,
          db.aiTrainingRecords.accountBookId,
        ),
      );

  $$AiTrainingRecordsTableProcessedTableManager get aiTrainingRecordsRefs {
    final manager = $$AiTrainingRecordsTableTableManager(
      $_db,
      $_db.aiTrainingRecords,
    ).filter((f) => f.accountBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiTrainingRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ConversationMessagesTable,
    List<ConversationMessage>
  >
  _conversationMessagesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.conversationMessages,
        aliasName: $_aliasNameGenerator(
          db.accountBooks.id,
          db.conversationMessages.accountBookId,
        ),
      );

  $$ConversationMessagesTableProcessedTableManager
  get conversationMessagesRefs {
    final manager = $$ConversationMessagesTableTableManager(
      $_db,
      $_db.conversationMessages,
    ).filter((f) => f.accountBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _conversationMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountBooksTableFilterComposer
    extends Composer<_$AppDatabase, $AccountBooksTable> {
  $$AccountBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiTrainingRecordsRefs(
    Expression<bool> Function($$AiTrainingRecordsTableFilterComposer f) f,
  ) {
    final $$AiTrainingRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiTrainingRecords,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiTrainingRecordsTableFilterComposer(
            $db: $db,
            $table: $db.aiTrainingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationMessagesRefs(
    Expression<bool> Function($$ConversationMessagesTableFilterComposer f) f,
  ) {
    final $$ConversationMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversationMessages,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationMessagesTableFilterComposer(
            $db: $db,
            $table: $db.conversationMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountBooksTable> {
  $$AccountBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountBooksTable> {
  $$AccountBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.accountBookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiTrainingRecordsRefs<T extends Object>(
    Expression<T> Function($$AiTrainingRecordsTableAnnotationComposer a) f,
  ) {
    final $$AiTrainingRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.aiTrainingRecords,
          getReferencedColumn: (t) => t.accountBookId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AiTrainingRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.aiTrainingRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> conversationMessagesRefs<T extends Object>(
    Expression<T> Function($$ConversationMessagesTableAnnotationComposer a) f,
  ) {
    final $$ConversationMessagesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.conversationMessages,
          getReferencedColumn: (t) => t.accountBookId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConversationMessagesTableAnnotationComposer(
                $db: $db,
                $table: $db.conversationMessages,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccountBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountBooksTable,
          AccountBook,
          $$AccountBooksTableFilterComposer,
          $$AccountBooksTableOrderingComposer,
          $$AccountBooksTableAnnotationComposer,
          $$AccountBooksTableCreateCompanionBuilder,
          $$AccountBooksTableUpdateCompanionBuilder,
          (AccountBook, $$AccountBooksTableReferences),
          AccountBook,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool budgetsRefs,
            bool aiTrainingRecordsRefs,
            bool conversationMessagesRefs,
          })
        > {
  $$AccountBooksTableTableManager(_$AppDatabase db, $AccountBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountBooksCompanion(
                id: id,
                name: name,
                type: type,
                description: description,
                icon: icon,
                isDefault: isDefault,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountBooksCompanion.insert(
                id: id,
                name: name,
                type: type,
                description: description,
                icon: icon,
                isDefault: isDefault,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                budgetsRefs = false,
                aiTrainingRecordsRefs = false,
                conversationMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (budgetsRefs) db.budgets,
                    if (aiTrainingRecordsRefs) db.aiTrainingRecords,
                    if (conversationMessagesRefs) db.conversationMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          AccountBook,
                          $AccountBooksTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountBooksTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          AccountBook,
                          $AccountBooksTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$AccountBooksTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiTrainingRecordsRefs)
                        await $_getPrefetchedData<
                          AccountBook,
                          $AccountBooksTable,
                          AiTrainingRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AccountBooksTableReferences
                              ._aiTrainingRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).aiTrainingRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conversationMessagesRefs)
                        await $_getPrefetchedData<
                          AccountBook,
                          $AccountBooksTable,
                          ConversationMessage
                        >(
                          currentTable: table,
                          referencedTable: $$AccountBooksTableReferences
                              ._conversationMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountBookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountBooksTable,
      AccountBook,
      $$AccountBooksTableFilterComposer,
      $$AccountBooksTableOrderingComposer,
      $$AccountBooksTableAnnotationComposer,
      $$AccountBooksTableCreateCompanionBuilder,
      $$AccountBooksTableUpdateCompanionBuilder,
      (AccountBook, $$AccountBooksTableReferences),
      AccountBook,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool budgetsRefs,
        bool aiTrainingRecordsRefs,
        bool conversationMessagesRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> icon,
      Value<String> color,
      Value<int?> parentId,
      Value<int> level,
      Value<bool> isSystem,
      Value<bool> isExpense,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> icon,
      Value<String> color,
      Value<int?> parentId,
      Value<int> level,
      Value<bool> isSystem,
      Value<bool> isExpense,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.categories.parentId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: $_aliasNameGenerator(db.categories.id, db.budgets.categoryId),
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool parentId, bool budgetsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                level: level,
                isSystem: isSystem,
                isExpense: isExpense,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                level: level,
                isSystem: isSystem,
                isExpense: isExpense,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, budgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (budgetsRefs) db.budgets],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$CategoriesTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$CategoriesTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (budgetsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Budget
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._budgetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).budgetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool parentId, bool budgetsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required String description,
      required int categoryId,
      Value<int?> subcategoryId,
      required DateTime transactionDate,
      Value<String?> originalInput,
      Value<String?> mediaFilePath,
      Value<String?> mediaType,
      Value<double?> aiConfidence,
      Value<String> aiSource,
      Value<bool> userConfirmed,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required int accountBookId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<String> description,
      Value<int> categoryId,
      Value<int?> subcategoryId,
      Value<DateTime> transactionDate,
      Value<String?> originalInput,
      Value<String?> mediaFilePath,
      Value<String?> mediaType,
      Value<double?> aiConfidence,
      Value<String> aiSource,
      Value<bool> userConfirmed,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> accountBookId,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.subcategoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<int>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountBooksTable _accountBookIdTable(_$AppDatabase db) =>
      db.accountBooks.createAlias(
        $_aliasNameGenerator(db.transactions.accountBookId, db.accountBooks.id),
      );

  $$AccountBooksTableProcessedTableManager get accountBookId {
    final $_column = $_itemColumn<int>('account_book_id')!;

    final manager = $$AccountBooksTableTableManager(
      $_db,
      $_db.accountBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalInput => $composableBuilder(
    column: $table.originalInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aiConfidence => $composableBuilder(
    column: $table.aiConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiSource => $composableBuilder(
    column: $table.aiSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get subcategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableFilterComposer get accountBookId {
    final $$AccountBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableFilterComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalInput => $composableBuilder(
    column: $table.originalInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aiConfidence => $composableBuilder(
    column: $table.aiConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiSource => $composableBuilder(
    column: $table.aiSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get subcategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableOrderingComposer get accountBookId {
    final $$AccountBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableOrderingComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalInput => $composableBuilder(
    column: $table.originalInput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<double> get aiConfidence => $composableBuilder(
    column: $table.aiConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiSource =>
      $composableBuilder(column: $table.aiSource, builder: (column) => column);

  GeneratedColumn<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get subcategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableAnnotationComposer get accountBookId {
    final $$AccountBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool categoryId,
            bool subcategoryId,
            bool accountBookId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> subcategoryId = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> originalInput = const Value.absent(),
                Value<String?> mediaFilePath = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<double?> aiConfidence = const Value.absent(),
                Value<String> aiSource = const Value.absent(),
                Value<bool> userConfirmed = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> accountBookId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                description: description,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                transactionDate: transactionDate,
                originalInput: originalInput,
                mediaFilePath: mediaFilePath,
                mediaType: mediaType,
                aiConfidence: aiConfidence,
                aiSource: aiSource,
                userConfirmed: userConfirmed,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                accountBookId: accountBookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required String description,
                required int categoryId,
                Value<int?> subcategoryId = const Value.absent(),
                required DateTime transactionDate,
                Value<String?> originalInput = const Value.absent(),
                Value<String?> mediaFilePath = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<double?> aiConfidence = const Value.absent(),
                Value<String> aiSource = const Value.absent(),
                Value<bool> userConfirmed = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required int accountBookId,
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                description: description,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                transactionDate: transactionDate,
                originalInput: originalInput,
                mediaFilePath: mediaFilePath,
                mediaType: mediaType,
                aiConfidence: aiConfidence,
                aiSource: aiSource,
                userConfirmed: userConfirmed,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                accountBookId: accountBookId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                subcategoryId = false,
                accountBookId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subcategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subcategoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._subcategoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._subcategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (accountBookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountBookId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._accountBookIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._accountBookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool categoryId,
        bool subcategoryId,
        bool accountBookId,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<int?> categoryId,
      required double amount,
      Value<String> period,
      required int year,
      required int month,
      Value<DateTime> createdAt,
      required int accountBookId,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<int?> categoryId,
      Value<double> amount,
      Value<String> period,
      Value<int> year,
      Value<int> month,
      Value<DateTime> createdAt,
      Value<int> accountBookId,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.budgets.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountBooksTable _accountBookIdTable(_$AppDatabase db) =>
      db.accountBooks.createAlias(
        $_aliasNameGenerator(db.budgets.accountBookId, db.accountBooks.id),
      );

  $$AccountBooksTableProcessedTableManager get accountBookId {
    final $_column = $_itemColumn<int>('account_book_id')!;

    final manager = $$AccountBooksTableTableManager(
      $_db,
      $_db.accountBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableFilterComposer get accountBookId {
    final $$AccountBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableFilterComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableOrderingComposer get accountBookId {
    final $$AccountBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableOrderingComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountBooksTableAnnotationComposer get accountBookId {
    final $$AccountBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool categoryId, bool accountBookId})
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> accountBookId = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                amount: amount,
                period: period,
                year: year,
                month: month,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                required double amount,
                Value<String> period = const Value.absent(),
                required int year,
                required int month,
                Value<DateTime> createdAt = const Value.absent(),
                required int accountBookId,
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                amount: amount,
                period: period,
                year: year,
                month: month,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, accountBookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$BudgetsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (accountBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountBookId,
                                referencedTable: $$BudgetsTableReferences
                                    ._accountBookIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._accountBookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool categoryId, bool accountBookId})
    >;
typedef $$AiTrainingRecordsTableCreateCompanionBuilder =
    AiTrainingRecordsCompanion Function({
      Value<int> id,
      required String inputText,
      Value<int?> predictedCategoryId,
      Value<int?> actualCategoryId,
      Value<bool?> wasCorrect,
      Value<DateTime> createdAt,
      required int accountBookId,
    });
typedef $$AiTrainingRecordsTableUpdateCompanionBuilder =
    AiTrainingRecordsCompanion Function({
      Value<int> id,
      Value<String> inputText,
      Value<int?> predictedCategoryId,
      Value<int?> actualCategoryId,
      Value<bool?> wasCorrect,
      Value<DateTime> createdAt,
      Value<int> accountBookId,
    });

final class $$AiTrainingRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AiTrainingRecordsTable,
          AiTrainingRecord
        > {
  $$AiTrainingRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountBooksTable _accountBookIdTable(_$AppDatabase db) =>
      db.accountBooks.createAlias(
        $_aliasNameGenerator(
          db.aiTrainingRecords.accountBookId,
          db.accountBooks.id,
        ),
      );

  $$AccountBooksTableProcessedTableManager get accountBookId {
    final $_column = $_itemColumn<int>('account_book_id')!;

    final manager = $$AccountBooksTableTableManager(
      $_db,
      $_db.accountBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AiTrainingRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AiTrainingRecordsTable> {
  $$AiTrainingRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputText => $composableBuilder(
    column: $table.inputText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get predictedCategoryId => $composableBuilder(
    column: $table.predictedCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualCategoryId => $composableBuilder(
    column: $table.actualCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountBooksTableFilterComposer get accountBookId {
    final $$AccountBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableFilterComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiTrainingRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiTrainingRecordsTable> {
  $$AiTrainingRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputText => $composableBuilder(
    column: $table.inputText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get predictedCategoryId => $composableBuilder(
    column: $table.predictedCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualCategoryId => $composableBuilder(
    column: $table.actualCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountBooksTableOrderingComposer get accountBookId {
    final $$AccountBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableOrderingComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiTrainingRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiTrainingRecordsTable> {
  $$AiTrainingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inputText =>
      $composableBuilder(column: $table.inputText, builder: (column) => column);

  GeneratedColumn<int> get predictedCategoryId => $composableBuilder(
    column: $table.predictedCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualCategoryId => $composableBuilder(
    column: $table.actualCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountBooksTableAnnotationComposer get accountBookId {
    final $$AccountBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiTrainingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiTrainingRecordsTable,
          AiTrainingRecord,
          $$AiTrainingRecordsTableFilterComposer,
          $$AiTrainingRecordsTableOrderingComposer,
          $$AiTrainingRecordsTableAnnotationComposer,
          $$AiTrainingRecordsTableCreateCompanionBuilder,
          $$AiTrainingRecordsTableUpdateCompanionBuilder,
          (AiTrainingRecord, $$AiTrainingRecordsTableReferences),
          AiTrainingRecord,
          PrefetchHooks Function({bool accountBookId})
        > {
  $$AiTrainingRecordsTableTableManager(
    _$AppDatabase db,
    $AiTrainingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiTrainingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiTrainingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiTrainingRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> inputText = const Value.absent(),
                Value<int?> predictedCategoryId = const Value.absent(),
                Value<int?> actualCategoryId = const Value.absent(),
                Value<bool?> wasCorrect = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> accountBookId = const Value.absent(),
              }) => AiTrainingRecordsCompanion(
                id: id,
                inputText: inputText,
                predictedCategoryId: predictedCategoryId,
                actualCategoryId: actualCategoryId,
                wasCorrect: wasCorrect,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String inputText,
                Value<int?> predictedCategoryId = const Value.absent(),
                Value<int?> actualCategoryId = const Value.absent(),
                Value<bool?> wasCorrect = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required int accountBookId,
              }) => AiTrainingRecordsCompanion.insert(
                id: id,
                inputText: inputText,
                predictedCategoryId: predictedCategoryId,
                actualCategoryId: actualCategoryId,
                wasCorrect: wasCorrect,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiTrainingRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountBookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountBookId,
                                referencedTable:
                                    $$AiTrainingRecordsTableReferences
                                        ._accountBookIdTable(db),
                                referencedColumn:
                                    $$AiTrainingRecordsTableReferences
                                        ._accountBookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AiTrainingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiTrainingRecordsTable,
      AiTrainingRecord,
      $$AiTrainingRecordsTableFilterComposer,
      $$AiTrainingRecordsTableOrderingComposer,
      $$AiTrainingRecordsTableAnnotationComposer,
      $$AiTrainingRecordsTableCreateCompanionBuilder,
      $$AiTrainingRecordsTableUpdateCompanionBuilder,
      (AiTrainingRecord, $$AiTrainingRecordsTableReferences),
      AiTrainingRecord,
      PrefetchHooks Function({bool accountBookId})
    >;
typedef $$ConversationMessagesTableCreateCompanionBuilder =
    ConversationMessagesCompanion Function({
      Value<int> id,
      required String conversationId,
      required String role,
      required String content,
      Value<String?> mediaType,
      Value<String?> mediaFilePath,
      Value<String?> functionName,
      Value<String?> functionArgs,
      Value<String?> functionResult,
      Value<DateTime> createdAt,
      required int accountBookId,
    });
typedef $$ConversationMessagesTableUpdateCompanionBuilder =
    ConversationMessagesCompanion Function({
      Value<int> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<String?> mediaType,
      Value<String?> mediaFilePath,
      Value<String?> functionName,
      Value<String?> functionArgs,
      Value<String?> functionResult,
      Value<DateTime> createdAt,
      Value<int> accountBookId,
    });

final class $$ConversationMessagesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConversationMessagesTable,
          ConversationMessage
        > {
  $$ConversationMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountBooksTable _accountBookIdTable(_$AppDatabase db) =>
      db.accountBooks.createAlias(
        $_aliasNameGenerator(
          db.conversationMessages.accountBookId,
          db.accountBooks.id,
        ),
      );

  $$AccountBooksTableProcessedTableManager get accountBookId {
    final $_column = $_itemColumn<int>('account_book_id')!;

    final manager = $$AccountBooksTableTableManager(
      $_db,
      $_db.accountBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConversationMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationMessagesTable> {
  $$ConversationMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functionArgs => $composableBuilder(
    column: $table.functionArgs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functionResult => $composableBuilder(
    column: $table.functionResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountBooksTableFilterComposer get accountBookId {
    final $$AccountBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableFilterComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationMessagesTable> {
  $$ConversationMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functionArgs => $composableBuilder(
    column: $table.functionArgs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functionResult => $composableBuilder(
    column: $table.functionResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountBooksTableOrderingComposer get accountBookId {
    final $$AccountBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableOrderingComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationMessagesTable> {
  $$ConversationMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mediaFilePath => $composableBuilder(
    column: $table.mediaFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get functionArgs => $composableBuilder(
    column: $table.functionArgs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get functionResult => $composableBuilder(
    column: $table.functionResult,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountBooksTableAnnotationComposer get accountBookId {
    final $$AccountBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountBookId,
      referencedTable: $db.accountBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.accountBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationMessagesTable,
          ConversationMessage,
          $$ConversationMessagesTableFilterComposer,
          $$ConversationMessagesTableOrderingComposer,
          $$ConversationMessagesTableAnnotationComposer,
          $$ConversationMessagesTableCreateCompanionBuilder,
          $$ConversationMessagesTableUpdateCompanionBuilder,
          (ConversationMessage, $$ConversationMessagesTableReferences),
          ConversationMessage,
          PrefetchHooks Function({bool accountBookId})
        > {
  $$ConversationMessagesTableTableManager(
    _$AppDatabase db,
    $ConversationMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationMessagesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConversationMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<String?> mediaFilePath = const Value.absent(),
                Value<String?> functionName = const Value.absent(),
                Value<String?> functionArgs = const Value.absent(),
                Value<String?> functionResult = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> accountBookId = const Value.absent(),
              }) => ConversationMessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                mediaType: mediaType,
                mediaFilePath: mediaFilePath,
                functionName: functionName,
                functionArgs: functionArgs,
                functionResult: functionResult,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conversationId,
                required String role,
                required String content,
                Value<String?> mediaType = const Value.absent(),
                Value<String?> mediaFilePath = const Value.absent(),
                Value<String?> functionName = const Value.absent(),
                Value<String?> functionArgs = const Value.absent(),
                Value<String?> functionResult = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required int accountBookId,
              }) => ConversationMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                mediaType: mediaType,
                mediaFilePath: mediaFilePath,
                functionName: functionName,
                functionArgs: functionArgs,
                functionResult: functionResult,
                createdAt: createdAt,
                accountBookId: accountBookId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountBookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountBookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountBookId,
                                referencedTable:
                                    $$ConversationMessagesTableReferences
                                        ._accountBookIdTable(db),
                                referencedColumn:
                                    $$ConversationMessagesTableReferences
                                        ._accountBookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConversationMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationMessagesTable,
      ConversationMessage,
      $$ConversationMessagesTableFilterComposer,
      $$ConversationMessagesTableOrderingComposer,
      $$ConversationMessagesTableAnnotationComposer,
      $$ConversationMessagesTableCreateCompanionBuilder,
      $$ConversationMessagesTableUpdateCompanionBuilder,
      (ConversationMessage, $$ConversationMessagesTableReferences),
      ConversationMessage,
      PrefetchHooks Function({bool accountBookId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> nickname,
      Value<String?> avatarPath,
      Value<String?> gender,
      Value<String?> email,
      Value<String?> phone,
      Value<String> uid,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> nickname,
      Value<String?> avatarPath,
      Value<String?> gender,
      Value<String?> email,
      Value<String?> phone,
      Value<String> uid,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                nickname: nickname,
                avatarPath: avatarPath,
                gender: gender,
                email: email,
                phone: phone,
                uid: uid,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                avatarPath: avatarPath,
                gender: gender,
                email: email,
                phone: phone,
                uid: uid,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$CheckInRecordsTableCreateCompanionBuilder =
    CheckInRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      required DateTime checkInDate,
      Value<bool> isMakeup,
      Value<DateTime> createdAt,
    });
typedef $$CheckInRecordsTableUpdateCompanionBuilder =
    CheckInRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> checkInDate,
      Value<bool> isMakeup,
      Value<DateTime> createdAt,
    });

class $$CheckInRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMakeup => $composableBuilder(
    column: $table.isMakeup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckInRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMakeup => $composableBuilder(
    column: $table.isMakeup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckInRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMakeup =>
      $composableBuilder(column: $table.isMakeup, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CheckInRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckInRecordsTable,
          CheckInRecord,
          $$CheckInRecordsTableFilterComposer,
          $$CheckInRecordsTableOrderingComposer,
          $$CheckInRecordsTableAnnotationComposer,
          $$CheckInRecordsTableCreateCompanionBuilder,
          $$CheckInRecordsTableUpdateCompanionBuilder,
          (
            CheckInRecord,
            BaseReferences<_$AppDatabase, $CheckInRecordsTable, CheckInRecord>,
          ),
          CheckInRecord,
          PrefetchHooks Function()
        > {
  $$CheckInRecordsTableTableManager(
    _$AppDatabase db,
    $CheckInRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> checkInDate = const Value.absent(),
                Value<bool> isMakeup = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CheckInRecordsCompanion(
                id: id,
                userId: userId,
                checkInDate: checkInDate,
                isMakeup: isMakeup,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                required DateTime checkInDate,
                Value<bool> isMakeup = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CheckInRecordsCompanion.insert(
                id: id,
                userId: userId,
                checkInDate: checkInDate,
                isMakeup: isMakeup,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckInRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckInRecordsTable,
      CheckInRecord,
      $$CheckInRecordsTableFilterComposer,
      $$CheckInRecordsTableOrderingComposer,
      $$CheckInRecordsTableAnnotationComposer,
      $$CheckInRecordsTableCreateCompanionBuilder,
      $$CheckInRecordsTableUpdateCompanionBuilder,
      (
        CheckInRecord,
        BaseReferences<_$AppDatabase, $CheckInRecordsTable, CheckInRecord>,
      ),
      CheckInRecord,
      PrefetchHooks Function()
    >;
typedef $$AcCoinBalancesTableCreateCompanionBuilder =
    AcCoinBalancesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> balance,
      Value<DateTime> updatedAt,
    });
typedef $$AcCoinBalancesTableUpdateCompanionBuilder =
    AcCoinBalancesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> balance,
      Value<DateTime> updatedAt,
    });

class $$AcCoinBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $AcCoinBalancesTable> {
  $$AcCoinBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcCoinBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AcCoinBalancesTable> {
  $$AcCoinBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcCoinBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcCoinBalancesTable> {
  $$AcCoinBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AcCoinBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcCoinBalancesTable,
          AcCoinBalance,
          $$AcCoinBalancesTableFilterComposer,
          $$AcCoinBalancesTableOrderingComposer,
          $$AcCoinBalancesTableAnnotationComposer,
          $$AcCoinBalancesTableCreateCompanionBuilder,
          $$AcCoinBalancesTableUpdateCompanionBuilder,
          (
            AcCoinBalance,
            BaseReferences<_$AppDatabase, $AcCoinBalancesTable, AcCoinBalance>,
          ),
          AcCoinBalance,
          PrefetchHooks Function()
        > {
  $$AcCoinBalancesTableTableManager(
    _$AppDatabase db,
    $AcCoinBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcCoinBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcCoinBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcCoinBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AcCoinBalancesCompanion(
                id: id,
                userId: userId,
                balance: balance,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AcCoinBalancesCompanion.insert(
                id: id,
                userId: userId,
                balance: balance,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcCoinBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcCoinBalancesTable,
      AcCoinBalance,
      $$AcCoinBalancesTableFilterComposer,
      $$AcCoinBalancesTableOrderingComposer,
      $$AcCoinBalancesTableAnnotationComposer,
      $$AcCoinBalancesTableCreateCompanionBuilder,
      $$AcCoinBalancesTableUpdateCompanionBuilder,
      (
        AcCoinBalance,
        BaseReferences<_$AppDatabase, $AcCoinBalancesTable, AcCoinBalance>,
      ),
      AcCoinBalance,
      PrefetchHooks Function()
    >;
typedef $$AcCoinTransactionsTableCreateCompanionBuilder =
    AcCoinTransactionsCompanion Function({
      Value<int> id,
      Value<int> userId,
      required int amount,
      required String type,
      Value<String> description,
      Value<int?> relatedDate,
      Value<DateTime> createdAt,
    });
typedef $$AcCoinTransactionsTableUpdateCompanionBuilder =
    AcCoinTransactionsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> amount,
      Value<String> type,
      Value<String> description,
      Value<int?> relatedDate,
      Value<DateTime> createdAt,
    });

class $$AcCoinTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $AcCoinTransactionsTable> {
  $$AcCoinTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcCoinTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AcCoinTransactionsTable> {
  $$AcCoinTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcCoinTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcCoinTransactionsTable> {
  $$AcCoinTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AcCoinTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcCoinTransactionsTable,
          AcCoinTransaction,
          $$AcCoinTransactionsTableFilterComposer,
          $$AcCoinTransactionsTableOrderingComposer,
          $$AcCoinTransactionsTableAnnotationComposer,
          $$AcCoinTransactionsTableCreateCompanionBuilder,
          $$AcCoinTransactionsTableUpdateCompanionBuilder,
          (
            AcCoinTransaction,
            BaseReferences<
              _$AppDatabase,
              $AcCoinTransactionsTable,
              AcCoinTransaction
            >,
          ),
          AcCoinTransaction,
          PrefetchHooks Function()
        > {
  $$AcCoinTransactionsTableTableManager(
    _$AppDatabase db,
    $AcCoinTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcCoinTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcCoinTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcCoinTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> relatedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AcCoinTransactionsCompanion(
                id: id,
                userId: userId,
                amount: amount,
                type: type,
                description: description,
                relatedDate: relatedDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                required int amount,
                required String type,
                Value<String> description = const Value.absent(),
                Value<int?> relatedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AcCoinTransactionsCompanion.insert(
                id: id,
                userId: userId,
                amount: amount,
                type: type,
                description: description,
                relatedDate: relatedDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcCoinTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcCoinTransactionsTable,
      AcCoinTransaction,
      $$AcCoinTransactionsTableFilterComposer,
      $$AcCoinTransactionsTableOrderingComposer,
      $$AcCoinTransactionsTableAnnotationComposer,
      $$AcCoinTransactionsTableCreateCompanionBuilder,
      $$AcCoinTransactionsTableUpdateCompanionBuilder,
      (
        AcCoinTransaction,
        BaseReferences<
          _$AppDatabase,
          $AcCoinTransactionsTable,
          AcCoinTransaction
        >,
      ),
      AcCoinTransaction,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountBooksTableTableManager get accountBooks =>
      $$AccountBooksTableTableManager(_db, _db.accountBooks);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$AiTrainingRecordsTableTableManager get aiTrainingRecords =>
      $$AiTrainingRecordsTableTableManager(_db, _db.aiTrainingRecords);
  $$ConversationMessagesTableTableManager get conversationMessages =>
      $$ConversationMessagesTableTableManager(_db, _db.conversationMessages);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$CheckInRecordsTableTableManager get checkInRecords =>
      $$CheckInRecordsTableTableManager(_db, _db.checkInRecords);
  $$AcCoinBalancesTableTableManager get acCoinBalances =>
      $$AcCoinBalancesTableTableManager(_db, _db.acCoinBalances);
  $$AcCoinTransactionsTableTableManager get acCoinTransactions =>
      $$AcCoinTransactionsTableTableManager(_db, _db.acCoinTransactions);
}
