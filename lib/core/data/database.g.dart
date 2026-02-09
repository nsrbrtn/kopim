// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<String> balanceMinor = GeneratedColumn<String>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant<double>(0),
  );
  static const VerificationMeta _openingBalanceMinorMeta =
      const VerificationMeta('openingBalanceMinor');
  @override
  late final GeneratedColumn<String> openingBalanceMinor =
      GeneratedColumn<String>(
        'opening_balance_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('0'),
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyScaleMeta = const VerificationMeta(
    'currencyScale',
  );
  @override
  late final GeneratedColumn<int> currencyScale = GeneratedColumn<int>(
    'currency_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradientIdMeta = const VerificationMeta(
    'gradientId',
  );
  @override
  late final GeneratedColumn<String> gradientId = GeneratedColumn<String>(
    'gradient_id',
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
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconStyleMeta = const VerificationMeta(
    'iconStyle',
  );
  @override
  late final GeneratedColumn<String> iconStyle = GeneratedColumn<String>(
    'icon_style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    balance,
    balanceMinor,
    openingBalance,
    openingBalanceMinor,
    currency,
    currencyScale,
    type,
    color,
    gradientId,
    createdAt,
    updatedAt,
    isDeleted,
    isPrimary,
    isHidden,
    iconName,
    iconStyle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance_minor')) {
      context.handle(
        _openingBalanceMinorMeta,
        openingBalanceMinor.isAcceptableOrUnknown(
          data['opening_balance_minor']!,
          _openingBalanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('currency_scale')) {
      context.handle(
        _currencyScaleMeta,
        currencyScale.isAcceptableOrUnknown(
          data['currency_scale']!,
          _currencyScaleMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('gradient_id')) {
      context.handle(
        _gradientIdMeta,
        gradientId.isAcceptableOrUnknown(data['gradient_id']!, _gradientIdMeta),
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('icon_style')) {
      context.handle(
        _iconStyleMeta,
        iconStyle.isAcceptableOrUnknown(data['icon_style']!, _iconStyleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance_minor'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      openingBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_balance_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      currencyScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_scale'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      gradientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gradient_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      iconStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_style'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String name;
  final double balance;
  final String balanceMinor;
  final double openingBalance;
  final String openingBalanceMinor;
  final String currency;
  final int currencyScale;
  final String type;
  final String? color;
  final String? gradientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isPrimary;
  final bool isHidden;
  final String? iconName;
  final String? iconStyle;
  const AccountRow({
    required this.id,
    required this.name,
    required this.balance,
    required this.balanceMinor,
    required this.openingBalance,
    required this.openingBalanceMinor,
    required this.currency,
    required this.currencyScale,
    required this.type,
    this.color,
    this.gradientId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isPrimary,
    required this.isHidden,
    this.iconName,
    this.iconStyle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['balance'] = Variable<double>(balance);
    map['balance_minor'] = Variable<String>(balanceMinor);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['opening_balance_minor'] = Variable<String>(openingBalanceMinor);
    map['currency'] = Variable<String>(currency);
    map['currency_scale'] = Variable<int>(currencyScale);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || gradientId != null) {
      map['gradient_id'] = Variable<String>(gradientId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || iconStyle != null) {
      map['icon_style'] = Variable<String>(iconStyle);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      balance: Value(balance),
      balanceMinor: Value(balanceMinor),
      openingBalance: Value(openingBalance),
      openingBalanceMinor: Value(openingBalanceMinor),
      currency: Value(currency),
      currencyScale: Value(currencyScale),
      type: Value(type),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      gradientId: gradientId == null && nullToAbsent
          ? const Value.absent()
          : Value(gradientId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isPrimary: Value(isPrimary),
      isHidden: Value(isHidden),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      iconStyle: iconStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(iconStyle),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      balance: serializer.fromJson<double>(json['balance']),
      balanceMinor: serializer.fromJson<String>(json['balanceMinor']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      openingBalanceMinor: serializer.fromJson<String>(
        json['openingBalanceMinor'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      currencyScale: serializer.fromJson<int>(json['currencyScale']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String?>(json['color']),
      gradientId: serializer.fromJson<String?>(json['gradientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      iconStyle: serializer.fromJson<String?>(json['iconStyle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'balance': serializer.toJson<double>(balance),
      'balanceMinor': serializer.toJson<String>(balanceMinor),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'openingBalanceMinor': serializer.toJson<String>(openingBalanceMinor),
      'currency': serializer.toJson<String>(currency),
      'currencyScale': serializer.toJson<int>(currencyScale),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String?>(color),
      'gradientId': serializer.toJson<String?>(gradientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isHidden': serializer.toJson<bool>(isHidden),
      'iconName': serializer.toJson<String?>(iconName),
      'iconStyle': serializer.toJson<String?>(iconStyle),
    };
  }

  AccountRow copyWith({
    String? id,
    String? name,
    double? balance,
    String? balanceMinor,
    double? openingBalance,
    String? openingBalanceMinor,
    String? currency,
    int? currencyScale,
    String? type,
    Value<String?> color = const Value.absent(),
    Value<String?> gradientId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isPrimary,
    bool? isHidden,
    Value<String?> iconName = const Value.absent(),
    Value<String?> iconStyle = const Value.absent(),
  }) => AccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    balance: balance ?? this.balance,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    openingBalance: openingBalance ?? this.openingBalance,
    openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
    currency: currency ?? this.currency,
    currencyScale: currencyScale ?? this.currencyScale,
    type: type ?? this.type,
    color: color.present ? color.value : this.color,
    gradientId: gradientId.present ? gradientId.value : this.gradientId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isPrimary: isPrimary ?? this.isPrimary,
    isHidden: isHidden ?? this.isHidden,
    iconName: iconName.present ? iconName.value : this.iconName,
    iconStyle: iconStyle.present ? iconStyle.value : this.iconStyle,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      balance: data.balance.present ? data.balance.value : this.balance,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      openingBalanceMinor: data.openingBalanceMinor.present
          ? data.openingBalanceMinor.value
          : this.openingBalanceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      currencyScale: data.currencyScale.present
          ? data.currencyScale.value
          : this.currencyScale,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      gradientId: data.gradientId.present
          ? data.gradientId.value
          : this.gradientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      iconStyle: data.iconStyle.present ? data.iconStyle.value : this.iconStyle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('currency: $currency, ')
          ..write('currencyScale: $currencyScale, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('gradientId: $gradientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isHidden: $isHidden, ')
          ..write('iconName: $iconName, ')
          ..write('iconStyle: $iconStyle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    balance,
    balanceMinor,
    openingBalance,
    openingBalanceMinor,
    currency,
    currencyScale,
    type,
    color,
    gradientId,
    createdAt,
    updatedAt,
    isDeleted,
    isPrimary,
    isHidden,
    iconName,
    iconStyle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.balance == this.balance &&
          other.balanceMinor == this.balanceMinor &&
          other.openingBalance == this.openingBalance &&
          other.openingBalanceMinor == this.openingBalanceMinor &&
          other.currency == this.currency &&
          other.currencyScale == this.currencyScale &&
          other.type == this.type &&
          other.color == this.color &&
          other.gradientId == this.gradientId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isPrimary == this.isPrimary &&
          other.isHidden == this.isHidden &&
          other.iconName == this.iconName &&
          other.iconStyle == this.iconStyle);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> balance;
  final Value<String> balanceMinor;
  final Value<double> openingBalance;
  final Value<String> openingBalanceMinor;
  final Value<String> currency;
  final Value<int> currencyScale;
  final Value<String> type;
  final Value<String?> color;
  final Value<String?> gradientId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isPrimary;
  final Value<bool> isHidden;
  final Value<String?> iconName;
  final Value<String?> iconStyle;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.balance = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencyScale = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.gradientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.iconName = const Value.absent(),
    this.iconStyle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required double balance,
    this.balanceMinor = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    required String currency,
    this.currencyScale = const Value.absent(),
    required String type,
    this.color = const Value.absent(),
    this.gradientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.iconName = const Value.absent(),
    this.iconStyle = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       balance = Value(balance),
       currency = Value(currency),
       type = Value(type);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? balance,
    Expression<String>? balanceMinor,
    Expression<double>? openingBalance,
    Expression<String>? openingBalanceMinor,
    Expression<String>? currency,
    Expression<int>? currencyScale,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? gradientId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isPrimary,
    Expression<bool>? isHidden,
    Expression<String>? iconName,
    Expression<String>? iconStyle,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (balance != null) 'balance': balance,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (openingBalanceMinor != null)
        'opening_balance_minor': openingBalanceMinor,
      if (currency != null) 'currency': currency,
      if (currencyScale != null) 'currency_scale': currencyScale,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (gradientId != null) 'gradient_id': gradientId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isHidden != null) 'is_hidden': isHidden,
      if (iconName != null) 'icon_name': iconName,
      if (iconStyle != null) 'icon_style': iconStyle,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? balance,
    Value<String>? balanceMinor,
    Value<double>? openingBalance,
    Value<String>? openingBalanceMinor,
    Value<String>? currency,
    Value<int>? currencyScale,
    Value<String>? type,
    Value<String?>? color,
    Value<String?>? gradientId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isPrimary,
    Value<bool>? isHidden,
    Value<String?>? iconName,
    Value<String?>? iconStyle,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      currency: currency ?? this.currency,
      currencyScale: currencyScale ?? this.currencyScale,
      type: type ?? this.type,
      color: color ?? this.color,
      gradientId: gradientId ?? this.gradientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isPrimary: isPrimary ?? this.isPrimary,
      isHidden: isHidden ?? this.isHidden,
      iconName: iconName ?? this.iconName,
      iconStyle: iconStyle ?? this.iconStyle,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<String>(balanceMinor.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (openingBalanceMinor.present) {
      map['opening_balance_minor'] = Variable<String>(
        openingBalanceMinor.value,
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currencyScale.present) {
      map['currency_scale'] = Variable<int>(currencyScale.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (gradientId.present) {
      map['gradient_id'] = Variable<String>(gradientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (iconStyle.present) {
      map['icon_style'] = Variable<String>(iconStyle.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('currency: $currency, ')
          ..write('currencyScale: $currencyScale, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('gradientId: $gradientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isHidden: $isHidden, ')
          ..write('iconName: $iconName, ')
          ..write('iconStyle: $iconStyle, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
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
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconStyleMeta = const VerificationMeta(
    'iconStyle',
  );
  @override
  late final GeneratedColumn<String> iconStyle = GeneratedColumn<String>(
    'icon_style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES categories(id) ON DELETE SET NULL',
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
    defaultValue: const Constant<bool>(false),
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
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    icon,
    iconStyle,
    iconName,
    color,
    parentId,
    createdAt,
    updatedAt,
    isDeleted,
    isSystem,
    isHidden,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('icon_style')) {
      context.handle(
        _iconStyleMeta,
        iconStyle.isAcceptableOrUnknown(data['icon_style']!, _iconStyleMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      iconStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_style'],
      ),
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? iconStyle;
  final String? iconName;
  final String? color;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSystem;
  final bool isHidden;
  final bool isFavorite;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.iconStyle,
    this.iconName,
    this.color,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSystem,
    required this.isHidden,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || iconStyle != null) {
      map['icon_style'] = Variable<String>(iconStyle);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      iconStyle: iconStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(iconStyle),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSystem: Value(isSystem),
      isHidden: Value(isHidden),
      isFavorite: Value(isFavorite),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String?>(json['icon']),
      iconStyle: serializer.fromJson<String?>(json['iconStyle']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      color: serializer.fromJson<String?>(json['color']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String?>(icon),
      'iconStyle': serializer.toJson<String?>(iconStyle),
      'iconName': serializer.toJson<String?>(iconName),
      'color': serializer.toJson<String?>(color),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isHidden': serializer.toJson<bool>(isHidden),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> icon = const Value.absent(),
    Value<String?> iconStyle = const Value.absent(),
    Value<String?> iconName = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSystem,
    bool? isHidden,
    bool? isFavorite,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon.present ? icon.value : this.icon,
    iconStyle: iconStyle.present ? iconStyle.value : this.iconStyle,
    iconName: iconName.present ? iconName.value : this.iconName,
    color: color.present ? color.value : this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSystem: isSystem ?? this.isSystem,
    isHidden: isHidden ?? this.isHidden,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      iconStyle: data.iconStyle.present ? data.iconStyle.value : this.iconStyle,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('iconStyle: $iconStyle, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    icon,
    iconStyle,
    iconName,
    color,
    parentId,
    createdAt,
    updatedAt,
    isDeleted,
    isSystem,
    isHidden,
    isFavorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.iconStyle == this.iconStyle &&
          other.iconName == this.iconName &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSystem == this.isSystem &&
          other.isHidden == this.isHidden &&
          other.isFavorite == this.isFavorite);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> icon;
  final Value<String?> iconStyle;
  final Value<String?> iconName;
  final Value<String?> color;
  final Value<String?> parentId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSystem;
  final Value<bool> isHidden;
  final Value<bool> isFavorite;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.iconStyle = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.iconStyle = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? iconStyle,
    Expression<String>? iconName,
    Expression<String>? color,
    Expression<String>? parentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSystem,
    Expression<bool>? isHidden,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (iconStyle != null) 'icon_style': iconStyle,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSystem != null) 'is_system': isSystem,
      if (isHidden != null) 'is_hidden': isHidden,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? icon,
    Value<String?>? iconStyle,
    Value<String?>? iconName,
    Value<String?>? color,
    Value<String?>? parentId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSystem,
    Value<bool>? isHidden,
    Value<bool>? isFavorite,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconStyle: iconStyle ?? this.iconStyle,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSystem: isSystem ?? this.isSystem,
      isHidden: isHidden ?? this.isHidden,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (iconStyle.present) {
      map['icon_style'] = Variable<String>(iconStyle.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('iconStyle: $iconStyle, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
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
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const TagRow({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String color,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingGoalsTable extends SavingGoals
    with TableInfo<$SavingGoalsTable, SavingGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<int> currentAmount = GeneratedColumn<int>(
    'current_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    targetAmount,
    currentAmount,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingGoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $SavingGoalsTable createAlias(String alias) {
    return $SavingGoalsTable(attachedDatabase, alias);
  }
}

class SavingGoalRow extends DataClass implements Insertable<SavingGoalRow> {
  final String id;
  final String userId;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const SavingGoalRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<int>(targetAmount);
    map['current_amount'] = Variable<int>(currentAmount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  SavingGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingGoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory SavingGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingGoalRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currentAmount: serializer.fromJson<int>(json['currentAmount']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currentAmount': serializer.toJson<int>(currentAmount),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  SavingGoalRow copyWith({
    String? id,
    String? userId,
    String? name,
    int? targetAmount,
    int? currentAmount,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => SavingGoalRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  SavingGoalRow copyWithCompanion(SavingGoalsCompanion data) {
    return SavingGoalRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    targetAmount,
    currentAmount,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingGoalRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class SavingGoalsCompanion extends UpdateCompanion<SavingGoalRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> targetAmount;
  final Value<int> currentAmount;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const SavingGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingGoalsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required int targetAmount,
    this.currentAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       targetAmount = Value(targetAmount);
  static Insertable<SavingGoalRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? targetAmount,
    Expression<int>? currentAmount,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<int>? targetAmount,
    Value<int>? currentAmount,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return SavingGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<int>(currentAmount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditsTable extends Credits with TableInfo<$CreditsTable, CreditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMinorMeta = const VerificationMeta(
    'totalAmountMinor',
  );
  @override
  late final GeneratedColumn<String> totalAmountMinor = GeneratedColumn<String>(
    'total_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _totalAmountScaleMeta = const VerificationMeta(
    'totalAmountScale',
  );
  @override
  late final GeneratedColumn<int> totalAmountScale = GeneratedColumn<int>(
    'total_amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMonthsMeta = const VerificationMeta(
    'termMonths',
  );
  @override
  late final GeneratedColumn<int> termMonths = GeneratedColumn<int>(
    'term_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDayMeta = const VerificationMeta(
    'paymentDay',
  );
  @override
  late final GeneratedColumn<int> paymentDay = GeneratedColumn<int>(
    'payment_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
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
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueAmountMeta = const VerificationMeta(
    'issueAmount',
  );
  @override
  late final GeneratedColumn<double> issueAmount = GeneratedColumn<double>(
    'issue_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueAmountMinorMeta = const VerificationMeta(
    'issueAmountMinor',
  );
  @override
  late final GeneratedColumn<String> issueAmountMinor = GeneratedColumn<String>(
    'issue_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _issueAmountScaleMeta = const VerificationMeta(
    'issueAmountScale',
  );
  @override
  late final GeneratedColumn<int> issueAmountScale = GeneratedColumn<int>(
    'issue_amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _targetAccountIdMeta = const VerificationMeta(
    'targetAccountId',
  );
  @override
  late final GeneratedColumn<String> targetAccountId = GeneratedColumn<String>(
    'target_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _interestCategoryIdMeta =
      const VerificationMeta('interestCategoryId');
  @override
  late final GeneratedColumn<String> interestCategoryId =
      GeneratedColumn<String>(
        'interest_category_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _feesCategoryIdMeta = const VerificationMeta(
    'feesCategoryId',
  );
  @override
  late final GeneratedColumn<String> feesCategoryId = GeneratedColumn<String>(
    'fees_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _firstPaymentDateMeta = const VerificationMeta(
    'firstPaymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstPaymentDate =
      GeneratedColumn<DateTime>(
        'first_payment_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    totalAmount,
    totalAmountMinor,
    totalAmountScale,
    interestRate,
    termMonths,
    startDate,
    paymentDay,
    createdAt,
    updatedAt,
    isDeleted,
    issueDate,
    issueAmount,
    issueAmountMinor,
    issueAmountScale,
    targetAccountId,
    interestCategoryId,
    feesCategoryId,
    firstPaymentDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('total_amount_minor')) {
      context.handle(
        _totalAmountMinorMeta,
        totalAmountMinor.isAcceptableOrUnknown(
          data['total_amount_minor']!,
          _totalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_scale')) {
      context.handle(
        _totalAmountScaleMeta,
        totalAmountScale.isAcceptableOrUnknown(
          data['total_amount_scale']!,
          _totalAmountScaleMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestRateMeta);
    }
    if (data.containsKey('term_months')) {
      context.handle(
        _termMonthsMeta,
        termMonths.isAcceptableOrUnknown(data['term_months']!, _termMonthsMeta),
      );
    } else if (isInserting) {
      context.missing(_termMonthsMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('payment_day')) {
      context.handle(
        _paymentDayMeta,
        paymentDay.isAcceptableOrUnknown(data['payment_day']!, _paymentDayMeta),
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    }
    if (data.containsKey('issue_amount')) {
      context.handle(
        _issueAmountMeta,
        issueAmount.isAcceptableOrUnknown(
          data['issue_amount']!,
          _issueAmountMeta,
        ),
      );
    }
    if (data.containsKey('issue_amount_minor')) {
      context.handle(
        _issueAmountMinorMeta,
        issueAmountMinor.isAcceptableOrUnknown(
          data['issue_amount_minor']!,
          _issueAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('issue_amount_scale')) {
      context.handle(
        _issueAmountScaleMeta,
        issueAmountScale.isAcceptableOrUnknown(
          data['issue_amount_scale']!,
          _issueAmountScaleMeta,
        ),
      );
    }
    if (data.containsKey('target_account_id')) {
      context.handle(
        _targetAccountIdMeta,
        targetAccountId.isAcceptableOrUnknown(
          data['target_account_id']!,
          _targetAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('interest_category_id')) {
      context.handle(
        _interestCategoryIdMeta,
        interestCategoryId.isAcceptableOrUnknown(
          data['interest_category_id']!,
          _interestCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('fees_category_id')) {
      context.handle(
        _feesCategoryIdMeta,
        feesCategoryId.isAcceptableOrUnknown(
          data['fees_category_id']!,
          _feesCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('first_payment_date')) {
      context.handle(
        _firstPaymentDateMeta,
        firstPaymentDate.isAcceptableOrUnknown(
          data['first_payment_date']!,
          _firstPaymentDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      totalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_amount_minor'],
      )!,
      totalAmountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_scale'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      )!,
      termMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_months'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      paymentDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      ),
      issueAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}issue_amount'],
      ),
      issueAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_amount_minor'],
      )!,
      issueAmountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_amount_scale'],
      )!,
      targetAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_account_id'],
      ),
      interestCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_category_id'],
      ),
      feesCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fees_category_id'],
      ),
      firstPaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_payment_date'],
      ),
    );
  }

  @override
  $CreditsTable createAlias(String alias) {
    return $CreditsTable(attachedDatabase, alias);
  }
}

class CreditRow extends DataClass implements Insertable<CreditRow> {
  final String id;
  final String accountId;
  final String? categoryId;
  final double totalAmount;
  final String totalAmountMinor;
  final int totalAmountScale;
  final double interestRate;
  final int termMonths;
  final DateTime startDate;
  final int paymentDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? issueDate;
  final double? issueAmount;
  final String issueAmountMinor;
  final int issueAmountScale;
  final String? targetAccountId;
  final String? interestCategoryId;
  final String? feesCategoryId;
  final DateTime? firstPaymentDate;
  const CreditRow({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.totalAmount,
    required this.totalAmountMinor,
    required this.totalAmountScale,
    required this.interestRate,
    required this.termMonths,
    required this.startDate,
    required this.paymentDay,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.issueDate,
    this.issueAmount,
    required this.issueAmountMinor,
    required this.issueAmountScale,
    this.targetAccountId,
    this.interestCategoryId,
    this.feesCategoryId,
    this.firstPaymentDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['total_amount_minor'] = Variable<String>(totalAmountMinor);
    map['total_amount_scale'] = Variable<int>(totalAmountScale);
    map['interest_rate'] = Variable<double>(interestRate);
    map['term_months'] = Variable<int>(termMonths);
    map['start_date'] = Variable<DateTime>(startDate);
    map['payment_day'] = Variable<int>(paymentDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || issueDate != null) {
      map['issue_date'] = Variable<DateTime>(issueDate);
    }
    if (!nullToAbsent || issueAmount != null) {
      map['issue_amount'] = Variable<double>(issueAmount);
    }
    map['issue_amount_minor'] = Variable<String>(issueAmountMinor);
    map['issue_amount_scale'] = Variable<int>(issueAmountScale);
    if (!nullToAbsent || targetAccountId != null) {
      map['target_account_id'] = Variable<String>(targetAccountId);
    }
    if (!nullToAbsent || interestCategoryId != null) {
      map['interest_category_id'] = Variable<String>(interestCategoryId);
    }
    if (!nullToAbsent || feesCategoryId != null) {
      map['fees_category_id'] = Variable<String>(feesCategoryId);
    }
    if (!nullToAbsent || firstPaymentDate != null) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate);
    }
    return map;
  }

  CreditsCompanion toCompanion(bool nullToAbsent) {
    return CreditsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      totalAmount: Value(totalAmount),
      totalAmountMinor: Value(totalAmountMinor),
      totalAmountScale: Value(totalAmountScale),
      interestRate: Value(interestRate),
      termMonths: Value(termMonths),
      startDate: Value(startDate),
      paymentDay: Value(paymentDay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      issueDate: issueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(issueDate),
      issueAmount: issueAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(issueAmount),
      issueAmountMinor: Value(issueAmountMinor),
      issueAmountScale: Value(issueAmountScale),
      targetAccountId: targetAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAccountId),
      interestCategoryId: interestCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(interestCategoryId),
      feesCategoryId: feesCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(feesCategoryId),
      firstPaymentDate: firstPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPaymentDate),
    );
  }

  factory CreditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      totalAmountMinor: serializer.fromJson<String>(json['totalAmountMinor']),
      totalAmountScale: serializer.fromJson<int>(json['totalAmountScale']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      termMonths: serializer.fromJson<int>(json['termMonths']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      paymentDay: serializer.fromJson<int>(json['paymentDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      issueDate: serializer.fromJson<DateTime?>(json['issueDate']),
      issueAmount: serializer.fromJson<double?>(json['issueAmount']),
      issueAmountMinor: serializer.fromJson<String>(json['issueAmountMinor']),
      issueAmountScale: serializer.fromJson<int>(json['issueAmountScale']),
      targetAccountId: serializer.fromJson<String?>(json['targetAccountId']),
      interestCategoryId: serializer.fromJson<String?>(
        json['interestCategoryId'],
      ),
      feesCategoryId: serializer.fromJson<String?>(json['feesCategoryId']),
      firstPaymentDate: serializer.fromJson<DateTime?>(
        json['firstPaymentDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'totalAmountMinor': serializer.toJson<String>(totalAmountMinor),
      'totalAmountScale': serializer.toJson<int>(totalAmountScale),
      'interestRate': serializer.toJson<double>(interestRate),
      'termMonths': serializer.toJson<int>(termMonths),
      'startDate': serializer.toJson<DateTime>(startDate),
      'paymentDay': serializer.toJson<int>(paymentDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'issueDate': serializer.toJson<DateTime?>(issueDate),
      'issueAmount': serializer.toJson<double?>(issueAmount),
      'issueAmountMinor': serializer.toJson<String>(issueAmountMinor),
      'issueAmountScale': serializer.toJson<int>(issueAmountScale),
      'targetAccountId': serializer.toJson<String?>(targetAccountId),
      'interestCategoryId': serializer.toJson<String?>(interestCategoryId),
      'feesCategoryId': serializer.toJson<String?>(feesCategoryId),
      'firstPaymentDate': serializer.toJson<DateTime?>(firstPaymentDate),
    };
  }

  CreditRow copyWith({
    String? id,
    String? accountId,
    Value<String?> categoryId = const Value.absent(),
    double? totalAmount,
    String? totalAmountMinor,
    int? totalAmountScale,
    double? interestRate,
    int? termMonths,
    DateTime? startDate,
    int? paymentDay,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    Value<DateTime?> issueDate = const Value.absent(),
    Value<double?> issueAmount = const Value.absent(),
    String? issueAmountMinor,
    int? issueAmountScale,
    Value<String?> targetAccountId = const Value.absent(),
    Value<String?> interestCategoryId = const Value.absent(),
    Value<String?> feesCategoryId = const Value.absent(),
    Value<DateTime?> firstPaymentDate = const Value.absent(),
  }) => CreditRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    totalAmount: totalAmount ?? this.totalAmount,
    totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
    totalAmountScale: totalAmountScale ?? this.totalAmountScale,
    interestRate: interestRate ?? this.interestRate,
    termMonths: termMonths ?? this.termMonths,
    startDate: startDate ?? this.startDate,
    paymentDay: paymentDay ?? this.paymentDay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    issueDate: issueDate.present ? issueDate.value : this.issueDate,
    issueAmount: issueAmount.present ? issueAmount.value : this.issueAmount,
    issueAmountMinor: issueAmountMinor ?? this.issueAmountMinor,
    issueAmountScale: issueAmountScale ?? this.issueAmountScale,
    targetAccountId: targetAccountId.present
        ? targetAccountId.value
        : this.targetAccountId,
    interestCategoryId: interestCategoryId.present
        ? interestCategoryId.value
        : this.interestCategoryId,
    feesCategoryId: feesCategoryId.present
        ? feesCategoryId.value
        : this.feesCategoryId,
    firstPaymentDate: firstPaymentDate.present
        ? firstPaymentDate.value
        : this.firstPaymentDate,
  );
  CreditRow copyWithCompanion(CreditsCompanion data) {
    return CreditRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      totalAmountMinor: data.totalAmountMinor.present
          ? data.totalAmountMinor.value
          : this.totalAmountMinor,
      totalAmountScale: data.totalAmountScale.present
          ? data.totalAmountScale.value
          : this.totalAmountScale,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      termMonths: data.termMonths.present
          ? data.termMonths.value
          : this.termMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      paymentDay: data.paymentDay.present
          ? data.paymentDay.value
          : this.paymentDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      issueAmount: data.issueAmount.present
          ? data.issueAmount.value
          : this.issueAmount,
      issueAmountMinor: data.issueAmountMinor.present
          ? data.issueAmountMinor.value
          : this.issueAmountMinor,
      issueAmountScale: data.issueAmountScale.present
          ? data.issueAmountScale.value
          : this.issueAmountScale,
      targetAccountId: data.targetAccountId.present
          ? data.targetAccountId.value
          : this.targetAccountId,
      interestCategoryId: data.interestCategoryId.present
          ? data.interestCategoryId.value
          : this.interestCategoryId,
      feesCategoryId: data.feesCategoryId.present
          ? data.feesCategoryId.value
          : this.feesCategoryId,
      firstPaymentDate: data.firstPaymentDate.present
          ? data.firstPaymentDate.value
          : this.firstPaymentDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('totalAmountScale: $totalAmountScale, ')
          ..write('interestRate: $interestRate, ')
          ..write('termMonths: $termMonths, ')
          ..write('startDate: $startDate, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('issueDate: $issueDate, ')
          ..write('issueAmount: $issueAmount, ')
          ..write('issueAmountMinor: $issueAmountMinor, ')
          ..write('issueAmountScale: $issueAmountScale, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('interestCategoryId: $interestCategoryId, ')
          ..write('feesCategoryId: $feesCategoryId, ')
          ..write('firstPaymentDate: $firstPaymentDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    accountId,
    categoryId,
    totalAmount,
    totalAmountMinor,
    totalAmountScale,
    interestRate,
    termMonths,
    startDate,
    paymentDay,
    createdAt,
    updatedAt,
    isDeleted,
    issueDate,
    issueAmount,
    issueAmountMinor,
    issueAmountScale,
    targetAccountId,
    interestCategoryId,
    feesCategoryId,
    firstPaymentDate,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.totalAmount == this.totalAmount &&
          other.totalAmountMinor == this.totalAmountMinor &&
          other.totalAmountScale == this.totalAmountScale &&
          other.interestRate == this.interestRate &&
          other.termMonths == this.termMonths &&
          other.startDate == this.startDate &&
          other.paymentDay == this.paymentDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.issueDate == this.issueDate &&
          other.issueAmount == this.issueAmount &&
          other.issueAmountMinor == this.issueAmountMinor &&
          other.issueAmountScale == this.issueAmountScale &&
          other.targetAccountId == this.targetAccountId &&
          other.interestCategoryId == this.interestCategoryId &&
          other.feesCategoryId == this.feesCategoryId &&
          other.firstPaymentDate == this.firstPaymentDate);
}

class CreditsCompanion extends UpdateCompanion<CreditRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> categoryId;
  final Value<double> totalAmount;
  final Value<String> totalAmountMinor;
  final Value<int> totalAmountScale;
  final Value<double> interestRate;
  final Value<int> termMonths;
  final Value<DateTime> startDate;
  final Value<int> paymentDay;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> issueDate;
  final Value<double?> issueAmount;
  final Value<String> issueAmountMinor;
  final Value<int> issueAmountScale;
  final Value<String?> targetAccountId;
  final Value<String?> interestCategoryId;
  final Value<String?> feesCategoryId;
  final Value<DateTime?> firstPaymentDate;
  final Value<int> rowid;
  const CreditsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.totalAmountMinor = const Value.absent(),
    this.totalAmountScale = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.termMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.issueAmount = const Value.absent(),
    this.issueAmountMinor = const Value.absent(),
    this.issueAmountScale = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.interestCategoryId = const Value.absent(),
    this.feesCategoryId = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditsCompanion.insert({
    required String id,
    required String accountId,
    this.categoryId = const Value.absent(),
    required double totalAmount,
    this.totalAmountMinor = const Value.absent(),
    this.totalAmountScale = const Value.absent(),
    required double interestRate,
    required int termMonths,
    required DateTime startDate,
    this.paymentDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.issueAmount = const Value.absent(),
    this.issueAmountMinor = const Value.absent(),
    this.issueAmountScale = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.interestCategoryId = const Value.absent(),
    this.feesCategoryId = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       totalAmount = Value(totalAmount),
       interestRate = Value(interestRate),
       termMonths = Value(termMonths),
       startDate = Value(startDate);
  static Insertable<CreditRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<double>? totalAmount,
    Expression<String>? totalAmountMinor,
    Expression<int>? totalAmountScale,
    Expression<double>? interestRate,
    Expression<int>? termMonths,
    Expression<DateTime>? startDate,
    Expression<int>? paymentDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? issueDate,
    Expression<double>? issueAmount,
    Expression<String>? issueAmountMinor,
    Expression<int>? issueAmountScale,
    Expression<String>? targetAccountId,
    Expression<String>? interestCategoryId,
    Expression<String>? feesCategoryId,
    Expression<DateTime>? firstPaymentDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (totalAmountMinor != null) 'total_amount_minor': totalAmountMinor,
      if (totalAmountScale != null) 'total_amount_scale': totalAmountScale,
      if (interestRate != null) 'interest_rate': interestRate,
      if (termMonths != null) 'term_months': termMonths,
      if (startDate != null) 'start_date': startDate,
      if (paymentDay != null) 'payment_day': paymentDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (issueDate != null) 'issue_date': issueDate,
      if (issueAmount != null) 'issue_amount': issueAmount,
      if (issueAmountMinor != null) 'issue_amount_minor': issueAmountMinor,
      if (issueAmountScale != null) 'issue_amount_scale': issueAmountScale,
      if (targetAccountId != null) 'target_account_id': targetAccountId,
      if (interestCategoryId != null)
        'interest_category_id': interestCategoryId,
      if (feesCategoryId != null) 'fees_category_id': feesCategoryId,
      if (firstPaymentDate != null) 'first_payment_date': firstPaymentDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String?>? categoryId,
    Value<double>? totalAmount,
    Value<String>? totalAmountMinor,
    Value<int>? totalAmountScale,
    Value<double>? interestRate,
    Value<int>? termMonths,
    Value<DateTime>? startDate,
    Value<int>? paymentDay,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<DateTime?>? issueDate,
    Value<double?>? issueAmount,
    Value<String>? issueAmountMinor,
    Value<int>? issueAmountScale,
    Value<String?>? targetAccountId,
    Value<String?>? interestCategoryId,
    Value<String?>? feesCategoryId,
    Value<DateTime?>? firstPaymentDate,
    Value<int>? rowid,
  }) {
    return CreditsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      totalAmountScale: totalAmountScale ?? this.totalAmountScale,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      startDate: startDate ?? this.startDate,
      paymentDay: paymentDay ?? this.paymentDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      issueDate: issueDate ?? this.issueDate,
      issueAmount: issueAmount ?? this.issueAmount,
      issueAmountMinor: issueAmountMinor ?? this.issueAmountMinor,
      issueAmountScale: issueAmountScale ?? this.issueAmountScale,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      interestCategoryId: interestCategoryId ?? this.interestCategoryId,
      feesCategoryId: feesCategoryId ?? this.feesCategoryId,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (totalAmountMinor.present) {
      map['total_amount_minor'] = Variable<String>(totalAmountMinor.value);
    }
    if (totalAmountScale.present) {
      map['total_amount_scale'] = Variable<int>(totalAmountScale.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (termMonths.present) {
      map['term_months'] = Variable<int>(termMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (paymentDay.present) {
      map['payment_day'] = Variable<int>(paymentDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (issueAmount.present) {
      map['issue_amount'] = Variable<double>(issueAmount.value);
    }
    if (issueAmountMinor.present) {
      map['issue_amount_minor'] = Variable<String>(issueAmountMinor.value);
    }
    if (issueAmountScale.present) {
      map['issue_amount_scale'] = Variable<int>(issueAmountScale.value);
    }
    if (targetAccountId.present) {
      map['target_account_id'] = Variable<String>(targetAccountId.value);
    }
    if (interestCategoryId.present) {
      map['interest_category_id'] = Variable<String>(interestCategoryId.value);
    }
    if (feesCategoryId.present) {
      map['fees_category_id'] = Variable<String>(feesCategoryId.value);
    }
    if (firstPaymentDate.present) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('totalAmountScale: $totalAmountScale, ')
          ..write('interestRate: $interestRate, ')
          ..write('termMonths: $termMonths, ')
          ..write('startDate: $startDate, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('issueDate: $issueDate, ')
          ..write('issueAmount: $issueAmount, ')
          ..write('issueAmountMinor: $issueAmountMinor, ')
          ..write('issueAmountScale: $issueAmountScale, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('interestCategoryId: $interestCategoryId, ')
          ..write('feesCategoryId: $feesCategoryId, ')
          ..write('firstPaymentDate: $firstPaymentDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditPaymentSchedulesTable extends CreditPaymentSchedules
    with TableInfo<$CreditPaymentSchedulesTable, CreditPaymentScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditPaymentSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditIdMeta = const VerificationMeta(
    'creditId',
  );
  @override
  late final GeneratedColumn<String> creditId = GeneratedColumn<String>(
    'credit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalAmountMinorMeta =
      const VerificationMeta('principalAmountMinor');
  @override
  late final GeneratedColumn<String> principalAmountMinor =
      GeneratedColumn<String>(
        'principal_amount_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _interestAmountMinorMeta =
      const VerificationMeta('interestAmountMinor');
  @override
  late final GeneratedColumn<String> interestAmountMinor =
      GeneratedColumn<String>(
        'interest_amount_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalAmountMinorMeta = const VerificationMeta(
    'totalAmountMinor',
  );
  @override
  late final GeneratedColumn<String> totalAmountMinor = GeneratedColumn<String>(
    'total_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _principalPaidMinorMeta =
      const VerificationMeta('principalPaidMinor');
  @override
  late final GeneratedColumn<String> principalPaidMinor =
      GeneratedColumn<String>(
        'principal_paid_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('0'),
      );
  static const VerificationMeta _interestPaidMinorMeta = const VerificationMeta(
    'interestPaidMinor',
  );
  @override
  late final GeneratedColumn<String> interestPaidMinor =
      GeneratedColumn<String>(
        'interest_paid_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('0'),
      );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    creditId,
    periodKey,
    dueDate,
    status,
    principalAmountMinor,
    interestAmountMinor,
    totalAmountMinor,
    amountScale,
    principalPaidMinor,
    interestPaidMinor,
    paidAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_payment_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditPaymentScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('credit_id')) {
      context.handle(
        _creditIdMeta,
        creditId.isAcceptableOrUnknown(data['credit_id']!, _creditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creditIdMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('principal_amount_minor')) {
      context.handle(
        _principalAmountMinorMeta,
        principalAmountMinor.isAcceptableOrUnknown(
          data['principal_amount_minor']!,
          _principalAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalAmountMinorMeta);
    }
    if (data.containsKey('interest_amount_minor')) {
      context.handle(
        _interestAmountMinorMeta,
        interestAmountMinor.isAcceptableOrUnknown(
          data['interest_amount_minor']!,
          _interestAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestAmountMinorMeta);
    }
    if (data.containsKey('total_amount_minor')) {
      context.handle(
        _totalAmountMinorMeta,
        totalAmountMinor.isAcceptableOrUnknown(
          data['total_amount_minor']!,
          _totalAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMinorMeta);
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('principal_paid_minor')) {
      context.handle(
        _principalPaidMinorMeta,
        principalPaidMinor.isAcceptableOrUnknown(
          data['principal_paid_minor']!,
          _principalPaidMinorMeta,
        ),
      );
    }
    if (data.containsKey('interest_paid_minor')) {
      context.handle(
        _interestPaidMinorMeta,
        interestPaidMinor.isAcceptableOrUnknown(
          data['interest_paid_minor']!,
          _interestPaidMinorMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
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
  CreditPaymentScheduleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditPaymentScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      creditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_id'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      principalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}principal_amount_minor'],
      )!,
      interestAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_amount_minor'],
      )!,
      totalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      principalPaidMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}principal_paid_minor'],
      )!,
      interestPaidMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_paid_minor'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
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
  $CreditPaymentSchedulesTable createAlias(String alias) {
    return $CreditPaymentSchedulesTable(attachedDatabase, alias);
  }
}

class CreditPaymentScheduleRow extends DataClass
    implements Insertable<CreditPaymentScheduleRow> {
  final String id;
  final String creditId;
  final String periodKey;
  final DateTime dueDate;
  final String status;
  final String principalAmountMinor;
  final String interestAmountMinor;
  final String totalAmountMinor;
  final int amountScale;
  final String principalPaidMinor;
  final String interestPaidMinor;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CreditPaymentScheduleRow({
    required this.id,
    required this.creditId,
    required this.periodKey,
    required this.dueDate,
    required this.status,
    required this.principalAmountMinor,
    required this.interestAmountMinor,
    required this.totalAmountMinor,
    required this.amountScale,
    required this.principalPaidMinor,
    required this.interestPaidMinor,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['credit_id'] = Variable<String>(creditId);
    map['period_key'] = Variable<String>(periodKey);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['principal_amount_minor'] = Variable<String>(principalAmountMinor);
    map['interest_amount_minor'] = Variable<String>(interestAmountMinor);
    map['total_amount_minor'] = Variable<String>(totalAmountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['principal_paid_minor'] = Variable<String>(principalPaidMinor);
    map['interest_paid_minor'] = Variable<String>(interestPaidMinor);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CreditPaymentSchedulesCompanion toCompanion(bool nullToAbsent) {
    return CreditPaymentSchedulesCompanion(
      id: Value(id),
      creditId: Value(creditId),
      periodKey: Value(periodKey),
      dueDate: Value(dueDate),
      status: Value(status),
      principalAmountMinor: Value(principalAmountMinor),
      interestAmountMinor: Value(interestAmountMinor),
      totalAmountMinor: Value(totalAmountMinor),
      amountScale: Value(amountScale),
      principalPaidMinor: Value(principalPaidMinor),
      interestPaidMinor: Value(interestPaidMinor),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CreditPaymentScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditPaymentScheduleRow(
      id: serializer.fromJson<String>(json['id']),
      creditId: serializer.fromJson<String>(json['creditId']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      principalAmountMinor: serializer.fromJson<String>(
        json['principalAmountMinor'],
      ),
      interestAmountMinor: serializer.fromJson<String>(
        json['interestAmountMinor'],
      ),
      totalAmountMinor: serializer.fromJson<String>(json['totalAmountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      principalPaidMinor: serializer.fromJson<String>(
        json['principalPaidMinor'],
      ),
      interestPaidMinor: serializer.fromJson<String>(json['interestPaidMinor']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'creditId': serializer.toJson<String>(creditId),
      'periodKey': serializer.toJson<String>(periodKey),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'principalAmountMinor': serializer.toJson<String>(principalAmountMinor),
      'interestAmountMinor': serializer.toJson<String>(interestAmountMinor),
      'totalAmountMinor': serializer.toJson<String>(totalAmountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'principalPaidMinor': serializer.toJson<String>(principalPaidMinor),
      'interestPaidMinor': serializer.toJson<String>(interestPaidMinor),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CreditPaymentScheduleRow copyWith({
    String? id,
    String? creditId,
    String? periodKey,
    DateTime? dueDate,
    String? status,
    String? principalAmountMinor,
    String? interestAmountMinor,
    String? totalAmountMinor,
    int? amountScale,
    String? principalPaidMinor,
    String? interestPaidMinor,
    Value<DateTime?> paidAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CreditPaymentScheduleRow(
    id: id ?? this.id,
    creditId: creditId ?? this.creditId,
    periodKey: periodKey ?? this.periodKey,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    principalAmountMinor: principalAmountMinor ?? this.principalAmountMinor,
    interestAmountMinor: interestAmountMinor ?? this.interestAmountMinor,
    totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
    amountScale: amountScale ?? this.amountScale,
    principalPaidMinor: principalPaidMinor ?? this.principalPaidMinor,
    interestPaidMinor: interestPaidMinor ?? this.interestPaidMinor,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CreditPaymentScheduleRow copyWithCompanion(
    CreditPaymentSchedulesCompanion data,
  ) {
    return CreditPaymentScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      creditId: data.creditId.present ? data.creditId.value : this.creditId,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      principalAmountMinor: data.principalAmountMinor.present
          ? data.principalAmountMinor.value
          : this.principalAmountMinor,
      interestAmountMinor: data.interestAmountMinor.present
          ? data.interestAmountMinor.value
          : this.interestAmountMinor,
      totalAmountMinor: data.totalAmountMinor.present
          ? data.totalAmountMinor.value
          : this.totalAmountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      principalPaidMinor: data.principalPaidMinor.present
          ? data.principalPaidMinor.value
          : this.principalPaidMinor,
      interestPaidMinor: data.interestPaidMinor.present
          ? data.interestPaidMinor.value
          : this.interestPaidMinor,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditPaymentScheduleRow(')
          ..write('id: $id, ')
          ..write('creditId: $creditId, ')
          ..write('periodKey: $periodKey, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('principalAmountMinor: $principalAmountMinor, ')
          ..write('interestAmountMinor: $interestAmountMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('principalPaidMinor: $principalPaidMinor, ')
          ..write('interestPaidMinor: $interestPaidMinor, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditId,
    periodKey,
    dueDate,
    status,
    principalAmountMinor,
    interestAmountMinor,
    totalAmountMinor,
    amountScale,
    principalPaidMinor,
    interestPaidMinor,
    paidAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditPaymentScheduleRow &&
          other.id == this.id &&
          other.creditId == this.creditId &&
          other.periodKey == this.periodKey &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.principalAmountMinor == this.principalAmountMinor &&
          other.interestAmountMinor == this.interestAmountMinor &&
          other.totalAmountMinor == this.totalAmountMinor &&
          other.amountScale == this.amountScale &&
          other.principalPaidMinor == this.principalPaidMinor &&
          other.interestPaidMinor == this.interestPaidMinor &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CreditPaymentSchedulesCompanion
    extends UpdateCompanion<CreditPaymentScheduleRow> {
  final Value<String> id;
  final Value<String> creditId;
  final Value<String> periodKey;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<String> principalAmountMinor;
  final Value<String> interestAmountMinor;
  final Value<String> totalAmountMinor;
  final Value<int> amountScale;
  final Value<String> principalPaidMinor;
  final Value<String> interestPaidMinor;
  final Value<DateTime?> paidAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CreditPaymentSchedulesCompanion({
    this.id = const Value.absent(),
    this.creditId = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.principalAmountMinor = const Value.absent(),
    this.interestAmountMinor = const Value.absent(),
    this.totalAmountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.principalPaidMinor = const Value.absent(),
    this.interestPaidMinor = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditPaymentSchedulesCompanion.insert({
    required String id,
    required String creditId,
    required String periodKey,
    required DateTime dueDate,
    required String status,
    required String principalAmountMinor,
    required String interestAmountMinor,
    required String totalAmountMinor,
    this.amountScale = const Value.absent(),
    this.principalPaidMinor = const Value.absent(),
    this.interestPaidMinor = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creditId = Value(creditId),
       periodKey = Value(periodKey),
       dueDate = Value(dueDate),
       status = Value(status),
       principalAmountMinor = Value(principalAmountMinor),
       interestAmountMinor = Value(interestAmountMinor),
       totalAmountMinor = Value(totalAmountMinor);
  static Insertable<CreditPaymentScheduleRow> custom({
    Expression<String>? id,
    Expression<String>? creditId,
    Expression<String>? periodKey,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? principalAmountMinor,
    Expression<String>? interestAmountMinor,
    Expression<String>? totalAmountMinor,
    Expression<int>? amountScale,
    Expression<String>? principalPaidMinor,
    Expression<String>? interestPaidMinor,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditId != null) 'credit_id': creditId,
      if (periodKey != null) 'period_key': periodKey,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (principalAmountMinor != null)
        'principal_amount_minor': principalAmountMinor,
      if (interestAmountMinor != null)
        'interest_amount_minor': interestAmountMinor,
      if (totalAmountMinor != null) 'total_amount_minor': totalAmountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (principalPaidMinor != null)
        'principal_paid_minor': principalPaidMinor,
      if (interestPaidMinor != null) 'interest_paid_minor': interestPaidMinor,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditPaymentSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? creditId,
    Value<String>? periodKey,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<String>? principalAmountMinor,
    Value<String>? interestAmountMinor,
    Value<String>? totalAmountMinor,
    Value<int>? amountScale,
    Value<String>? principalPaidMinor,
    Value<String>? interestPaidMinor,
    Value<DateTime?>? paidAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CreditPaymentSchedulesCompanion(
      id: id ?? this.id,
      creditId: creditId ?? this.creditId,
      periodKey: periodKey ?? this.periodKey,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      principalAmountMinor: principalAmountMinor ?? this.principalAmountMinor,
      interestAmountMinor: interestAmountMinor ?? this.interestAmountMinor,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      amountScale: amountScale ?? this.amountScale,
      principalPaidMinor: principalPaidMinor ?? this.principalPaidMinor,
      interestPaidMinor: interestPaidMinor ?? this.interestPaidMinor,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (creditId.present) {
      map['credit_id'] = Variable<String>(creditId.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (principalAmountMinor.present) {
      map['principal_amount_minor'] = Variable<String>(
        principalAmountMinor.value,
      );
    }
    if (interestAmountMinor.present) {
      map['interest_amount_minor'] = Variable<String>(
        interestAmountMinor.value,
      );
    }
    if (totalAmountMinor.present) {
      map['total_amount_minor'] = Variable<String>(totalAmountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (principalPaidMinor.present) {
      map['principal_paid_minor'] = Variable<String>(principalPaidMinor.value);
    }
    if (interestPaidMinor.present) {
      map['interest_paid_minor'] = Variable<String>(interestPaidMinor.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditPaymentSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('creditId: $creditId, ')
          ..write('periodKey: $periodKey, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('principalAmountMinor: $principalAmountMinor, ')
          ..write('interestAmountMinor: $interestAmountMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('principalPaidMinor: $principalPaidMinor, ')
          ..write('interestPaidMinor: $interestPaidMinor, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditPaymentGroupsTable extends CreditPaymentGroups
    with TableInfo<$CreditPaymentGroupsTable, CreditPaymentGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditPaymentGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditIdMeta = const VerificationMeta(
    'creditId',
  );
  @override
  late final GeneratedColumn<String> creditId = GeneratedColumn<String>(
    'credit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduleItemIdMeta = const VerificationMeta(
    'scheduleItemId',
  );
  @override
  late final GeneratedColumn<String> scheduleItemId = GeneratedColumn<String>(
    'schedule_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credit_payment_schedules (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalOutflowMinorMeta = const VerificationMeta(
    'totalOutflowMinor',
  );
  @override
  late final GeneratedColumn<String> totalOutflowMinor =
      GeneratedColumn<String>(
        'total_outflow_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalOutflowScaleMeta = const VerificationMeta(
    'totalOutflowScale',
  );
  @override
  late final GeneratedColumn<int> totalOutflowScale = GeneratedColumn<int>(
    'total_outflow_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _principalPaidMinorMeta =
      const VerificationMeta('principalPaidMinor');
  @override
  late final GeneratedColumn<String> principalPaidMinor =
      GeneratedColumn<String>(
        'principal_paid_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _interestPaidMinorMeta = const VerificationMeta(
    'interestPaidMinor',
  );
  @override
  late final GeneratedColumn<String> interestPaidMinor =
      GeneratedColumn<String>(
        'interest_paid_minor',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _feesPaidMinorMeta = const VerificationMeta(
    'feesPaidMinor',
  );
  @override
  late final GeneratedColumn<String> feesPaidMinor = GeneratedColumn<String>(
    'fees_paid_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
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
    creditId,
    sourceAccountId,
    scheduleItemId,
    paidAt,
    totalOutflowMinor,
    totalOutflowScale,
    principalPaidMinor,
    interestPaidMinor,
    feesPaidMinor,
    note,
    idempotencyKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_payment_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditPaymentGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('credit_id')) {
      context.handle(
        _creditIdMeta,
        creditId.isAcceptableOrUnknown(data['credit_id']!, _creditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creditIdMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('schedule_item_id')) {
      context.handle(
        _scheduleItemIdMeta,
        scheduleItemId.isAcceptableOrUnknown(
          data['schedule_item_id']!,
          _scheduleItemIdMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('total_outflow_minor')) {
      context.handle(
        _totalOutflowMinorMeta,
        totalOutflowMinor.isAcceptableOrUnknown(
          data['total_outflow_minor']!,
          _totalOutflowMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalOutflowMinorMeta);
    }
    if (data.containsKey('total_outflow_scale')) {
      context.handle(
        _totalOutflowScaleMeta,
        totalOutflowScale.isAcceptableOrUnknown(
          data['total_outflow_scale']!,
          _totalOutflowScaleMeta,
        ),
      );
    }
    if (data.containsKey('principal_paid_minor')) {
      context.handle(
        _principalPaidMinorMeta,
        principalPaidMinor.isAcceptableOrUnknown(
          data['principal_paid_minor']!,
          _principalPaidMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPaidMinorMeta);
    }
    if (data.containsKey('interest_paid_minor')) {
      context.handle(
        _interestPaidMinorMeta,
        interestPaidMinor.isAcceptableOrUnknown(
          data['interest_paid_minor']!,
          _interestPaidMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestPaidMinorMeta);
    }
    if (data.containsKey('fees_paid_minor')) {
      context.handle(
        _feesPaidMinorMeta,
        feesPaidMinor.isAcceptableOrUnknown(
          data['fees_paid_minor']!,
          _feesPaidMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feesPaidMinorMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
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
  CreditPaymentGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditPaymentGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      creditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_id'],
      )!,
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      )!,
      scheduleItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_item_id'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
      totalOutflowMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_outflow_minor'],
      )!,
      totalOutflowScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_outflow_scale'],
      )!,
      principalPaidMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}principal_paid_minor'],
      )!,
      interestPaidMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_paid_minor'],
      )!,
      feesPaidMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fees_paid_minor'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
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
  $CreditPaymentGroupsTable createAlias(String alias) {
    return $CreditPaymentGroupsTable(attachedDatabase, alias);
  }
}

class CreditPaymentGroupRow extends DataClass
    implements Insertable<CreditPaymentGroupRow> {
  final String id;
  final String creditId;
  final String sourceAccountId;
  final String? scheduleItemId;
  final DateTime paidAt;
  final String totalOutflowMinor;
  final int totalOutflowScale;
  final String principalPaidMinor;
  final String interestPaidMinor;
  final String feesPaidMinor;
  final String? note;
  final String? idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CreditPaymentGroupRow({
    required this.id,
    required this.creditId,
    required this.sourceAccountId,
    this.scheduleItemId,
    required this.paidAt,
    required this.totalOutflowMinor,
    required this.totalOutflowScale,
    required this.principalPaidMinor,
    required this.interestPaidMinor,
    required this.feesPaidMinor,
    this.note,
    this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['credit_id'] = Variable<String>(creditId);
    map['source_account_id'] = Variable<String>(sourceAccountId);
    if (!nullToAbsent || scheduleItemId != null) {
      map['schedule_item_id'] = Variable<String>(scheduleItemId);
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['total_outflow_minor'] = Variable<String>(totalOutflowMinor);
    map['total_outflow_scale'] = Variable<int>(totalOutflowScale);
    map['principal_paid_minor'] = Variable<String>(principalPaidMinor);
    map['interest_paid_minor'] = Variable<String>(interestPaidMinor);
    map['fees_paid_minor'] = Variable<String>(feesPaidMinor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CreditPaymentGroupsCompanion toCompanion(bool nullToAbsent) {
    return CreditPaymentGroupsCompanion(
      id: Value(id),
      creditId: Value(creditId),
      sourceAccountId: Value(sourceAccountId),
      scheduleItemId: scheduleItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleItemId),
      paidAt: Value(paidAt),
      totalOutflowMinor: Value(totalOutflowMinor),
      totalOutflowScale: Value(totalOutflowScale),
      principalPaidMinor: Value(principalPaidMinor),
      interestPaidMinor: Value(interestPaidMinor),
      feesPaidMinor: Value(feesPaidMinor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CreditPaymentGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditPaymentGroupRow(
      id: serializer.fromJson<String>(json['id']),
      creditId: serializer.fromJson<String>(json['creditId']),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      scheduleItemId: serializer.fromJson<String?>(json['scheduleItemId']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      totalOutflowMinor: serializer.fromJson<String>(json['totalOutflowMinor']),
      totalOutflowScale: serializer.fromJson<int>(json['totalOutflowScale']),
      principalPaidMinor: serializer.fromJson<String>(
        json['principalPaidMinor'],
      ),
      interestPaidMinor: serializer.fromJson<String>(json['interestPaidMinor']),
      feesPaidMinor: serializer.fromJson<String>(json['feesPaidMinor']),
      note: serializer.fromJson<String?>(json['note']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'creditId': serializer.toJson<String>(creditId),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'scheduleItemId': serializer.toJson<String?>(scheduleItemId),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'totalOutflowMinor': serializer.toJson<String>(totalOutflowMinor),
      'totalOutflowScale': serializer.toJson<int>(totalOutflowScale),
      'principalPaidMinor': serializer.toJson<String>(principalPaidMinor),
      'interestPaidMinor': serializer.toJson<String>(interestPaidMinor),
      'feesPaidMinor': serializer.toJson<String>(feesPaidMinor),
      'note': serializer.toJson<String?>(note),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CreditPaymentGroupRow copyWith({
    String? id,
    String? creditId,
    String? sourceAccountId,
    Value<String?> scheduleItemId = const Value.absent(),
    DateTime? paidAt,
    String? totalOutflowMinor,
    int? totalOutflowScale,
    String? principalPaidMinor,
    String? interestPaidMinor,
    String? feesPaidMinor,
    Value<String?> note = const Value.absent(),
    Value<String?> idempotencyKey = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CreditPaymentGroupRow(
    id: id ?? this.id,
    creditId: creditId ?? this.creditId,
    sourceAccountId: sourceAccountId ?? this.sourceAccountId,
    scheduleItemId: scheduleItemId.present
        ? scheduleItemId.value
        : this.scheduleItemId,
    paidAt: paidAt ?? this.paidAt,
    totalOutflowMinor: totalOutflowMinor ?? this.totalOutflowMinor,
    totalOutflowScale: totalOutflowScale ?? this.totalOutflowScale,
    principalPaidMinor: principalPaidMinor ?? this.principalPaidMinor,
    interestPaidMinor: interestPaidMinor ?? this.interestPaidMinor,
    feesPaidMinor: feesPaidMinor ?? this.feesPaidMinor,
    note: note.present ? note.value : this.note,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CreditPaymentGroupRow copyWithCompanion(CreditPaymentGroupsCompanion data) {
    return CreditPaymentGroupRow(
      id: data.id.present ? data.id.value : this.id,
      creditId: data.creditId.present ? data.creditId.value : this.creditId,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      scheduleItemId: data.scheduleItemId.present
          ? data.scheduleItemId.value
          : this.scheduleItemId,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      totalOutflowMinor: data.totalOutflowMinor.present
          ? data.totalOutflowMinor.value
          : this.totalOutflowMinor,
      totalOutflowScale: data.totalOutflowScale.present
          ? data.totalOutflowScale.value
          : this.totalOutflowScale,
      principalPaidMinor: data.principalPaidMinor.present
          ? data.principalPaidMinor.value
          : this.principalPaidMinor,
      interestPaidMinor: data.interestPaidMinor.present
          ? data.interestPaidMinor.value
          : this.interestPaidMinor,
      feesPaidMinor: data.feesPaidMinor.present
          ? data.feesPaidMinor.value
          : this.feesPaidMinor,
      note: data.note.present ? data.note.value : this.note,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditPaymentGroupRow(')
          ..write('id: $id, ')
          ..write('creditId: $creditId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('scheduleItemId: $scheduleItemId, ')
          ..write('paidAt: $paidAt, ')
          ..write('totalOutflowMinor: $totalOutflowMinor, ')
          ..write('totalOutflowScale: $totalOutflowScale, ')
          ..write('principalPaidMinor: $principalPaidMinor, ')
          ..write('interestPaidMinor: $interestPaidMinor, ')
          ..write('feesPaidMinor: $feesPaidMinor, ')
          ..write('note: $note, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    creditId,
    sourceAccountId,
    scheduleItemId,
    paidAt,
    totalOutflowMinor,
    totalOutflowScale,
    principalPaidMinor,
    interestPaidMinor,
    feesPaidMinor,
    note,
    idempotencyKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditPaymentGroupRow &&
          other.id == this.id &&
          other.creditId == this.creditId &&
          other.sourceAccountId == this.sourceAccountId &&
          other.scheduleItemId == this.scheduleItemId &&
          other.paidAt == this.paidAt &&
          other.totalOutflowMinor == this.totalOutflowMinor &&
          other.totalOutflowScale == this.totalOutflowScale &&
          other.principalPaidMinor == this.principalPaidMinor &&
          other.interestPaidMinor == this.interestPaidMinor &&
          other.feesPaidMinor == this.feesPaidMinor &&
          other.note == this.note &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CreditPaymentGroupsCompanion
    extends UpdateCompanion<CreditPaymentGroupRow> {
  final Value<String> id;
  final Value<String> creditId;
  final Value<String> sourceAccountId;
  final Value<String?> scheduleItemId;
  final Value<DateTime> paidAt;
  final Value<String> totalOutflowMinor;
  final Value<int> totalOutflowScale;
  final Value<String> principalPaidMinor;
  final Value<String> interestPaidMinor;
  final Value<String> feesPaidMinor;
  final Value<String?> note;
  final Value<String?> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CreditPaymentGroupsCompanion({
    this.id = const Value.absent(),
    this.creditId = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.scheduleItemId = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.totalOutflowMinor = const Value.absent(),
    this.totalOutflowScale = const Value.absent(),
    this.principalPaidMinor = const Value.absent(),
    this.interestPaidMinor = const Value.absent(),
    this.feesPaidMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditPaymentGroupsCompanion.insert({
    required String id,
    required String creditId,
    required String sourceAccountId,
    this.scheduleItemId = const Value.absent(),
    required DateTime paidAt,
    required String totalOutflowMinor,
    this.totalOutflowScale = const Value.absent(),
    required String principalPaidMinor,
    required String interestPaidMinor,
    required String feesPaidMinor,
    this.note = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creditId = Value(creditId),
       sourceAccountId = Value(sourceAccountId),
       paidAt = Value(paidAt),
       totalOutflowMinor = Value(totalOutflowMinor),
       principalPaidMinor = Value(principalPaidMinor),
       interestPaidMinor = Value(interestPaidMinor),
       feesPaidMinor = Value(feesPaidMinor);
  static Insertable<CreditPaymentGroupRow> custom({
    Expression<String>? id,
    Expression<String>? creditId,
    Expression<String>? sourceAccountId,
    Expression<String>? scheduleItemId,
    Expression<DateTime>? paidAt,
    Expression<String>? totalOutflowMinor,
    Expression<int>? totalOutflowScale,
    Expression<String>? principalPaidMinor,
    Expression<String>? interestPaidMinor,
    Expression<String>? feesPaidMinor,
    Expression<String>? note,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditId != null) 'credit_id': creditId,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (scheduleItemId != null) 'schedule_item_id': scheduleItemId,
      if (paidAt != null) 'paid_at': paidAt,
      if (totalOutflowMinor != null) 'total_outflow_minor': totalOutflowMinor,
      if (totalOutflowScale != null) 'total_outflow_scale': totalOutflowScale,
      if (principalPaidMinor != null)
        'principal_paid_minor': principalPaidMinor,
      if (interestPaidMinor != null) 'interest_paid_minor': interestPaidMinor,
      if (feesPaidMinor != null) 'fees_paid_minor': feesPaidMinor,
      if (note != null) 'note': note,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditPaymentGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? creditId,
    Value<String>? sourceAccountId,
    Value<String?>? scheduleItemId,
    Value<DateTime>? paidAt,
    Value<String>? totalOutflowMinor,
    Value<int>? totalOutflowScale,
    Value<String>? principalPaidMinor,
    Value<String>? interestPaidMinor,
    Value<String>? feesPaidMinor,
    Value<String?>? note,
    Value<String?>? idempotencyKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CreditPaymentGroupsCompanion(
      id: id ?? this.id,
      creditId: creditId ?? this.creditId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      scheduleItemId: scheduleItemId ?? this.scheduleItemId,
      paidAt: paidAt ?? this.paidAt,
      totalOutflowMinor: totalOutflowMinor ?? this.totalOutflowMinor,
      totalOutflowScale: totalOutflowScale ?? this.totalOutflowScale,
      principalPaidMinor: principalPaidMinor ?? this.principalPaidMinor,
      interestPaidMinor: interestPaidMinor ?? this.interestPaidMinor,
      feesPaidMinor: feesPaidMinor ?? this.feesPaidMinor,
      note: note ?? this.note,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (creditId.present) {
      map['credit_id'] = Variable<String>(creditId.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (scheduleItemId.present) {
      map['schedule_item_id'] = Variable<String>(scheduleItemId.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (totalOutflowMinor.present) {
      map['total_outflow_minor'] = Variable<String>(totalOutflowMinor.value);
    }
    if (totalOutflowScale.present) {
      map['total_outflow_scale'] = Variable<int>(totalOutflowScale.value);
    }
    if (principalPaidMinor.present) {
      map['principal_paid_minor'] = Variable<String>(principalPaidMinor.value);
    }
    if (interestPaidMinor.present) {
      map['interest_paid_minor'] = Variable<String>(interestPaidMinor.value);
    }
    if (feesPaidMinor.present) {
      map['fees_paid_minor'] = Variable<String>(feesPaidMinor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditPaymentGroupsCompanion(')
          ..write('id: $id, ')
          ..write('creditId: $creditId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('scheduleItemId: $scheduleItemId, ')
          ..write('paidAt: $paidAt, ')
          ..write('totalOutflowMinor: $totalOutflowMinor, ')
          ..write('totalOutflowScale: $totalOutflowScale, ')
          ..write('principalPaidMinor: $principalPaidMinor, ')
          ..write('interestPaidMinor: $interestPaidMinor, ')
          ..write('feesPaidMinor: $feesPaidMinor, ')
          ..write('note: $note, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transferAccountIdMeta = const VerificationMeta(
    'transferAccountId',
  );
  @override
  late final GeneratedColumn<String> transferAccountId =
      GeneratedColumn<String>(
        'transfer_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingGoalIdMeta = const VerificationMeta(
    'savingGoalId',
  );
  @override
  late final GeneratedColumn<String> savingGoalId = GeneratedColumn<String>(
    'saving_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES saving_goals(id) ON DELETE SET NULL',
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
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credit_payment_groups (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    transferAccountId,
    categoryId,
    amount,
    amountMinor,
    amountScale,
    date,
    note,
    type,
    idempotencyKey,
    savingGoalId,
    createdAt,
    updatedAt,
    isDeleted,
    groupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('transfer_account_id')) {
      context.handle(
        _transferAccountIdMeta,
        transferAccountId.isAcceptableOrUnknown(
          data['transfer_account_id']!,
          _transferAccountIdMeta,
        ),
      );
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('saving_goal_id')) {
      context.handle(
        _savingGoalIdMeta,
        savingGoalId.isAcceptableOrUnknown(
          data['saving_goal_id']!,
          _savingGoalIdMeta,
        ),
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      transferAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      savingGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saving_goal_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String accountId;
  final String? transferAccountId;
  final String? categoryId;
  final double amount;
  final String amountMinor;
  final int amountScale;
  final DateTime date;
  final String? note;
  final String type;
  final String? idempotencyKey;
  final String? savingGoalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String? groupId;
  const TransactionRow({
    required this.id,
    required this.accountId,
    this.transferAccountId,
    this.categoryId,
    required this.amount,
    required this.amountMinor,
    required this.amountScale,
    required this.date,
    this.note,
    required this.type,
    this.idempotencyKey,
    this.savingGoalId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || transferAccountId != null) {
      map['transfer_account_id'] = Variable<String>(transferAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    if (!nullToAbsent || savingGoalId != null) {
      map['saving_goal_id'] = Variable<String>(savingGoalId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      transferAccountId: transferAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      amountScale: Value(amountScale),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      type: Value(type),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      savingGoalId: savingGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(savingGoalId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      transferAccountId: serializer.fromJson<String?>(
        json['transferAccountId'],
      ),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      type: serializer.fromJson<String>(json['type']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      savingGoalId: serializer.fromJson<String?>(json['savingGoalId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      groupId: serializer.fromJson<String?>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'transferAccountId': serializer.toJson<String?>(transferAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'type': serializer.toJson<String>(type),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'savingGoalId': serializer.toJson<String?>(savingGoalId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'groupId': serializer.toJson<String?>(groupId),
    };
  }

  TransactionRow copyWith({
    String? id,
    String? accountId,
    Value<String?> transferAccountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    double? amount,
    String? amountMinor,
    int? amountScale,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    String? type,
    Value<String?> idempotencyKey = const Value.absent(),
    Value<String?> savingGoalId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    Value<String?> groupId = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    transferAccountId: transferAccountId.present
        ? transferAccountId.value
        : this.transferAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    amountScale: amountScale ?? this.amountScale,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    type: type ?? this.type,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    savingGoalId: savingGoalId.present ? savingGoalId.value : this.savingGoalId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    groupId: groupId.present ? groupId.value : this.groupId,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transferAccountId: data.transferAccountId.present
          ? data.transferAccountId.value
          : this.transferAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      type: data.type.present ? data.type.value : this.type,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      savingGoalId: data.savingGoalId.present
          ? data.savingGoalId.value
          : this.savingGoalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('savingGoalId: $savingGoalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    transferAccountId,
    categoryId,
    amount,
    amountMinor,
    amountScale,
    date,
    note,
    type,
    idempotencyKey,
    savingGoalId,
    createdAt,
    updatedAt,
    isDeleted,
    groupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.transferAccountId == this.transferAccountId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.amountScale == this.amountScale &&
          other.date == this.date &&
          other.note == this.note &&
          other.type == this.type &&
          other.idempotencyKey == this.idempotencyKey &&
          other.savingGoalId == this.savingGoalId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.groupId == this.groupId);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> transferAccountId;
  final Value<String?> categoryId;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<int> amountScale;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<String> type;
  final Value<String?> idempotencyKey;
  final Value<String?> savingGoalId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> groupId;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transferAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.savingGoalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String accountId,
    this.transferAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double amount,
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    required String type,
    this.idempotencyKey = const Value.absent(),
    this.savingGoalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       amount = Value(amount),
       date = Value(date),
       type = Value(type);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? transferAccountId,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<int>? amountScale,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? type,
    Expression<String>? idempotencyKey,
    Expression<String>? savingGoalId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (transferAccountId != null) 'transfer_account_id': transferAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (type != null) 'type': type,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (savingGoalId != null) 'saving_goal_id': savingGoalId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String?>? transferAccountId,
    Value<String?>? categoryId,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<int>? amountScale,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<String>? type,
    Value<String?>? idempotencyKey,
    Value<String?>? savingGoalId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? groupId,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      transferAccountId: transferAccountId ?? this.transferAccountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      amountScale: amountScale ?? this.amountScale,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      savingGoalId: savingGoalId ?? this.savingGoalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (transferAccountId.present) {
      map['transfer_account_id'] = Variable<String>(transferAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (savingGoalId.present) {
      map['saving_goal_id'] = Variable<String>(savingGoalId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('savingGoalId: $savingGoalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
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
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    tagId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, tagId};
  @override
  TransactionTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTagRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTagRow extends DataClass
    implements Insertable<TransactionTagRow> {
  final String transactionId;
  final String tagId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const TransactionTagRow({
    required this.transactionId,
    required this.tagId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      transactionId: Value(transactionId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory TransactionTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTagRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TransactionTagRow copyWith({
    String? transactionId,
    String? tagId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => TransactionTagRow(
    transactionId: transactionId ?? this.transactionId,
    tagId: tagId ?? this.tagId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  TransactionTagRow copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTagRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagRow(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(transactionId, tagId, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTagRow &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTagRow> {
  final Value<String> transactionId;
  final Value<String> tagId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required String transactionId,
    required String tagId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       tagId = Value(tagId);
  static Insertable<TransactionTagRow> custom({
    Expression<String>? transactionId,
    Expression<String>? tagId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<String>? transactionId,
    Value<String>? tagId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TransactionTagsCompanion(
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
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
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    status,
    attemptCount,
    createdAt,
    updatedAt,
    sentAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
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
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntryRow extends DataClass implements Insertable<OutboxEntryRow> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final String status;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? sentAt;
  final String? lastError;
  const OutboxEntryRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.sentAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      status: Value(status),
      attemptCount: Value(attemptCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntryRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntryRow copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    String? status,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> sentAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntryRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntryRow copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntryRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntryRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    status,
    attemptCount,
    createdAt,
    updatedAt,
    sentAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntryRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sentAt == this.sentAt &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntryRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> sentAt;
  final Value<String?> lastError;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<OutboxEntryRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? sentAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? sentAt,
    Value<String?>? lastError,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentAt: sentAt ?? this.sentAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    uid,
    name,
    currency,
    locale,
    photoUrl,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
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
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String uid;
  final String? name;
  final String? currency;
  final String? locale;
  final String? photoUrl;
  final DateTime updatedAt;
  const ProfileRow({
    required this.uid,
    this.name,
    this.currency,
    this.locale,
    this.photoUrl,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      uid: Value(uid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String?>(json['name']),
      currency: serializer.fromJson<String?>(json['currency']),
      locale: serializer.fromJson<String?>(json['locale']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String?>(name),
      'currency': serializer.toJson<String?>(currency),
      'locale': serializer.toJson<String?>(locale),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRow copyWith({
    String? uid,
    Value<String?> name = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<String?> locale = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileRow(
    uid: uid ?? this.uid,
    name: name.present ? name.value : this.name,
    currency: currency.present ? currency.value : this.currency,
    locale: locale.present ? locale.value : this.locale,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      locale: data.locale.present ? data.locale.value : this.locale,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('locale: $locale, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, name, currency, locale, photoUrl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.locale == this.locale &&
          other.photoUrl == this.photoUrl &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> uid;
  final Value<String?> name;
  final Value<String?> currency;
  final Value<String?> locale;
  final Value<String?> photoUrl;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.locale = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String uid,
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.locale = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uid = Value(uid);
  static Insertable<ProfileRow> custom({
    Expression<String>? uid,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? locale,
    Expression<String>? photoUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (locale != null) 'locale': locale,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? uid,
    Value<String?>? name,
    Value<String?>? currency,
    Value<String?>? locale,
    Value<String?>? photoUrl,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('locale: $locale, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> categories =
      GeneratedColumn<String>(
        'categories',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => '[]',
      ).withConverter<List<String>>($BudgetsTable.$convertercategories);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> accounts =
      GeneratedColumn<String>(
        'accounts',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => '[]',
      ).withConverter<List<String>>($BudgetsTable.$converteraccounts);
  @override
  late final GeneratedColumnWithTypeConverter<
    List<Map<String, dynamic>>,
    String
  >
  categoryAllocations =
      GeneratedColumn<String>(
        'category_allocations',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => '[]',
      ).withConverter<List<Map<String, dynamic>>>(
        $BudgetsTable.$convertercategoryAllocations,
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
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    period,
    startDate,
    endDate,
    amount,
    amountMinor,
    amountScale,
    scope,
    categories,
    accounts,
    categoryAllocations,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      categories: $BudgetsTable.$convertercategories.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}categories'],
        )!,
      ),
      accounts: $BudgetsTable.$converteraccounts.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}accounts'],
        )!,
      ),
      categoryAllocations: $BudgetsTable.$convertercategoryAllocations.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category_allocations'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertercategories =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converteraccounts =
      const StringListConverter();
  static TypeConverter<List<Map<String, dynamic>>, String>
  $convertercategoryAllocations = const JsonMapListConverter();
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String id;
  final String title;
  final String period;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final String amountMinor;
  final int amountScale;
  final String scope;
  final List<String> categories;
  final List<String> accounts;
  final List<Map<String, dynamic>> categoryAllocations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const BudgetRow({
    required this.id,
    required this.title,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.amountMinor,
    required this.amountScale,
    required this.scope,
    required this.categories,
    required this.accounts,
    required this.categoryAllocations,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['scope'] = Variable<String>(scope);
    {
      map['categories'] = Variable<String>(
        $BudgetsTable.$convertercategories.toSql(categories),
      );
    }
    {
      map['accounts'] = Variable<String>(
        $BudgetsTable.$converteraccounts.toSql(accounts),
      );
    }
    {
      map['category_allocations'] = Variable<String>(
        $BudgetsTable.$convertercategoryAllocations.toSql(categoryAllocations),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      title: Value(title),
      period: Value(period),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      amountScale: Value(amountScale),
      scope: Value(scope),
      categories: Value(categories),
      accounts: Value(accounts),
      categoryAllocations: Value(categoryAllocations),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      scope: serializer.fromJson<String>(json['scope']),
      categories: serializer.fromJson<List<String>>(json['categories']),
      accounts: serializer.fromJson<List<String>>(json['accounts']),
      categoryAllocations: serializer.fromJson<List<Map<String, dynamic>>>(
        json['categoryAllocations'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'scope': serializer.toJson<String>(scope),
      'categories': serializer.toJson<List<String>>(categories),
      'accounts': serializer.toJson<List<String>>(accounts),
      'categoryAllocations': serializer.toJson<List<Map<String, dynamic>>>(
        categoryAllocations,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  BudgetRow copyWith({
    String? id,
    String? title,
    String? period,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    double? amount,
    String? amountMinor,
    int? amountScale,
    String? scope,
    List<String>? categories,
    List<String>? accounts,
    List<Map<String, dynamic>>? categoryAllocations,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => BudgetRow(
    id: id ?? this.id,
    title: title ?? this.title,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    amountScale: amountScale ?? this.amountScale,
    scope: scope ?? this.scope,
    categories: categories ?? this.categories,
    accounts: accounts ?? this.accounts,
    categoryAllocations: categoryAllocations ?? this.categoryAllocations,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      scope: data.scope.present ? data.scope.value : this.scope,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      accounts: data.accounts.present ? data.accounts.value : this.accounts,
      categoryAllocations: data.categoryAllocations.present
          ? data.categoryAllocations.value
          : this.categoryAllocations,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('scope: $scope, ')
          ..write('categories: $categories, ')
          ..write('accounts: $accounts, ')
          ..write('categoryAllocations: $categoryAllocations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    period,
    startDate,
    endDate,
    amount,
    amountMinor,
    amountScale,
    scope,
    categories,
    accounts,
    categoryAllocations,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.amountScale == this.amountScale &&
          other.scope == this.scope &&
          other.categories == this.categories &&
          other.accounts == this.accounts &&
          other.categoryAllocations == this.categoryAllocations &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<int> amountScale;
  final Value<String> scope;
  final Value<List<String>> categories;
  final Value<List<String>> accounts;
  final Value<List<Map<String, dynamic>>> categoryAllocations;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.scope = const Value.absent(),
    this.categories = const Value.absent(),
    this.accounts = const Value.absent(),
    this.categoryAllocations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String title,
    required String period,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required double amount,
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    required String scope,
    this.categories = const Value.absent(),
    this.accounts = const Value.absent(),
    this.categoryAllocations = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       period = Value(period),
       startDate = Value(startDate),
       amount = Value(amount),
       scope = Value(scope);
  static Insertable<BudgetRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<int>? amountScale,
    Expression<String>? scope,
    Expression<String>? categories,
    Expression<String>? accounts,
    Expression<String>? categoryAllocations,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (scope != null) 'scope': scope,
      if (categories != null) 'categories': categories,
      if (accounts != null) 'accounts': accounts,
      if (categoryAllocations != null)
        'category_allocations': categoryAllocations,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? period,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<int>? amountScale,
    Value<String>? scope,
    Value<List<String>>? categories,
    Value<List<String>>? accounts,
    Value<List<Map<String, dynamic>>>? categoryAllocations,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      amountScale: amountScale ?? this.amountScale,
      scope: scope ?? this.scope,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
      categoryAllocations: categoryAllocations ?? this.categoryAllocations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(
        $BudgetsTable.$convertercategories.toSql(categories.value),
      );
    }
    if (accounts.present) {
      map['accounts'] = Variable<String>(
        $BudgetsTable.$converteraccounts.toSql(accounts.value),
      );
    }
    if (categoryAllocations.present) {
      map['category_allocations'] = Variable<String>(
        $BudgetsTable.$convertercategoryAllocations.toSql(
          categoryAllocations.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('scope: $scope, ')
          ..write('categories: $categories, ')
          ..write('accounts: $accounts, ')
          ..write('categoryAllocations: $categoryAllocations, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetInstancesTable extends BudgetInstances
    with TableInfo<$BudgetInstancesTable, BudgetInstanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budgets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _spentMeta = const VerificationMeta('spent');
  @override
  late final GeneratedColumn<double> spent = GeneratedColumn<double>(
    'spent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant<double>(0),
  );
  static const VerificationMeta _spentMinorMeta = const VerificationMeta(
    'spentMinor',
  );
  @override
  late final GeneratedColumn<String> spentMinor = GeneratedColumn<String>(
    'spent_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('pending'),
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
    budgetId,
    periodStart,
    periodEnd,
    amount,
    amountMinor,
    spent,
    spentMinor,
    amountScale,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetInstanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('spent')) {
      context.handle(
        _spentMeta,
        spent.isAcceptableOrUnknown(data['spent']!, _spentMeta),
      );
    }
    if (data.containsKey('spent_minor')) {
      context.handle(
        _spentMinorMeta,
        spentMinor.isAcceptableOrUnknown(data['spent_minor']!, _spentMinorMeta),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  BudgetInstanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetInstanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      spent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spent'],
      )!,
      spentMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spent_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
  $BudgetInstancesTable createAlias(String alias) {
    return $BudgetInstancesTable(attachedDatabase, alias);
  }
}

class BudgetInstanceRow extends DataClass
    implements Insertable<BudgetInstanceRow> {
  final String id;
  final String budgetId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double amount;
  final String amountMinor;
  final double spent;
  final String spentMinor;
  final int amountScale;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BudgetInstanceRow({
    required this.id,
    required this.budgetId,
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.amountMinor,
    required this.spent,
    required this.spentMinor,
    required this.amountScale,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['budget_id'] = Variable<String>(budgetId);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['spent'] = Variable<double>(spent);
    map['spent_minor'] = Variable<String>(spentMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetInstancesCompanion toCompanion(bool nullToAbsent) {
    return BudgetInstancesCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      spent: Value(spent),
      spentMinor: Value(spentMinor),
      amountScale: Value(amountScale),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BudgetInstanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetInstanceRow(
      id: serializer.fromJson<String>(json['id']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      spent: serializer.fromJson<double>(json['spent']),
      spentMinor: serializer.fromJson<String>(json['spentMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'budgetId': serializer.toJson<String>(budgetId),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'spent': serializer.toJson<double>(spent),
      'spentMinor': serializer.toJson<String>(spentMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BudgetInstanceRow copyWith({
    String? id,
    String? budgetId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? amount,
    String? amountMinor,
    double? spent,
    String? spentMinor,
    int? amountScale,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BudgetInstanceRow(
    id: id ?? this.id,
    budgetId: budgetId ?? this.budgetId,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    spent: spent ?? this.spent,
    spentMinor: spentMinor ?? this.spentMinor,
    amountScale: amountScale ?? this.amountScale,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BudgetInstanceRow copyWithCompanion(BudgetInstancesCompanion data) {
    return BudgetInstanceRow(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      spent: data.spent.present ? data.spent.value : this.spent,
      spentMinor: data.spentMinor.present
          ? data.spentMinor.value
          : this.spentMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetInstanceRow(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('spent: $spent, ')
          ..write('spentMinor: $spentMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    budgetId,
    periodStart,
    periodEnd,
    amount,
    amountMinor,
    spent,
    spentMinor,
    amountScale,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetInstanceRow &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.spent == this.spent &&
          other.spentMinor == this.spentMinor &&
          other.amountScale == this.amountScale &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetInstancesCompanion extends UpdateCompanion<BudgetInstanceRow> {
  final Value<String> id;
  final Value<String> budgetId;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<double> spent;
  final Value<String> spentMinor;
  final Value<int> amountScale;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetInstancesCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.spent = const Value.absent(),
    this.spentMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetInstancesCompanion.insert({
    required String id,
    required String budgetId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double amount,
    this.amountMinor = const Value.absent(),
    this.spent = const Value.absent(),
    this.spentMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       budgetId = Value(budgetId),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       amount = Value(amount);
  static Insertable<BudgetInstanceRow> custom({
    Expression<String>? id,
    Expression<String>? budgetId,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<double>? spent,
    Expression<String>? spentMinor,
    Expression<int>? amountScale,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (spent != null) 'spent': spent,
      if (spentMinor != null) 'spent_minor': spentMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetInstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? budgetId,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<double>? spent,
    Value<String>? spentMinor,
    Value<int>? amountScale,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetInstancesCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      spent: spent ?? this.spent,
      spentMinor: spentMinor ?? this.spentMinor,
      amountScale: amountScale ?? this.amountScale,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (spent.present) {
      map['spent'] = Variable<double>(spent.value);
    }
    if (spentMinor.present) {
      map['spent_minor'] = Variable<String>(spentMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetInstancesCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('spent: $spent, ')
          ..write('spentMinor: $spentMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalContributionsTable extends GoalContributions
    with TableInfo<$GoalContributionsTable, GoalContributionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saving_goals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
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
    goalId,
    transactionId,
    amount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalContributionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
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
  GoalContributionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalContributionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalContributionsTable createAlias(String alias) {
    return $GoalContributionsTable(attachedDatabase, alias);
  }
}

class GoalContributionRow extends DataClass
    implements Insertable<GoalContributionRow> {
  final String id;
  final String goalId;
  final String transactionId;
  final int amount;
  final DateTime createdAt;
  const GoalContributionRow({
    required this.id,
    required this.goalId,
    required this.transactionId,
    required this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalContributionsCompanion toCompanion(bool nullToAbsent) {
    return GoalContributionsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      transactionId: Value(transactionId),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory GoalContributionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalContributionRow(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'transactionId': serializer.toJson<String>(transactionId),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalContributionRow copyWith({
    String? id,
    String? goalId,
    String? transactionId,
    int? amount,
    DateTime? createdAt,
  }) => GoalContributionRow(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    transactionId: transactionId ?? this.transactionId,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalContributionRow copyWithCompanion(GoalContributionsCompanion data) {
    return GoalContributionRow(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalContributionRow(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goalId, transactionId, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalContributionRow &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.transactionId == this.transactionId &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class GoalContributionsCompanion extends UpdateCompanion<GoalContributionRow> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<String> transactionId;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalContributionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalContributionsCompanion.insert({
    required String id,
    required String goalId,
    required String transactionId,
    required int amount,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       goalId = Value(goalId),
       transactionId = Value(transactionId),
       amount = Value(amount);
  static Insertable<GoalContributionRow> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<String>? transactionId,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalContributionsCompanion copyWith({
    Value<String>? id,
    Value<String>? goalId,
    Value<String>? transactionId,
    Value<int>? amount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GoalContributionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalContributionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('transactionId: $transactionId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UpcomingPaymentsTable extends UpcomingPayments
    with TableInfo<$UpcomingPaymentsTable, UpcomingPaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpcomingPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notifyDaysBeforeMeta = const VerificationMeta(
    'notifyDaysBefore',
  );
  @override
  late final GeneratedColumn<int> notifyDaysBefore = GeneratedColumn<int>(
    'notify_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _notifyTimeHhmmMeta = const VerificationMeta(
    'notifyTimeHhmm',
  );
  @override
  late final GeneratedColumn<String> notifyTimeHhmm = GeneratedColumn<String>(
    'notify_time_hhmm',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 5,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('12:00'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoPostMeta = const VerificationMeta(
    'autoPost',
  );
  @override
  late final GeneratedColumn<bool> autoPost = GeneratedColumn<bool>(
    'auto_post',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_post" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _nextRunAtMeta = const VerificationMeta(
    'nextRunAt',
  );
  @override
  late final GeneratedColumn<int> nextRunAt = GeneratedColumn<int>(
    'next_run_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextNotifyAtMeta = const VerificationMeta(
    'nextNotifyAt',
  );
  @override
  late final GeneratedColumn<int> nextNotifyAt = GeneratedColumn<int>(
    'next_notify_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastGeneratedPeriodMeta =
      const VerificationMeta('lastGeneratedPeriod');
  @override
  late final GeneratedColumn<String> lastGeneratedPeriod =
      GeneratedColumn<String>(
        'last_generated_period',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    accountId,
    categoryId,
    amount,
    amountMinor,
    amountScale,
    dayOfMonth,
    notifyDaysBefore,
    notifyTimeHhmm,
    note,
    autoPost,
    isActive,
    nextRunAt,
    nextNotifyAt,
    lastGeneratedPeriod,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'upcoming_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpcomingPaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('notify_days_before')) {
      context.handle(
        _notifyDaysBeforeMeta,
        notifyDaysBefore.isAcceptableOrUnknown(
          data['notify_days_before']!,
          _notifyDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('notify_time_hhmm')) {
      context.handle(
        _notifyTimeHhmmMeta,
        notifyTimeHhmm.isAcceptableOrUnknown(
          data['notify_time_hhmm']!,
          _notifyTimeHhmmMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('auto_post')) {
      context.handle(
        _autoPostMeta,
        autoPost.isAcceptableOrUnknown(data['auto_post']!, _autoPostMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
        _nextRunAtMeta,
        nextRunAt.isAcceptableOrUnknown(data['next_run_at']!, _nextRunAtMeta),
      );
    }
    if (data.containsKey('next_notify_at')) {
      context.handle(
        _nextNotifyAtMeta,
        nextNotifyAt.isAcceptableOrUnknown(
          data['next_notify_at']!,
          _nextNotifyAtMeta,
        ),
      );
    }
    if (data.containsKey('last_generated_period')) {
      context.handle(
        _lastGeneratedPeriodMeta,
        lastGeneratedPeriod.isAcceptableOrUnknown(
          data['last_generated_period']!,
          _lastGeneratedPeriodMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UpcomingPaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpcomingPaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      notifyDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notify_days_before'],
      )!,
      notifyTimeHhmm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notify_time_hhmm'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      autoPost: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_post'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      nextRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_run_at'],
      ),
      nextNotifyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_notify_at'],
      ),
      lastGeneratedPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated_period'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UpcomingPaymentsTable createAlias(String alias) {
    return $UpcomingPaymentsTable(attachedDatabase, alias);
  }
}

class UpcomingPaymentRow extends DataClass
    implements Insertable<UpcomingPaymentRow> {
  final String id;
  final String title;
  final String accountId;
  final String categoryId;
  final double amount;
  final String amountMinor;
  final int amountScale;
  final int dayOfMonth;
  final int notifyDaysBefore;
  final String notifyTimeHhmm;
  final String? note;
  final bool autoPost;
  final bool isActive;
  final int? nextRunAt;
  final int? nextNotifyAt;
  final String? lastGeneratedPeriod;
  final int createdAt;
  final int updatedAt;
  const UpcomingPaymentRow({
    required this.id,
    required this.title,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.amountMinor,
    required this.amountScale,
    required this.dayOfMonth,
    required this.notifyDaysBefore,
    required this.notifyTimeHhmm,
    this.note,
    required this.autoPost,
    required this.isActive,
    this.nextRunAt,
    this.nextNotifyAt,
    this.lastGeneratedPeriod,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['account_id'] = Variable<String>(accountId);
    map['category_id'] = Variable<String>(categoryId);
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['notify_days_before'] = Variable<int>(notifyDaysBefore);
    map['notify_time_hhmm'] = Variable<String>(notifyTimeHhmm);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['auto_post'] = Variable<bool>(autoPost);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || nextRunAt != null) {
      map['next_run_at'] = Variable<int>(nextRunAt);
    }
    if (!nullToAbsent || nextNotifyAt != null) {
      map['next_notify_at'] = Variable<int>(nextNotifyAt);
    }
    if (!nullToAbsent || lastGeneratedPeriod != null) {
      map['last_generated_period'] = Variable<String>(lastGeneratedPeriod);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UpcomingPaymentsCompanion toCompanion(bool nullToAbsent) {
    return UpcomingPaymentsCompanion(
      id: Value(id),
      title: Value(title),
      accountId: Value(accountId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      amountScale: Value(amountScale),
      dayOfMonth: Value(dayOfMonth),
      notifyDaysBefore: Value(notifyDaysBefore),
      notifyTimeHhmm: Value(notifyTimeHhmm),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      autoPost: Value(autoPost),
      isActive: Value(isActive),
      nextRunAt: nextRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRunAt),
      nextNotifyAt: nextNotifyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextNotifyAt),
      lastGeneratedPeriod: lastGeneratedPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedPeriod),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UpcomingPaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpcomingPaymentRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      notifyDaysBefore: serializer.fromJson<int>(json['notifyDaysBefore']),
      notifyTimeHhmm: serializer.fromJson<String>(json['notifyTimeHhmm']),
      note: serializer.fromJson<String?>(json['note']),
      autoPost: serializer.fromJson<bool>(json['autoPost']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      nextRunAt: serializer.fromJson<int?>(json['nextRunAt']),
      nextNotifyAt: serializer.fromJson<int?>(json['nextNotifyAt']),
      lastGeneratedPeriod: serializer.fromJson<String?>(
        json['lastGeneratedPeriod'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'notifyDaysBefore': serializer.toJson<int>(notifyDaysBefore),
      'notifyTimeHhmm': serializer.toJson<String>(notifyTimeHhmm),
      'note': serializer.toJson<String?>(note),
      'autoPost': serializer.toJson<bool>(autoPost),
      'isActive': serializer.toJson<bool>(isActive),
      'nextRunAt': serializer.toJson<int?>(nextRunAt),
      'nextNotifyAt': serializer.toJson<int?>(nextNotifyAt),
      'lastGeneratedPeriod': serializer.toJson<String?>(lastGeneratedPeriod),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UpcomingPaymentRow copyWith({
    String? id,
    String? title,
    String? accountId,
    String? categoryId,
    double? amount,
    String? amountMinor,
    int? amountScale,
    int? dayOfMonth,
    int? notifyDaysBefore,
    String? notifyTimeHhmm,
    Value<String?> note = const Value.absent(),
    bool? autoPost,
    bool? isActive,
    Value<int?> nextRunAt = const Value.absent(),
    Value<int?> nextNotifyAt = const Value.absent(),
    Value<String?> lastGeneratedPeriod = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => UpcomingPaymentRow(
    id: id ?? this.id,
    title: title ?? this.title,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    amountScale: amountScale ?? this.amountScale,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
    notifyTimeHhmm: notifyTimeHhmm ?? this.notifyTimeHhmm,
    note: note.present ? note.value : this.note,
    autoPost: autoPost ?? this.autoPost,
    isActive: isActive ?? this.isActive,
    nextRunAt: nextRunAt.present ? nextRunAt.value : this.nextRunAt,
    nextNotifyAt: nextNotifyAt.present ? nextNotifyAt.value : this.nextNotifyAt,
    lastGeneratedPeriod: lastGeneratedPeriod.present
        ? lastGeneratedPeriod.value
        : this.lastGeneratedPeriod,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UpcomingPaymentRow copyWithCompanion(UpcomingPaymentsCompanion data) {
    return UpcomingPaymentRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      notifyDaysBefore: data.notifyDaysBefore.present
          ? data.notifyDaysBefore.value
          : this.notifyDaysBefore,
      notifyTimeHhmm: data.notifyTimeHhmm.present
          ? data.notifyTimeHhmm.value
          : this.notifyTimeHhmm,
      note: data.note.present ? data.note.value : this.note,
      autoPost: data.autoPost.present ? data.autoPost.value : this.autoPost,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      nextNotifyAt: data.nextNotifyAt.present
          ? data.nextNotifyAt.value
          : this.nextNotifyAt,
      lastGeneratedPeriod: data.lastGeneratedPeriod.present
          ? data.lastGeneratedPeriod.value
          : this.lastGeneratedPeriod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpcomingPaymentRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('notifyDaysBefore: $notifyDaysBefore, ')
          ..write('notifyTimeHhmm: $notifyTimeHhmm, ')
          ..write('note: $note, ')
          ..write('autoPost: $autoPost, ')
          ..write('isActive: $isActive, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('nextNotifyAt: $nextNotifyAt, ')
          ..write('lastGeneratedPeriod: $lastGeneratedPeriod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    accountId,
    categoryId,
    amount,
    amountMinor,
    amountScale,
    dayOfMonth,
    notifyDaysBefore,
    notifyTimeHhmm,
    note,
    autoPost,
    isActive,
    nextRunAt,
    nextNotifyAt,
    lastGeneratedPeriod,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpcomingPaymentRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.amountScale == this.amountScale &&
          other.dayOfMonth == this.dayOfMonth &&
          other.notifyDaysBefore == this.notifyDaysBefore &&
          other.notifyTimeHhmm == this.notifyTimeHhmm &&
          other.note == this.note &&
          other.autoPost == this.autoPost &&
          other.isActive == this.isActive &&
          other.nextRunAt == this.nextRunAt &&
          other.nextNotifyAt == this.nextNotifyAt &&
          other.lastGeneratedPeriod == this.lastGeneratedPeriod &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UpcomingPaymentsCompanion extends UpdateCompanion<UpcomingPaymentRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> accountId;
  final Value<String> categoryId;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<int> amountScale;
  final Value<int> dayOfMonth;
  final Value<int> notifyDaysBefore;
  final Value<String> notifyTimeHhmm;
  final Value<String?> note;
  final Value<bool> autoPost;
  final Value<bool> isActive;
  final Value<int?> nextRunAt;
  final Value<int?> nextNotifyAt;
  final Value<String?> lastGeneratedPeriod;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const UpcomingPaymentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.notifyDaysBefore = const Value.absent(),
    this.notifyTimeHhmm = const Value.absent(),
    this.note = const Value.absent(),
    this.autoPost = const Value.absent(),
    this.isActive = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.nextNotifyAt = const Value.absent(),
    this.lastGeneratedPeriod = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UpcomingPaymentsCompanion.insert({
    required String id,
    required String title,
    required String accountId,
    required String categoryId,
    required double amount,
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    required int dayOfMonth,
    this.notifyDaysBefore = const Value.absent(),
    this.notifyTimeHhmm = const Value.absent(),
    this.note = const Value.absent(),
    this.autoPost = const Value.absent(),
    this.isActive = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.nextNotifyAt = const Value.absent(),
    this.lastGeneratedPeriod = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       accountId = Value(accountId),
       categoryId = Value(categoryId),
       amount = Value(amount),
       dayOfMonth = Value(dayOfMonth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UpcomingPaymentRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<int>? amountScale,
    Expression<int>? dayOfMonth,
    Expression<int>? notifyDaysBefore,
    Expression<String>? notifyTimeHhmm,
    Expression<String>? note,
    Expression<bool>? autoPost,
    Expression<bool>? isActive,
    Expression<int>? nextRunAt,
    Expression<int>? nextNotifyAt,
    Expression<String>? lastGeneratedPeriod,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (notifyDaysBefore != null) 'notify_days_before': notifyDaysBefore,
      if (notifyTimeHhmm != null) 'notify_time_hhmm': notifyTimeHhmm,
      if (note != null) 'note': note,
      if (autoPost != null) 'auto_post': autoPost,
      if (isActive != null) 'is_active': isActive,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (nextNotifyAt != null) 'next_notify_at': nextNotifyAt,
      if (lastGeneratedPeriod != null)
        'last_generated_period': lastGeneratedPeriod,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UpcomingPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? accountId,
    Value<String>? categoryId,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<int>? amountScale,
    Value<int>? dayOfMonth,
    Value<int>? notifyDaysBefore,
    Value<String>? notifyTimeHhmm,
    Value<String?>? note,
    Value<bool>? autoPost,
    Value<bool>? isActive,
    Value<int?>? nextRunAt,
    Value<int?>? nextNotifyAt,
    Value<String?>? lastGeneratedPeriod,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return UpcomingPaymentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      amountScale: amountScale ?? this.amountScale,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
      notifyTimeHhmm: notifyTimeHhmm ?? this.notifyTimeHhmm,
      note: note ?? this.note,
      autoPost: autoPost ?? this.autoPost,
      isActive: isActive ?? this.isActive,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      nextNotifyAt: nextNotifyAt ?? this.nextNotifyAt,
      lastGeneratedPeriod: lastGeneratedPeriod ?? this.lastGeneratedPeriod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (notifyDaysBefore.present) {
      map['notify_days_before'] = Variable<int>(notifyDaysBefore.value);
    }
    if (notifyTimeHhmm.present) {
      map['notify_time_hhmm'] = Variable<String>(notifyTimeHhmm.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (autoPost.present) {
      map['auto_post'] = Variable<bool>(autoPost.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<int>(nextRunAt.value);
    }
    if (nextNotifyAt.present) {
      map['next_notify_at'] = Variable<int>(nextNotifyAt.value);
    }
    if (lastGeneratedPeriod.present) {
      map['last_generated_period'] = Variable<String>(
        lastGeneratedPeriod.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpcomingPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('notifyDaysBefore: $notifyDaysBefore, ')
          ..write('notifyTimeHhmm: $notifyTimeHhmm, ')
          ..write('note: $note, ')
          ..write('autoPost: $autoPost, ')
          ..write('isActive: $isActive, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('nextNotifyAt: $nextNotifyAt, ')
          ..write('lastGeneratedPeriod: $lastGeneratedPeriod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentRemindersTable extends PaymentReminders
    with TableInfo<$PaymentRemindersTable, PaymentReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _whenAtMeta = const VerificationMeta('whenAt');
  @override
  late final GeneratedColumn<int> whenAt = GeneratedColumn<int>(
    'when_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _lastNotifiedAtMeta = const VerificationMeta(
    'lastNotifiedAt',
  );
  @override
  late final GeneratedColumn<int> lastNotifiedAt = GeneratedColumn<int>(
    'last_notified_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amount,
    amountMinor,
    amountScale,
    whenAt,
    note,
    isDone,
    lastNotifiedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('when_at')) {
      context.handle(
        _whenAtMeta,
        whenAt.isAcceptableOrUnknown(data['when_at']!, _whenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_whenAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('last_notified_at')) {
      context.handle(
        _lastNotifiedAtMeta,
        lastNotifiedAt.isAcceptableOrUnknown(
          data['last_notified_at']!,
          _lastNotifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      whenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}when_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      lastNotifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_notified_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PaymentRemindersTable createAlias(String alias) {
    return $PaymentRemindersTable(attachedDatabase, alias);
  }
}

class PaymentReminderRow extends DataClass
    implements Insertable<PaymentReminderRow> {
  final String id;
  final String title;
  final double amount;
  final String amountMinor;
  final int amountScale;
  final int whenAt;
  final String? note;
  final bool isDone;
  final int? lastNotifiedAt;
  final int createdAt;
  final int updatedAt;
  const PaymentReminderRow({
    required this.id,
    required this.title,
    required this.amount,
    required this.amountMinor,
    required this.amountScale,
    required this.whenAt,
    this.note,
    required this.isDone,
    this.lastNotifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['when_at'] = Variable<int>(whenAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || lastNotifiedAt != null) {
      map['last_notified_at'] = Variable<int>(lastNotifiedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PaymentRemindersCompanion toCompanion(bool nullToAbsent) {
    return PaymentRemindersCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      amountScale: Value(amountScale),
      whenAt: Value(whenAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isDone: Value(isDone),
      lastNotifiedAt: lastNotifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentReminderRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      whenAt: serializer.fromJson<int>(json['whenAt']),
      note: serializer.fromJson<String?>(json['note']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      lastNotifiedAt: serializer.fromJson<int?>(json['lastNotifiedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'whenAt': serializer.toJson<int>(whenAt),
      'note': serializer.toJson<String?>(note),
      'isDone': serializer.toJson<bool>(isDone),
      'lastNotifiedAt': serializer.toJson<int?>(lastNotifiedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PaymentReminderRow copyWith({
    String? id,
    String? title,
    double? amount,
    String? amountMinor,
    int? amountScale,
    int? whenAt,
    Value<String?> note = const Value.absent(),
    bool? isDone,
    Value<int?> lastNotifiedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => PaymentReminderRow(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    amountScale: amountScale ?? this.amountScale,
    whenAt: whenAt ?? this.whenAt,
    note: note.present ? note.value : this.note,
    isDone: isDone ?? this.isDone,
    lastNotifiedAt: lastNotifiedAt.present
        ? lastNotifiedAt.value
        : this.lastNotifiedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PaymentReminderRow copyWithCompanion(PaymentRemindersCompanion data) {
    return PaymentReminderRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      whenAt: data.whenAt.present ? data.whenAt.value : this.whenAt,
      note: data.note.present ? data.note.value : this.note,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      lastNotifiedAt: data.lastNotifiedAt.present
          ? data.lastNotifiedAt.value
          : this.lastNotifiedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentReminderRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('whenAt: $whenAt, ')
          ..write('note: $note, ')
          ..write('isDone: $isDone, ')
          ..write('lastNotifiedAt: $lastNotifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    amountMinor,
    amountScale,
    whenAt,
    note,
    isDone,
    lastNotifiedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentReminderRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.amountScale == this.amountScale &&
          other.whenAt == this.whenAt &&
          other.note == this.note &&
          other.isDone == this.isDone &&
          other.lastNotifiedAt == this.lastNotifiedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentRemindersCompanion extends UpdateCompanion<PaymentReminderRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<int> amountScale;
  final Value<int> whenAt;
  final Value<String?> note;
  final Value<bool> isDone;
  final Value<int?> lastNotifiedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PaymentRemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.whenAt = const Value.absent(),
    this.note = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lastNotifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentRemindersCompanion.insert({
    required String id,
    required String title,
    required double amount,
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    required int whenAt,
    this.note = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lastNotifiedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       whenAt = Value(whenAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PaymentReminderRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<int>? amountScale,
    Expression<int>? whenAt,
    Expression<String>? note,
    Expression<bool>? isDone,
    Expression<int>? lastNotifiedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (whenAt != null) 'when_at': whenAt,
      if (note != null) 'note': note,
      if (isDone != null) 'is_done': isDone,
      if (lastNotifiedAt != null) 'last_notified_at': lastNotifiedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentRemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<int>? amountScale,
    Value<int>? whenAt,
    Value<String?>? note,
    Value<bool>? isDone,
    Value<int?>? lastNotifiedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentRemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      amountScale: amountScale ?? this.amountScale,
      whenAt: whenAt ?? this.whenAt,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (whenAt.present) {
      map['when_at'] = Variable<int>(whenAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (lastNotifiedAt.present) {
      map['last_notified_at'] = Variable<int>(lastNotifiedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('whenAt: $whenAt, ')
          ..write('note: $note, ')
          ..write('isDone: $isDone, ')
          ..write('lastNotifiedAt: $lastNotifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, DebtRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<String> amountMinor = GeneratedColumn<String>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _amountScaleMeta = const VerificationMeta(
    'amountScale',
  );
  @override
  late final GeneratedColumn<int> amountScale = GeneratedColumn<int>(
    'amount_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    name,
    amount,
    amountMinor,
    amountScale,
    dueDate,
    note,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_scale')) {
      context.handle(
        _amountScaleMeta,
        amountScale.isAcceptableOrUnknown(
          data['amount_scale']!,
          _amountScaleMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_minor'],
      )!,
      amountScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_scale'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class DebtRow extends DataClass implements Insertable<DebtRow> {
  final String id;
  final String accountId;
  final String? name;
  final double amount;
  final String amountMinor;
  final int amountScale;
  final DateTime dueDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const DebtRow({
    required this.id,
    required this.accountId,
    this.name,
    required this.amount,
    required this.amountMinor,
    required this.amountScale,
    required this.dueDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['amount'] = Variable<double>(amount);
    map['amount_minor'] = Variable<String>(amountMinor);
    map['amount_scale'] = Variable<int>(amountScale);
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      amount: Value(amount),
      amountMinor: Value(amountMinor),
      amountScale: Value(amountScale),
      dueDate: Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory DebtRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String?>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      amountMinor: serializer.fromJson<String>(json['amountMinor']),
      amountScale: serializer.fromJson<int>(json['amountScale']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String?>(name),
      'amount': serializer.toJson<double>(amount),
      'amountMinor': serializer.toJson<String>(amountMinor),
      'amountScale': serializer.toJson<int>(amountScale),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  DebtRow copyWith({
    String? id,
    String? accountId,
    Value<String?> name = const Value.absent(),
    double? amount,
    String? amountMinor,
    int? amountScale,
    DateTime? dueDate,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => DebtRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    name: name.present ? name.value : this.name,
    amount: amount ?? this.amount,
    amountMinor: amountMinor ?? this.amountMinor,
    amountScale: amountScale ?? this.amountScale,
    dueDate: dueDate ?? this.dueDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  DebtRow copyWithCompanion(DebtsCompanion data) {
    return DebtRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      amountScale: data.amountScale.present
          ? data.amountScale.value
          : this.amountScale,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    name,
    amount,
    amountMinor,
    amountScale,
    dueDate,
    note,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.amountMinor == this.amountMinor &&
          other.amountScale == this.amountScale &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class DebtsCompanion extends UpdateCompanion<DebtRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> name;
  final Value<double> amount;
  final Value<String> amountMinor;
  final Value<int> amountScale;
  final Value<DateTime> dueDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    required String id,
    required String accountId,
    this.name = const Value.absent(),
    required double amount,
    this.amountMinor = const Value.absent(),
    this.amountScale = const Value.absent(),
    required DateTime dueDate,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       amount = Value(amount),
       dueDate = Value(dueDate);
  static Insertable<DebtRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? amountMinor,
    Expression<int>? amountScale,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (amountScale != null) 'amount_scale': amountScale,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String?>? name,
    Value<double>? amount,
    Value<String>? amountMinor,
    Value<int>? amountScale,
    Value<DateTime>? dueDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      amountMinor: amountMinor ?? this.amountMinor,
      amountScale: amountScale ?? this.amountScale,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<String>(amountMinor.value);
    }
    if (amountScale.present) {
      map['amount_scale'] = Variable<int>(amountScale.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('amountScale: $amountScale, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CreditCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitMinorMeta = const VerificationMeta(
    'creditLimitMinor',
  );
  @override
  late final GeneratedColumn<String> creditLimitMinor = GeneratedColumn<String>(
    'credit_limit_minor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('0'),
  );
  static const VerificationMeta _creditLimitScaleMeta = const VerificationMeta(
    'creditLimitScale',
  );
  @override
  late final GeneratedColumn<int> creditLimitScale = GeneratedColumn<int>(
    'credit_limit_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(2),
  );
  static const VerificationMeta _statementDayMeta = const VerificationMeta(
    'statementDay',
  );
  @override
  late final GeneratedColumn<int> statementDay = GeneratedColumn<int>(
    'statement_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDueDaysMeta = const VerificationMeta(
    'paymentDueDays',
  );
  @override
  late final GeneratedColumn<int> paymentDueDays = GeneratedColumn<int>(
    'payment_due_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestRateAnnualMeta =
      const VerificationMeta('interestRateAnnual');
  @override
  late final GeneratedColumn<double> interestRateAnnual =
      GeneratedColumn<double>(
        'interest_rate_annual',
        aliasedName,
        false,
        type: DriftSqlType.double,
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
    defaultValue: const Constant<bool>(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    creditLimit,
    creditLimitMinor,
    creditLimitScale,
    statementDay,
    paymentDueDays,
    interestRateAnnual,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditLimitMeta);
    }
    if (data.containsKey('credit_limit_minor')) {
      context.handle(
        _creditLimitMinorMeta,
        creditLimitMinor.isAcceptableOrUnknown(
          data['credit_limit_minor']!,
          _creditLimitMinorMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit_scale')) {
      context.handle(
        _creditLimitScaleMeta,
        creditLimitScale.isAcceptableOrUnknown(
          data['credit_limit_scale']!,
          _creditLimitScaleMeta,
        ),
      );
    }
    if (data.containsKey('statement_day')) {
      context.handle(
        _statementDayMeta,
        statementDay.isAcceptableOrUnknown(
          data['statement_day']!,
          _statementDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statementDayMeta);
    }
    if (data.containsKey('payment_due_days')) {
      context.handle(
        _paymentDueDaysMeta,
        paymentDueDays.isAcceptableOrUnknown(
          data['payment_due_days']!,
          _paymentDueDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDueDaysMeta);
    }
    if (data.containsKey('interest_rate_annual')) {
      context.handle(
        _interestRateAnnualMeta,
        interestRateAnnual.isAcceptableOrUnknown(
          data['interest_rate_annual']!,
          _interestRateAnnualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestRateAnnualMeta);
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      )!,
      creditLimitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_limit_minor'],
      )!,
      creditLimitScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_scale'],
      )!,
      statementDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}statement_day'],
      )!,
      paymentDueDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_due_days'],
      )!,
      interestRateAnnual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate_annual'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CreditCardRow extends DataClass implements Insertable<CreditCardRow> {
  final String id;
  final String accountId;
  final double creditLimit;
  final String creditLimitMinor;
  final int creditLimitScale;
  final int statementDay;
  final int paymentDueDays;
  final double interestRateAnnual;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const CreditCardRow({
    required this.id,
    required this.accountId,
    required this.creditLimit,
    required this.creditLimitMinor,
    required this.creditLimitScale,
    required this.statementDay,
    required this.paymentDueDays,
    required this.interestRateAnnual,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['credit_limit_minor'] = Variable<String>(creditLimitMinor);
    map['credit_limit_scale'] = Variable<int>(creditLimitScale);
    map['statement_day'] = Variable<int>(statementDay);
    map['payment_due_days'] = Variable<int>(paymentDueDays);
    map['interest_rate_annual'] = Variable<double>(interestRateAnnual);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      creditLimit: Value(creditLimit),
      creditLimitMinor: Value(creditLimitMinor),
      creditLimitScale: Value(creditLimitScale),
      statementDay: Value(statementDay),
      paymentDueDays: Value(paymentDueDays),
      interestRateAnnual: Value(interestRateAnnual),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory CreditCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCardRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      creditLimitMinor: serializer.fromJson<String>(json['creditLimitMinor']),
      creditLimitScale: serializer.fromJson<int>(json['creditLimitScale']),
      statementDay: serializer.fromJson<int>(json['statementDay']),
      paymentDueDays: serializer.fromJson<int>(json['paymentDueDays']),
      interestRateAnnual: serializer.fromJson<double>(
        json['interestRateAnnual'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'creditLimitMinor': serializer.toJson<String>(creditLimitMinor),
      'creditLimitScale': serializer.toJson<int>(creditLimitScale),
      'statementDay': serializer.toJson<int>(statementDay),
      'paymentDueDays': serializer.toJson<int>(paymentDueDays),
      'interestRateAnnual': serializer.toJson<double>(interestRateAnnual),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CreditCardRow copyWith({
    String? id,
    String? accountId,
    double? creditLimit,
    String? creditLimitMinor,
    int? creditLimitScale,
    int? statementDay,
    int? paymentDueDays,
    double? interestRateAnnual,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => CreditCardRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    creditLimit: creditLimit ?? this.creditLimit,
    creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
    creditLimitScale: creditLimitScale ?? this.creditLimitScale,
    statementDay: statementDay ?? this.statementDay,
    paymentDueDays: paymentDueDays ?? this.paymentDueDays,
    interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  CreditCardRow copyWithCompanion(CreditCardsCompanion data) {
    return CreditCardRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      creditLimitMinor: data.creditLimitMinor.present
          ? data.creditLimitMinor.value
          : this.creditLimitMinor,
      creditLimitScale: data.creditLimitScale.present
          ? data.creditLimitScale.value
          : this.creditLimitScale,
      statementDay: data.statementDay.present
          ? data.statementDay.value
          : this.statementDay,
      paymentDueDays: data.paymentDueDays.present
          ? data.paymentDueDays.value
          : this.paymentDueDays,
      interestRateAnnual: data.interestRateAnnual.present
          ? data.interestRateAnnual.value
          : this.interestRateAnnual,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('creditLimitScale: $creditLimitScale, ')
          ..write('statementDay: $statementDay, ')
          ..write('paymentDueDays: $paymentDueDays, ')
          ..write('interestRateAnnual: $interestRateAnnual, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    creditLimit,
    creditLimitMinor,
    creditLimitScale,
    statementDay,
    paymentDueDays,
    interestRateAnnual,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCardRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.creditLimit == this.creditLimit &&
          other.creditLimitMinor == this.creditLimitMinor &&
          other.creditLimitScale == this.creditLimitScale &&
          other.statementDay == this.statementDay &&
          other.paymentDueDays == this.paymentDueDays &&
          other.interestRateAnnual == this.interestRateAnnual &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class CreditCardsCompanion extends UpdateCompanion<CreditCardRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<double> creditLimit;
  final Value<String> creditLimitMinor;
  final Value<int> creditLimitScale;
  final Value<int> statementDay;
  final Value<int> paymentDueDays;
  final Value<double> interestRateAnnual;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CreditCardsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.creditLimitScale = const Value.absent(),
    this.statementDay = const Value.absent(),
    this.paymentDueDays = const Value.absent(),
    this.interestRateAnnual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    required String id,
    required String accountId,
    required double creditLimit,
    this.creditLimitMinor = const Value.absent(),
    this.creditLimitScale = const Value.absent(),
    required int statementDay,
    required int paymentDueDays,
    required double interestRateAnnual,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       creditLimit = Value(creditLimit),
       statementDay = Value(statementDay),
       paymentDueDays = Value(paymentDueDays),
       interestRateAnnual = Value(interestRateAnnual);
  static Insertable<CreditCardRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<double>? creditLimit,
    Expression<String>? creditLimitMinor,
    Expression<int>? creditLimitScale,
    Expression<int>? statementDay,
    Expression<int>? paymentDueDays,
    Expression<double>? interestRateAnnual,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (creditLimitMinor != null) 'credit_limit_minor': creditLimitMinor,
      if (creditLimitScale != null) 'credit_limit_scale': creditLimitScale,
      if (statementDay != null) 'statement_day': statementDay,
      if (paymentDueDays != null) 'payment_due_days': paymentDueDays,
      if (interestRateAnnual != null)
        'interest_rate_annual': interestRateAnnual,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<double>? creditLimit,
    Value<String>? creditLimitMinor,
    Value<int>? creditLimitScale,
    Value<int>? statementDay,
    Value<int>? paymentDueDays,
    Value<double>? interestRateAnnual,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CreditCardsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      creditLimit: creditLimit ?? this.creditLimit,
      creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
      creditLimitScale: creditLimitScale ?? this.creditLimitScale,
      statementDay: statementDay ?? this.statementDay,
      paymentDueDays: paymentDueDays ?? this.paymentDueDays,
      interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (creditLimitMinor.present) {
      map['credit_limit_minor'] = Variable<String>(creditLimitMinor.value);
    }
    if (creditLimitScale.present) {
      map['credit_limit_scale'] = Variable<int>(creditLimitScale.value);
    }
    if (statementDay.present) {
      map['statement_day'] = Variable<int>(statementDay.value);
    }
    if (paymentDueDays.present) {
      map['payment_due_days'] = Variable<int>(paymentDueDays.value);
    }
    if (interestRateAnnual.present) {
      map['interest_rate_annual'] = Variable<double>(interestRateAnnual.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('creditLimitScale: $creditLimitScale, ')
          ..write('statementDay: $statementDay, ')
          ..write('paymentDueDays: $paymentDueDays, ')
          ..write('interestRateAnnual: $interestRateAnnual, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $SavingGoalsTable savingGoals = $SavingGoalsTable(this);
  late final $CreditsTable credits = $CreditsTable(this);
  late final $CreditPaymentSchedulesTable creditPaymentSchedules =
      $CreditPaymentSchedulesTable(this);
  late final $CreditPaymentGroupsTable creditPaymentGroups =
      $CreditPaymentGroupsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $BudgetInstancesTable budgetInstances = $BudgetInstancesTable(
    this,
  );
  late final $GoalContributionsTable goalContributions =
      $GoalContributionsTable(this);
  late final $UpcomingPaymentsTable upcomingPayments = $UpcomingPaymentsTable(
    this,
  );
  late final $PaymentRemindersTable paymentReminders = $PaymentRemindersTable(
    this,
  );
  late final $DebtsTable debts = $DebtsTable(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    tags,
    savingGoals,
    credits,
    creditPaymentSchedules,
    creditPaymentGroups,
    transactions,
    transactionTags,
    outboxEntries,
    profiles,
    budgets,
    budgetInstances,
    goalContributions,
    upcomingPayments,
    paymentReminders,
    debts,
    creditCards,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('credit_payment_schedules', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credit_payment_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credit_payment_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credit_payment_schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credit_payment_groups', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'saving_goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credit_payment_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'budgets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_instances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'saving_goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('goal_contributions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('goal_contributions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('upcoming_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('upcoming_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('debts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credit_cards', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String name,
      required double balance,
      Value<String> balanceMinor,
      Value<double> openingBalance,
      Value<String> openingBalanceMinor,
      required String currency,
      Value<int> currencyScale,
      required String type,
      Value<String?> color,
      Value<String?> gradientId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isPrimary,
      Value<bool> isHidden,
      Value<String?> iconName,
      Value<String?> iconStyle,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> balance,
      Value<String> balanceMinor,
      Value<double> openingBalance,
      Value<String> openingBalanceMinor,
      Value<String> currency,
      Value<int> currencyScale,
      Value<String> type,
      Value<String?> color,
      Value<String?> gradientId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isPrimary,
      Value<bool> isHidden,
      Value<String?> iconName,
      Value<String?> iconStyle,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CreditsTable, List<CreditRow>>
  _creditAccountTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.credits,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.credits.accountId),
  );

  $$CreditsTableProcessedTableManager get creditAccount {
    final manager = $$CreditsTableTableManager(
      $_db,
      $_db.credits,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_creditAccountTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CreditsTable, List<CreditRow>>
  _creditTargetAccountTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.credits,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.credits.targetAccountId),
  );

  $$CreditsTableProcessedTableManager get creditTargetAccount {
    final manager = $$CreditsTableTableManager($_db, $_db.credits).filter(
      (f) => f.targetAccountId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _creditTargetAccountTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CreditPaymentGroupsTable,
    List<CreditPaymentGroupRow>
  >
  _creditPaymentSourceAccountTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.creditPaymentGroups,
        aliasName: $_aliasNameGenerator(
          db.accounts.id,
          db.creditPaymentGroups.sourceAccountId,
        ),
      );

  $$CreditPaymentGroupsTableProcessedTableManager
  get creditPaymentSourceAccount {
    final manager =
        $$CreditPaymentGroupsTableTableManager(
          $_db,
          $_db.creditPaymentGroups,
        ).filter(
          (f) => f.sourceAccountId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _creditPaymentSourceAccountTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsAccountTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.transactions.accountId),
  );

  $$TransactionsTableProcessedTableManager get transactionsAccount {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionsAccountTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsTransferAccountTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactions,
        aliasName: $_aliasNameGenerator(
          db.accounts.id,
          db.transactions.transferAccountId,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionsTransferAccount {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
          (f) => f.transferAccountId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _transactionsTransferAccountTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UpcomingPaymentsTable, List<UpcomingPaymentRow>>
  _upcomingPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.upcomingPayments,
    aliasName: $_aliasNameGenerator(
      db.accounts.id,
      db.upcomingPayments.accountId,
    ),
  );

  $$UpcomingPaymentsTableProcessedTableManager get upcomingPaymentsRefs {
    final manager = $$UpcomingPaymentsTableTableManager(
      $_db,
      $_db.upcomingPayments,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _upcomingPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DebtsTable, List<DebtRow>> _debtAccountTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.debts,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.debts.accountId),
  );

  $$DebtsTableProcessedTableManager get debtAccount {
    final manager = $$DebtsTableTableManager(
      $_db,
      $_db.debts,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtAccountTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CreditCardsTable, List<CreditCardRow>>
  _creditCardAccountTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.creditCards,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.creditCards.accountId),
  );

  $$CreditCardsTableProcessedTableManager get creditCardAccount {
    final manager = $$CreditCardsTableTableManager(
      $_db,
      $_db.creditCards,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_creditCardAccountTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradientId => $composableBuilder(
    column: $table.gradientId,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconStyle => $composableBuilder(
    column: $table.iconStyle,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> creditAccount(
    Expression<bool> Function($$CreditsTableFilterComposer f) f,
  ) {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditTargetAccount(
    Expression<bool> Function($$CreditsTableFilterComposer f) f,
  ) {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.targetAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditPaymentSourceAccount(
    Expression<bool> Function($$CreditPaymentGroupsTableFilterComposer f) f,
  ) {
    final $$CreditPaymentGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditPaymentGroups,
      getReferencedColumn: (t) => t.sourceAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditPaymentGroupsTableFilterComposer(
            $db: $db,
            $table: $db.creditPaymentGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsAccount(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
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

  Expression<bool> transactionsTransferAccount(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.transferAccountId,
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

  Expression<bool> upcomingPaymentsRefs(
    Expression<bool> Function($$UpcomingPaymentsTableFilterComposer f) f,
  ) {
    final $$UpcomingPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upcomingPayments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpcomingPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.upcomingPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> debtAccount(
    Expression<bool> Function($$DebtsTableFilterComposer f) f,
  ) {
    final $$DebtsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableFilterComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditCardAccount(
    Expression<bool> Function($$CreditCardsTableFilterComposer f) f,
  ) {
    final $$CreditCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditCards,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditCardsTableFilterComposer(
            $db: $db,
            $table: $db.creditCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradientId => $composableBuilder(
    column: $table.gradientId,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconStyle => $composableBuilder(
    column: $table.iconStyle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get gradientId => $composableBuilder(
    column: $table.gradientId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get iconStyle =>
      $composableBuilder(column: $table.iconStyle, builder: (column) => column);

  Expression<T> creditAccount<T extends Object>(
    Expression<T> Function($$CreditsTableAnnotationComposer a) f,
  ) {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditTargetAccount<T extends Object>(
    Expression<T> Function($$CreditsTableAnnotationComposer a) f,
  ) {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.targetAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditPaymentSourceAccount<T extends Object>(
    Expression<T> Function($$CreditPaymentGroupsTableAnnotationComposer a) f,
  ) {
    final $$CreditPaymentGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditPaymentGroups,
          getReferencedColumn: (t) => t.sourceAccountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionsAccount<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
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

  Expression<T> transactionsTransferAccount<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.transferAccountId,
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

  Expression<T> upcomingPaymentsRefs<T extends Object>(
    Expression<T> Function($$UpcomingPaymentsTableAnnotationComposer a) f,
  ) {
    final $$UpcomingPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upcomingPayments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpcomingPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.upcomingPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> debtAccount<T extends Object>(
    Expression<T> Function($$DebtsTableAnnotationComposer a) f,
  ) {
    final $$DebtsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableAnnotationComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditCardAccount<T extends Object>(
    Expression<T> Function($$CreditCardsTableAnnotationComposer a) f,
  ) {
    final $$CreditCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditCards,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.creditCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool creditAccount,
            bool creditTargetAccount,
            bool creditPaymentSourceAccount,
            bool transactionsAccount,
            bool transactionsTransferAccount,
            bool upcomingPaymentsRefs,
            bool debtAccount,
            bool creditCardAccount,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> balanceMinor = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String> openingBalanceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> currencyScale = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> gradientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> iconStyle = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                balance: balance,
                balanceMinor: balanceMinor,
                openingBalance: openingBalance,
                openingBalanceMinor: openingBalanceMinor,
                currency: currency,
                currencyScale: currencyScale,
                type: type,
                color: color,
                gradientId: gradientId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isPrimary: isPrimary,
                isHidden: isHidden,
                iconName: iconName,
                iconStyle: iconStyle,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double balance,
                Value<String> balanceMinor = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<String> openingBalanceMinor = const Value.absent(),
                required String currency,
                Value<int> currencyScale = const Value.absent(),
                required String type,
                Value<String?> color = const Value.absent(),
                Value<String?> gradientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> iconStyle = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                balance: balance,
                balanceMinor: balanceMinor,
                openingBalance: openingBalance,
                openingBalanceMinor: openingBalanceMinor,
                currency: currency,
                currencyScale: currencyScale,
                type: type,
                color: color,
                gradientId: gradientId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isPrimary: isPrimary,
                isHidden: isHidden,
                iconName: iconName,
                iconStyle: iconStyle,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creditAccount = false,
                creditTargetAccount = false,
                creditPaymentSourceAccount = false,
                transactionsAccount = false,
                transactionsTransferAccount = false,
                upcomingPaymentsRefs = false,
                debtAccount = false,
                creditCardAccount = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (creditAccount) db.credits,
                    if (creditTargetAccount) db.credits,
                    if (creditPaymentSourceAccount) db.creditPaymentGroups,
                    if (transactionsAccount) db.transactions,
                    if (transactionsTransferAccount) db.transactions,
                    if (upcomingPaymentsRefs) db.upcomingPayments,
                    if (debtAccount) db.debts,
                    if (creditCardAccount) db.creditCards,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (creditAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          CreditRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._creditAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditTargetAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          CreditRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._creditTargetAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditTargetAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditPaymentSourceAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          CreditPaymentGroupRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._creditPaymentSourceAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditPaymentSourceAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsTransferAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsTransferAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsTransferAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transferAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (upcomingPaymentsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          UpcomingPaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._upcomingPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).upcomingPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (debtAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          DebtRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._debtAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).debtAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditCardAccount)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          CreditCardRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._creditCardAccountTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditCardAccount,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
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

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool creditAccount,
        bool creditTargetAccount,
        bool creditPaymentSourceAccount,
        bool transactionsAccount,
        bool transactionsTransferAccount,
        bool upcomingPaymentsRefs,
        bool debtAccount,
        bool creditCardAccount,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> icon,
      Value<String?> iconStyle,
      Value<String?> iconName,
      Value<String?> color,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSystem,
      Value<bool> isHidden,
      Value<bool> isFavorite,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> icon,
      Value<String?> iconStyle,
      Value<String?> iconName,
      Value<String?> color,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSystem,
      Value<bool> isHidden,
      Value<bool> isFavorite,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CreditsTable, List<CreditRow>>
  _creditCategoryTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.credits,
    aliasName: $_aliasNameGenerator(db.categories.id, db.credits.categoryId),
  );

  $$CreditsTableProcessedTableManager get creditCategory {
    final manager = $$CreditsTableTableManager(
      $_db,
      $_db.credits,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_creditCategoryTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CreditsTable, List<CreditRow>>
  _creditInterestCategoryTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.credits,
        aliasName: $_aliasNameGenerator(
          db.categories.id,
          db.credits.interestCategoryId,
        ),
      );

  $$CreditsTableProcessedTableManager get creditInterestCategory {
    final manager = $$CreditsTableTableManager($_db, $_db.credits).filter(
      (f) => f.interestCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _creditInterestCategoryTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CreditsTable, List<CreditRow>>
  _creditFeesCategoryTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.credits,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.credits.feesCategoryId,
    ),
  );

  $$CreditsTableProcessedTableManager get creditFeesCategory {
    final manager = $$CreditsTableTableManager(
      $_db,
      $_db.credits,
    ).filter((f) => f.feesCategoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_creditFeesCategoryTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsCategoryTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsCategory {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionsCategoryTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UpcomingPaymentsTable, List<UpcomingPaymentRow>>
  _upcomingPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.upcomingPayments,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.upcomingPayments.categoryId,
    ),
  );

  $$UpcomingPaymentsTableProcessedTableManager get upcomingPaymentsRefs {
    final manager = $$UpcomingPaymentsTableTableManager(
      $_db,
      $_db.upcomingPayments,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _upcomingPaymentsRefsTable($_db),
    );
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
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconStyle => $composableBuilder(
    column: $table.iconStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> creditCategory(
    Expression<bool> Function($$CreditsTableFilterComposer f) f,
  ) {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditInterestCategory(
    Expression<bool> Function($$CreditsTableFilterComposer f) f,
  ) {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.interestCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> creditFeesCategory(
    Expression<bool> Function($$CreditsTableFilterComposer f) f,
  ) {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.feesCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsCategory(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
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

  Expression<bool> upcomingPaymentsRefs(
    Expression<bool> Function($$UpcomingPaymentsTableFilterComposer f) f,
  ) {
    final $$UpcomingPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upcomingPayments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpcomingPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.upcomingPayments,
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
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconStyle => $composableBuilder(
    column: $table.iconStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get iconStyle =>
      $composableBuilder(column: $table.iconStyle, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  Expression<T> creditCategory<T extends Object>(
    Expression<T> Function($$CreditsTableAnnotationComposer a) f,
  ) {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditInterestCategory<T extends Object>(
    Expression<T> Function($$CreditsTableAnnotationComposer a) f,
  ) {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.interestCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> creditFeesCategory<T extends Object>(
    Expression<T> Function($$CreditsTableAnnotationComposer a) f,
  ) {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.feesCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsCategory<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
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

  Expression<T> upcomingPaymentsRefs<T extends Object>(
    Expression<T> Function($$UpcomingPaymentsTableAnnotationComposer a) f,
  ) {
    final $$UpcomingPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upcomingPayments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpcomingPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.upcomingPayments,
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
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool creditCategory,
            bool creditInterestCategory,
            bool creditFeesCategory,
            bool transactionsCategory,
            bool upcomingPaymentsRefs,
          })
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> iconStyle = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                icon: icon,
                iconStyle: iconStyle,
                iconName: iconName,
                color: color,
                parentId: parentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSystem: isSystem,
                isHidden: isHidden,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> icon = const Value.absent(),
                Value<String?> iconStyle = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                icon: icon,
                iconStyle: iconStyle,
                iconName: iconName,
                color: color,
                parentId: parentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSystem: isSystem,
                isHidden: isHidden,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creditCategory = false,
                creditInterestCategory = false,
                creditFeesCategory = false,
                transactionsCategory = false,
                upcomingPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (creditCategory) db.credits,
                    if (creditInterestCategory) db.credits,
                    if (creditFeesCategory) db.credits,
                    if (transactionsCategory) db.transactions,
                    if (upcomingPaymentsRefs) db.upcomingPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (creditCategory)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CreditRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._creditCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditInterestCategory)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CreditRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._creditInterestCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditInterestCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.interestCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditFeesCategory)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CreditRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._creditFeesCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditFeesCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.feesCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsCategory)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (upcomingPaymentsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          UpcomingPaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._upcomingPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).upcomingPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool creditCategory,
        bool creditInterestCategory,
        bool creditFeesCategory,
        bool transactionsCategory,
        bool upcomingPaymentsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTagRow>>
  _transactionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.transactionTags.tagId),
  );

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager = $$TransactionTagsTableTableManager(
      $_db,
      $_db.transactionTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionTagsRefs(
    Expression<bool> Function($$TransactionTagsTableFilterComposer f) f,
  ) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableFilterComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> transactionTagsRefs<T extends Object>(
    Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f,
  ) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool transactionTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String color,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({transactionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionTagsRefs) db.transactionTags,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionTagsRefs)
                    await $_getPrefetchedData<
                      TagRow,
                      $TagsTable,
                      TransactionTagRow
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._transactionTagsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TagsTableReferences(
                        db,
                        table,
                        p0,
                      ).transactionTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool transactionTagsRefs})
    >;
typedef $$SavingGoalsTableCreateCompanionBuilder =
    SavingGoalsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required int targetAmount,
      Value<int> currentAmount,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$SavingGoalsTableUpdateCompanionBuilder =
    SavingGoalsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<int> targetAmount,
      Value<int> currentAmount,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$SavingGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $SavingGoalsTable, SavingGoalRow> {
  $$SavingGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.savingGoals.id,
      db.transactions.savingGoalId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.savingGoalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalContributionsTable, List<GoalContributionRow>>
  _goalContributionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.goalContributions,
        aliasName: $_aliasNameGenerator(
          db.savingGoals.id,
          db.goalContributions.goalId,
        ),
      );

  $$GoalContributionsTableProcessedTableManager get goalContributionsRefs {
    final manager = $$GoalContributionsTableTableManager(
      $_db,
      $_db.goalContributions,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _goalContributionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavingGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.savingGoalId,
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

  Expression<bool> goalContributionsRefs(
    Expression<bool> Function($$GoalContributionsTableFilterComposer f) f,
  ) {
    final $$GoalContributionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalContributions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalContributionsTableFilterComposer(
            $db: $db,
            $table: $db.goalContributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavingGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.savingGoalId,
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

  Expression<T> goalContributionsRefs<T extends Object>(
    Expression<T> Function($$GoalContributionsTableAnnotationComposer a) f,
  ) {
    final $$GoalContributionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.goalContributions,
          getReferencedColumn: (t) => t.goalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GoalContributionsTableAnnotationComposer(
                $db: $db,
                $table: $db.goalContributions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavingGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingGoalsTable,
          SavingGoalRow,
          $$SavingGoalsTableFilterComposer,
          $$SavingGoalsTableOrderingComposer,
          $$SavingGoalsTableAnnotationComposer,
          $$SavingGoalsTableCreateCompanionBuilder,
          $$SavingGoalsTableUpdateCompanionBuilder,
          (SavingGoalRow, $$SavingGoalsTableReferences),
          SavingGoalRow,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool goalContributionsRefs,
          })
        > {
  $$SavingGoalsTableTableManager(_$AppDatabase db, $SavingGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<int> currentAmount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingGoalsCompanion(
                id: id,
                userId: userId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required int targetAmount,
                Value<int> currentAmount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingGoalsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transactionsRefs = false, goalContributionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (goalContributionsRefs) db.goalContributions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          SavingGoalRow,
                          $SavingGoalsTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavingGoalsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingGoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savingGoalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalContributionsRefs)
                        await $_getPrefetchedData<
                          SavingGoalRow,
                          $SavingGoalsTable,
                          GoalContributionRow
                        >(
                          currentTable: table,
                          referencedTable: $$SavingGoalsTableReferences
                              ._goalContributionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingGoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalContributionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.goalId == item.id,
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

typedef $$SavingGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingGoalsTable,
      SavingGoalRow,
      $$SavingGoalsTableFilterComposer,
      $$SavingGoalsTableOrderingComposer,
      $$SavingGoalsTableAnnotationComposer,
      $$SavingGoalsTableCreateCompanionBuilder,
      $$SavingGoalsTableUpdateCompanionBuilder,
      (SavingGoalRow, $$SavingGoalsTableReferences),
      SavingGoalRow,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool goalContributionsRefs,
      })
    >;
typedef $$CreditsTableCreateCompanionBuilder =
    CreditsCompanion Function({
      required String id,
      required String accountId,
      Value<String?> categoryId,
      required double totalAmount,
      Value<String> totalAmountMinor,
      Value<int> totalAmountScale,
      required double interestRate,
      required int termMonths,
      required DateTime startDate,
      Value<int> paymentDay,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<DateTime?> issueDate,
      Value<double?> issueAmount,
      Value<String> issueAmountMinor,
      Value<int> issueAmountScale,
      Value<String?> targetAccountId,
      Value<String?> interestCategoryId,
      Value<String?> feesCategoryId,
      Value<DateTime?> firstPaymentDate,
      Value<int> rowid,
    });
typedef $$CreditsTableUpdateCompanionBuilder =
    CreditsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String?> categoryId,
      Value<double> totalAmount,
      Value<String> totalAmountMinor,
      Value<int> totalAmountScale,
      Value<double> interestRate,
      Value<int> termMonths,
      Value<DateTime> startDate,
      Value<int> paymentDay,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<DateTime?> issueDate,
      Value<double?> issueAmount,
      Value<String> issueAmountMinor,
      Value<int> issueAmountScale,
      Value<String?> targetAccountId,
      Value<String?> interestCategoryId,
      Value<String?> feesCategoryId,
      Value<DateTime?> firstPaymentDate,
      Value<int> rowid,
    });

final class $$CreditsTableReferences
    extends BaseReferences<_$AppDatabase, $CreditsTable, CreditRow> {
  $$CreditsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.credits.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.credits.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
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

  static $AccountsTable _targetAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.credits.targetAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get targetAccountId {
    final $_column = $_itemColumn<String>('target_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _interestCategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.credits.interestCategoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get interestCategoryId {
    final $_column = $_itemColumn<String>('interest_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_interestCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _feesCategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.credits.feesCategoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get feesCategoryId {
    final $_column = $_itemColumn<String>('fees_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feesCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CreditPaymentSchedulesTable,
    List<CreditPaymentScheduleRow>
  >
  _creditPaymentSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.creditPaymentSchedules,
        aliasName: $_aliasNameGenerator(
          db.credits.id,
          db.creditPaymentSchedules.creditId,
        ),
      );

  $$CreditPaymentSchedulesTableProcessedTableManager
  get creditPaymentSchedulesRefs {
    final manager = $$CreditPaymentSchedulesTableTableManager(
      $_db,
      $_db.creditPaymentSchedules,
    ).filter((f) => f.creditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _creditPaymentSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CreditPaymentGroupsTable,
    List<CreditPaymentGroupRow>
  >
  _creditPaymentGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.creditPaymentGroups,
        aliasName: $_aliasNameGenerator(
          db.credits.id,
          db.creditPaymentGroups.creditId,
        ),
      );

  $$CreditPaymentGroupsTableProcessedTableManager get creditPaymentGroupsRefs {
    final manager = $$CreditPaymentGroupsTableTableManager(
      $_db,
      $_db.creditPaymentGroups,
    ).filter((f) => f.creditId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _creditPaymentGroupsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CreditsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditsTable> {
  $$CreditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountScale => $composableBuilder(
    column: $table.totalAmountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get termMonths => $composableBuilder(
    column: $table.termMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get issueAmount => $composableBuilder(
    column: $table.issueAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueAmountMinor => $composableBuilder(
    column: $table.issueAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issueAmountScale => $composableBuilder(
    column: $table.issueAmountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$AccountsTableFilterComposer get targetAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get interestCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interestCategoryId,
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

  $$CategoriesTableFilterComposer get feesCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feesCategoryId,
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

  Expression<bool> creditPaymentSchedulesRefs(
    Expression<bool> Function($$CreditPaymentSchedulesTableFilterComposer f) f,
  ) {
    final $$CreditPaymentSchedulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditPaymentSchedules,
          getReferencedColumn: (t) => t.creditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentSchedulesTableFilterComposer(
                $db: $db,
                $table: $db.creditPaymentSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> creditPaymentGroupsRefs(
    Expression<bool> Function($$CreditPaymentGroupsTableFilterComposer f) f,
  ) {
    final $$CreditPaymentGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditPaymentGroups,
      getReferencedColumn: (t) => t.creditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditPaymentGroupsTableFilterComposer(
            $db: $db,
            $table: $db.creditPaymentGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CreditsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditsTable> {
  $$CreditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountScale => $composableBuilder(
    column: $table.totalAmountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get termMonths => $composableBuilder(
    column: $table.termMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get issueAmount => $composableBuilder(
    column: $table.issueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueAmountMinor => $composableBuilder(
    column: $table.issueAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issueAmountScale => $composableBuilder(
    column: $table.issueAmountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$AccountsTableOrderingComposer get targetAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get interestCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interestCategoryId,
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

  $$CategoriesTableOrderingComposer get feesCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feesCategoryId,
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

class $$CreditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditsTable> {
  $$CreditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmountScale => $composableBuilder(
    column: $table.totalAmountScale,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get termMonths => $composableBuilder(
    column: $table.termMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<double> get issueAmount => $composableBuilder(
    column: $table.issueAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issueAmountMinor => $composableBuilder(
    column: $table.issueAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get issueAmountScale => $composableBuilder(
    column: $table.issueAmountScale,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$AccountsTableAnnotationComposer get targetAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get interestCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interestCategoryId,
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

  $$CategoriesTableAnnotationComposer get feesCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feesCategoryId,
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

  Expression<T> creditPaymentSchedulesRefs<T extends Object>(
    Expression<T> Function($$CreditPaymentSchedulesTableAnnotationComposer a) f,
  ) {
    final $$CreditPaymentSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditPaymentSchedules,
          getReferencedColumn: (t) => t.creditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> creditPaymentGroupsRefs<T extends Object>(
    Expression<T> Function($$CreditPaymentGroupsTableAnnotationComposer a) f,
  ) {
    final $$CreditPaymentGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditPaymentGroups,
          getReferencedColumn: (t) => t.creditId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CreditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditsTable,
          CreditRow,
          $$CreditsTableFilterComposer,
          $$CreditsTableOrderingComposer,
          $$CreditsTableAnnotationComposer,
          $$CreditsTableCreateCompanionBuilder,
          $$CreditsTableUpdateCompanionBuilder,
          (CreditRow, $$CreditsTableReferences),
          CreditRow,
          PrefetchHooks Function({
            bool accountId,
            bool categoryId,
            bool targetAccountId,
            bool interestCategoryId,
            bool feesCategoryId,
            bool creditPaymentSchedulesRefs,
            bool creditPaymentGroupsRefs,
          })
        > {
  $$CreditsTableTableManager(_$AppDatabase db, $CreditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> totalAmountMinor = const Value.absent(),
                Value<int> totalAmountScale = const Value.absent(),
                Value<double> interestRate = const Value.absent(),
                Value<int> termMonths = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> paymentDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> issueDate = const Value.absent(),
                Value<double?> issueAmount = const Value.absent(),
                Value<String> issueAmountMinor = const Value.absent(),
                Value<int> issueAmountScale = const Value.absent(),
                Value<String?> targetAccountId = const Value.absent(),
                Value<String?> interestCategoryId = const Value.absent(),
                Value<String?> feesCategoryId = const Value.absent(),
                Value<DateTime?> firstPaymentDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditsCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                totalAmount: totalAmount,
                totalAmountMinor: totalAmountMinor,
                totalAmountScale: totalAmountScale,
                interestRate: interestRate,
                termMonths: termMonths,
                startDate: startDate,
                paymentDay: paymentDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                issueDate: issueDate,
                issueAmount: issueAmount,
                issueAmountMinor: issueAmountMinor,
                issueAmountScale: issueAmountScale,
                targetAccountId: targetAccountId,
                interestCategoryId: interestCategoryId,
                feesCategoryId: feesCategoryId,
                firstPaymentDate: firstPaymentDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                Value<String?> categoryId = const Value.absent(),
                required double totalAmount,
                Value<String> totalAmountMinor = const Value.absent(),
                Value<int> totalAmountScale = const Value.absent(),
                required double interestRate,
                required int termMonths,
                required DateTime startDate,
                Value<int> paymentDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime?> issueDate = const Value.absent(),
                Value<double?> issueAmount = const Value.absent(),
                Value<String> issueAmountMinor = const Value.absent(),
                Value<int> issueAmountScale = const Value.absent(),
                Value<String?> targetAccountId = const Value.absent(),
                Value<String?> interestCategoryId = const Value.absent(),
                Value<String?> feesCategoryId = const Value.absent(),
                Value<DateTime?> firstPaymentDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditsCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                totalAmount: totalAmount,
                totalAmountMinor: totalAmountMinor,
                totalAmountScale: totalAmountScale,
                interestRate: interestRate,
                termMonths: termMonths,
                startDate: startDate,
                paymentDay: paymentDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                issueDate: issueDate,
                issueAmount: issueAmount,
                issueAmountMinor: issueAmountMinor,
                issueAmountScale: issueAmountScale,
                targetAccountId: targetAccountId,
                interestCategoryId: interestCategoryId,
                feesCategoryId: feesCategoryId,
                firstPaymentDate: firstPaymentDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                categoryId = false,
                targetAccountId = false,
                interestCategoryId = false,
                feesCategoryId = false,
                creditPaymentSchedulesRefs = false,
                creditPaymentGroupsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (creditPaymentSchedulesRefs) db.creditPaymentSchedules,
                    if (creditPaymentGroupsRefs) db.creditPaymentGroups,
                  ],
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable: $$CreditsTableReferences
                                        ._accountIdTable(db),
                                    referencedColumn: $$CreditsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$CreditsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$CreditsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (targetAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetAccountId,
                                    referencedTable: $$CreditsTableReferences
                                        ._targetAccountIdTable(db),
                                    referencedColumn: $$CreditsTableReferences
                                        ._targetAccountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (interestCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.interestCategoryId,
                                    referencedTable: $$CreditsTableReferences
                                        ._interestCategoryIdTable(db),
                                    referencedColumn: $$CreditsTableReferences
                                        ._interestCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (feesCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.feesCategoryId,
                                    referencedTable: $$CreditsTableReferences
                                        ._feesCategoryIdTable(db),
                                    referencedColumn: $$CreditsTableReferences
                                        ._feesCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (creditPaymentSchedulesRefs)
                        await $_getPrefetchedData<
                          CreditRow,
                          $CreditsTable,
                          CreditPaymentScheduleRow
                        >(
                          currentTable: table,
                          referencedTable: $$CreditsTableReferences
                              ._creditPaymentSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CreditsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditPaymentSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.creditId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (creditPaymentGroupsRefs)
                        await $_getPrefetchedData<
                          CreditRow,
                          $CreditsTable,
                          CreditPaymentGroupRow
                        >(
                          currentTable: table,
                          referencedTable: $$CreditsTableReferences
                              ._creditPaymentGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CreditsTableReferences(
                                db,
                                table,
                                p0,
                              ).creditPaymentGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.creditId == item.id,
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

typedef $$CreditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditsTable,
      CreditRow,
      $$CreditsTableFilterComposer,
      $$CreditsTableOrderingComposer,
      $$CreditsTableAnnotationComposer,
      $$CreditsTableCreateCompanionBuilder,
      $$CreditsTableUpdateCompanionBuilder,
      (CreditRow, $$CreditsTableReferences),
      CreditRow,
      PrefetchHooks Function({
        bool accountId,
        bool categoryId,
        bool targetAccountId,
        bool interestCategoryId,
        bool feesCategoryId,
        bool creditPaymentSchedulesRefs,
        bool creditPaymentGroupsRefs,
      })
    >;
typedef $$CreditPaymentSchedulesTableCreateCompanionBuilder =
    CreditPaymentSchedulesCompanion Function({
      required String id,
      required String creditId,
      required String periodKey,
      required DateTime dueDate,
      required String status,
      required String principalAmountMinor,
      required String interestAmountMinor,
      required String totalAmountMinor,
      Value<int> amountScale,
      Value<String> principalPaidMinor,
      Value<String> interestPaidMinor,
      Value<DateTime?> paidAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CreditPaymentSchedulesTableUpdateCompanionBuilder =
    CreditPaymentSchedulesCompanion Function({
      Value<String> id,
      Value<String> creditId,
      Value<String> periodKey,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<String> principalAmountMinor,
      Value<String> interestAmountMinor,
      Value<String> totalAmountMinor,
      Value<int> amountScale,
      Value<String> principalPaidMinor,
      Value<String> interestPaidMinor,
      Value<DateTime?> paidAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CreditPaymentSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CreditPaymentSchedulesTable,
          CreditPaymentScheduleRow
        > {
  $$CreditPaymentSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CreditsTable _creditIdTable(_$AppDatabase db) =>
      db.credits.createAlias(
        $_aliasNameGenerator(db.creditPaymentSchedules.creditId, db.credits.id),
      );

  $$CreditsTableProcessedTableManager get creditId {
    final $_column = $_itemColumn<String>('credit_id')!;

    final manager = $$CreditsTableTableManager(
      $_db,
      $_db.credits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CreditPaymentGroupsTable,
    List<CreditPaymentGroupRow>
  >
  _creditPaymentGroupsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.creditPaymentGroups,
        aliasName: $_aliasNameGenerator(
          db.creditPaymentSchedules.id,
          db.creditPaymentGroups.scheduleItemId,
        ),
      );

  $$CreditPaymentGroupsTableProcessedTableManager get creditPaymentGroupsRefs {
    final manager = $$CreditPaymentGroupsTableTableManager(
      $_db,
      $_db.creditPaymentGroups,
    ).filter((f) => f.scheduleItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _creditPaymentGroupsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CreditPaymentSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $CreditPaymentSchedulesTable> {
  $$CreditPaymentSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get principalAmountMinor => $composableBuilder(
    column: $table.principalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestAmountMinor => $composableBuilder(
    column: $table.interestAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
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

  $$CreditsTableFilterComposer get creditId {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> creditPaymentGroupsRefs(
    Expression<bool> Function($$CreditPaymentGroupsTableFilterComposer f) f,
  ) {
    final $$CreditPaymentGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.creditPaymentGroups,
      getReferencedColumn: (t) => t.scheduleItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditPaymentGroupsTableFilterComposer(
            $db: $db,
            $table: $db.creditPaymentGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CreditPaymentSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditPaymentSchedulesTable> {
  $$CreditPaymentSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get principalAmountMinor => $composableBuilder(
    column: $table.principalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestAmountMinor => $composableBuilder(
    column: $table.interestAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
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

  $$CreditsTableOrderingComposer get creditId {
    final $$CreditsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableOrderingComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditPaymentSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditPaymentSchedulesTable> {
  $$CreditPaymentSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get principalAmountMinor => $composableBuilder(
    column: $table.principalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestAmountMinor => $composableBuilder(
    column: $table.interestAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CreditsTableAnnotationComposer get creditId {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> creditPaymentGroupsRefs<T extends Object>(
    Expression<T> Function($$CreditPaymentGroupsTableAnnotationComposer a) f,
  ) {
    final $$CreditPaymentGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.creditPaymentGroups,
          getReferencedColumn: (t) => t.scheduleItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CreditPaymentSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditPaymentSchedulesTable,
          CreditPaymentScheduleRow,
          $$CreditPaymentSchedulesTableFilterComposer,
          $$CreditPaymentSchedulesTableOrderingComposer,
          $$CreditPaymentSchedulesTableAnnotationComposer,
          $$CreditPaymentSchedulesTableCreateCompanionBuilder,
          $$CreditPaymentSchedulesTableUpdateCompanionBuilder,
          (CreditPaymentScheduleRow, $$CreditPaymentSchedulesTableReferences),
          CreditPaymentScheduleRow,
          PrefetchHooks Function({bool creditId, bool creditPaymentGroupsRefs})
        > {
  $$CreditPaymentSchedulesTableTableManager(
    _$AppDatabase db,
    $CreditPaymentSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditPaymentSchedulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CreditPaymentSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CreditPaymentSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> creditId = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> principalAmountMinor = const Value.absent(),
                Value<String> interestAmountMinor = const Value.absent(),
                Value<String> totalAmountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<String> principalPaidMinor = const Value.absent(),
                Value<String> interestPaidMinor = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditPaymentSchedulesCompanion(
                id: id,
                creditId: creditId,
                periodKey: periodKey,
                dueDate: dueDate,
                status: status,
                principalAmountMinor: principalAmountMinor,
                interestAmountMinor: interestAmountMinor,
                totalAmountMinor: totalAmountMinor,
                amountScale: amountScale,
                principalPaidMinor: principalPaidMinor,
                interestPaidMinor: interestPaidMinor,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String creditId,
                required String periodKey,
                required DateTime dueDate,
                required String status,
                required String principalAmountMinor,
                required String interestAmountMinor,
                required String totalAmountMinor,
                Value<int> amountScale = const Value.absent(),
                Value<String> principalPaidMinor = const Value.absent(),
                Value<String> interestPaidMinor = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditPaymentSchedulesCompanion.insert(
                id: id,
                creditId: creditId,
                periodKey: periodKey,
                dueDate: dueDate,
                status: status,
                principalAmountMinor: principalAmountMinor,
                interestAmountMinor: interestAmountMinor,
                totalAmountMinor: totalAmountMinor,
                amountScale: amountScale,
                principalPaidMinor: principalPaidMinor,
                interestPaidMinor: interestPaidMinor,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditPaymentSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({creditId = false, creditPaymentGroupsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (creditPaymentGroupsRefs) db.creditPaymentGroups,
                  ],
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
                        if (creditId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.creditId,
                                    referencedTable:
                                        $$CreditPaymentSchedulesTableReferences
                                            ._creditIdTable(db),
                                    referencedColumn:
                                        $$CreditPaymentSchedulesTableReferences
                                            ._creditIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (creditPaymentGroupsRefs)
                        await $_getPrefetchedData<
                          CreditPaymentScheduleRow,
                          $CreditPaymentSchedulesTable,
                          CreditPaymentGroupRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CreditPaymentSchedulesTableReferences
                                  ._creditPaymentGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CreditPaymentSchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).creditPaymentGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleItemId == item.id,
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

typedef $$CreditPaymentSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditPaymentSchedulesTable,
      CreditPaymentScheduleRow,
      $$CreditPaymentSchedulesTableFilterComposer,
      $$CreditPaymentSchedulesTableOrderingComposer,
      $$CreditPaymentSchedulesTableAnnotationComposer,
      $$CreditPaymentSchedulesTableCreateCompanionBuilder,
      $$CreditPaymentSchedulesTableUpdateCompanionBuilder,
      (CreditPaymentScheduleRow, $$CreditPaymentSchedulesTableReferences),
      CreditPaymentScheduleRow,
      PrefetchHooks Function({bool creditId, bool creditPaymentGroupsRefs})
    >;
typedef $$CreditPaymentGroupsTableCreateCompanionBuilder =
    CreditPaymentGroupsCompanion Function({
      required String id,
      required String creditId,
      required String sourceAccountId,
      Value<String?> scheduleItemId,
      required DateTime paidAt,
      required String totalOutflowMinor,
      Value<int> totalOutflowScale,
      required String principalPaidMinor,
      required String interestPaidMinor,
      required String feesPaidMinor,
      Value<String?> note,
      Value<String?> idempotencyKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CreditPaymentGroupsTableUpdateCompanionBuilder =
    CreditPaymentGroupsCompanion Function({
      Value<String> id,
      Value<String> creditId,
      Value<String> sourceAccountId,
      Value<String?> scheduleItemId,
      Value<DateTime> paidAt,
      Value<String> totalOutflowMinor,
      Value<int> totalOutflowScale,
      Value<String> principalPaidMinor,
      Value<String> interestPaidMinor,
      Value<String> feesPaidMinor,
      Value<String?> note,
      Value<String?> idempotencyKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CreditPaymentGroupsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CreditPaymentGroupsTable,
          CreditPaymentGroupRow
        > {
  $$CreditPaymentGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CreditsTable _creditIdTable(_$AppDatabase db) =>
      db.credits.createAlias(
        $_aliasNameGenerator(db.creditPaymentGroups.creditId, db.credits.id),
      );

  $$CreditsTableProcessedTableManager get creditId {
    final $_column = $_itemColumn<String>('credit_id')!;

    final manager = $$CreditsTableTableManager(
      $_db,
      $_db.credits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _sourceAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(
          db.creditPaymentGroups.sourceAccountId,
          db.accounts.id,
        ),
      );

  $$AccountsTableProcessedTableManager get sourceAccountId {
    final $_column = $_itemColumn<String>('source_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CreditPaymentSchedulesTable _scheduleItemIdTable(_$AppDatabase db) =>
      db.creditPaymentSchedules.createAlias(
        $_aliasNameGenerator(
          db.creditPaymentGroups.scheduleItemId,
          db.creditPaymentSchedules.id,
        ),
      );

  $$CreditPaymentSchedulesTableProcessedTableManager? get scheduleItemId {
    final $_column = $_itemColumn<String>('schedule_item_id');
    if ($_column == null) return null;
    final manager = $$CreditPaymentSchedulesTableTableManager(
      $_db,
      $_db.creditPaymentSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.creditPaymentGroups.id,
      db.transactions.groupId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CreditPaymentGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditPaymentGroupsTable> {
  $$CreditPaymentGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalOutflowMinor => $composableBuilder(
    column: $table.totalOutflowMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalOutflowScale => $composableBuilder(
    column: $table.totalOutflowScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feesPaidMinor => $composableBuilder(
    column: $table.feesPaidMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
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

  $$CreditsTableFilterComposer get creditId {
    final $$CreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableFilterComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get sourceAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentSchedulesTableFilterComposer get scheduleItemId {
    final $$CreditPaymentSchedulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleItemId,
          referencedTable: $db.creditPaymentSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentSchedulesTableFilterComposer(
                $db: $db,
                $table: $db.creditPaymentSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.groupId,
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
}

class $$CreditPaymentGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditPaymentGroupsTable> {
  $$CreditPaymentGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalOutflowMinor => $composableBuilder(
    column: $table.totalOutflowMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalOutflowScale => $composableBuilder(
    column: $table.totalOutflowScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feesPaidMinor => $composableBuilder(
    column: $table.feesPaidMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
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

  $$CreditsTableOrderingComposer get creditId {
    final $$CreditsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableOrderingComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get sourceAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentSchedulesTableOrderingComposer get scheduleItemId {
    final $$CreditPaymentSchedulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleItemId,
          referencedTable: $db.creditPaymentSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentSchedulesTableOrderingComposer(
                $db: $db,
                $table: $db.creditPaymentSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CreditPaymentGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditPaymentGroupsTable> {
  $$CreditPaymentGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get totalOutflowMinor => $composableBuilder(
    column: $table.totalOutflowMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalOutflowScale => $composableBuilder(
    column: $table.totalOutflowScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get principalPaidMinor => $composableBuilder(
    column: $table.principalPaidMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestPaidMinor => $composableBuilder(
    column: $table.interestPaidMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feesPaidMinor => $composableBuilder(
    column: $table.feesPaidMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CreditsTableAnnotationComposer get creditId {
    final $$CreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creditId,
      referencedTable: $db.credits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.credits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get sourceAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentSchedulesTableAnnotationComposer get scheduleItemId {
    final $$CreditPaymentSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleItemId,
          referencedTable: $db.creditPaymentSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.groupId,
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
}

class $$CreditPaymentGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditPaymentGroupsTable,
          CreditPaymentGroupRow,
          $$CreditPaymentGroupsTableFilterComposer,
          $$CreditPaymentGroupsTableOrderingComposer,
          $$CreditPaymentGroupsTableAnnotationComposer,
          $$CreditPaymentGroupsTableCreateCompanionBuilder,
          $$CreditPaymentGroupsTableUpdateCompanionBuilder,
          (CreditPaymentGroupRow, $$CreditPaymentGroupsTableReferences),
          CreditPaymentGroupRow,
          PrefetchHooks Function({
            bool creditId,
            bool sourceAccountId,
            bool scheduleItemId,
            bool transactionsRefs,
          })
        > {
  $$CreditPaymentGroupsTableTableManager(
    _$AppDatabase db,
    $CreditPaymentGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditPaymentGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditPaymentGroupsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CreditPaymentGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> creditId = const Value.absent(),
                Value<String> sourceAccountId = const Value.absent(),
                Value<String?> scheduleItemId = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<String> totalOutflowMinor = const Value.absent(),
                Value<int> totalOutflowScale = const Value.absent(),
                Value<String> principalPaidMinor = const Value.absent(),
                Value<String> interestPaidMinor = const Value.absent(),
                Value<String> feesPaidMinor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditPaymentGroupsCompanion(
                id: id,
                creditId: creditId,
                sourceAccountId: sourceAccountId,
                scheduleItemId: scheduleItemId,
                paidAt: paidAt,
                totalOutflowMinor: totalOutflowMinor,
                totalOutflowScale: totalOutflowScale,
                principalPaidMinor: principalPaidMinor,
                interestPaidMinor: interestPaidMinor,
                feesPaidMinor: feesPaidMinor,
                note: note,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String creditId,
                required String sourceAccountId,
                Value<String?> scheduleItemId = const Value.absent(),
                required DateTime paidAt,
                required String totalOutflowMinor,
                Value<int> totalOutflowScale = const Value.absent(),
                required String principalPaidMinor,
                required String interestPaidMinor,
                required String feesPaidMinor,
                Value<String?> note = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditPaymentGroupsCompanion.insert(
                id: id,
                creditId: creditId,
                sourceAccountId: sourceAccountId,
                scheduleItemId: scheduleItemId,
                paidAt: paidAt,
                totalOutflowMinor: totalOutflowMinor,
                totalOutflowScale: totalOutflowScale,
                principalPaidMinor: principalPaidMinor,
                interestPaidMinor: interestPaidMinor,
                feesPaidMinor: feesPaidMinor,
                note: note,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditPaymentGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creditId = false,
                sourceAccountId = false,
                scheduleItemId = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
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
                        if (creditId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.creditId,
                                    referencedTable:
                                        $$CreditPaymentGroupsTableReferences
                                            ._creditIdTable(db),
                                    referencedColumn:
                                        $$CreditPaymentGroupsTableReferences
                                            ._creditIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceAccountId,
                                    referencedTable:
                                        $$CreditPaymentGroupsTableReferences
                                            ._sourceAccountIdTable(db),
                                    referencedColumn:
                                        $$CreditPaymentGroupsTableReferences
                                            ._sourceAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (scheduleItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scheduleItemId,
                                    referencedTable:
                                        $$CreditPaymentGroupsTableReferences
                                            ._scheduleItemIdTable(db),
                                    referencedColumn:
                                        $$CreditPaymentGroupsTableReferences
                                            ._scheduleItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CreditPaymentGroupRow,
                          $CreditPaymentGroupsTable,
                          TransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CreditPaymentGroupsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CreditPaymentGroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
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

typedef $$CreditPaymentGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditPaymentGroupsTable,
      CreditPaymentGroupRow,
      $$CreditPaymentGroupsTableFilterComposer,
      $$CreditPaymentGroupsTableOrderingComposer,
      $$CreditPaymentGroupsTableAnnotationComposer,
      $$CreditPaymentGroupsTableCreateCompanionBuilder,
      $$CreditPaymentGroupsTableUpdateCompanionBuilder,
      (CreditPaymentGroupRow, $$CreditPaymentGroupsTableReferences),
      CreditPaymentGroupRow,
      PrefetchHooks Function({
        bool creditId,
        bool sourceAccountId,
        bool scheduleItemId,
        bool transactionsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String accountId,
      Value<String?> transferAccountId,
      Value<String?> categoryId,
      required double amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      required DateTime date,
      Value<String?> note,
      required String type,
      Value<String?> idempotencyKey,
      Value<String?> savingGoalId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<String?> groupId,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String?> transferAccountId,
      Value<String?> categoryId,
      Value<double> amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      Value<DateTime> date,
      Value<String?> note,
      Value<String> type,
      Value<String?> idempotencyKey,
      Value<String?> savingGoalId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<String?> groupId,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _transferAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.transferAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get transferAccountId {
    final $_column = $_itemColumn<String>('transfer_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transferAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
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

  static $SavingGoalsTable _savingGoalIdTable(_$AppDatabase db) =>
      db.savingGoals.createAlias(
        $_aliasNameGenerator(db.transactions.savingGoalId, db.savingGoals.id),
      );

  $$SavingGoalsTableProcessedTableManager? get savingGoalId {
    final $_column = $_itemColumn<String>('saving_goal_id');
    if ($_column == null) return null;
    final manager = $$SavingGoalsTableTableManager(
      $_db,
      $_db.savingGoals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savingGoalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CreditPaymentGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.creditPaymentGroups.createAlias(
        $_aliasNameGenerator(
          db.transactions.groupId,
          db.creditPaymentGroups.id,
        ),
      );

  $$CreditPaymentGroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$CreditPaymentGroupsTableTableManager(
      $_db,
      $_db.creditPaymentGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTagRow>>
  _transactionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTags,
    aliasName: $_aliasNameGenerator(
      db.transactions.id,
      db.transactionTags.transactionId,
    ),
  );

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager = $$TransactionTagsTableTableManager(
      $_db,
      $_db.transactionTags,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalContributionsTable, List<GoalContributionRow>>
  _goalContributionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.goalContributions,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.goalContributions.transactionId,
        ),
      );

  $$GoalContributionsTableProcessedTableManager get goalContributionsRefs {
    final manager = $$GoalContributionsTableTableManager(
      $_db,
      $_db.goalContributions,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _goalContributionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get transferAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$SavingGoalsTableFilterComposer get savingGoalId {
    final $$SavingGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingGoalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableFilterComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentGroupsTableFilterComposer get groupId {
    final $$CreditPaymentGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.creditPaymentGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CreditPaymentGroupsTableFilterComposer(
            $db: $db,
            $table: $db.creditPaymentGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionTagsRefs(
    Expression<bool> Function($$TransactionTagsTableFilterComposer f) f,
  ) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableFilterComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalContributionsRefs(
    Expression<bool> Function($$GoalContributionsTableFilterComposer f) f,
  ) {
    final $$GoalContributionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalContributions,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalContributionsTableFilterComposer(
            $db: $db,
            $table: $db.goalContributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get transferAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$SavingGoalsTableOrderingComposer get savingGoalId {
    final $$SavingGoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingGoalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableOrderingComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentGroupsTableOrderingComposer get groupId {
    final $$CreditPaymentGroupsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.creditPaymentGroups,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentGroupsTableOrderingComposer(
                $db: $db,
                $table: $db.creditPaymentGroups,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get transferAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$SavingGoalsTableAnnotationComposer get savingGoalId {
    final $$SavingGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingGoalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CreditPaymentGroupsTableAnnotationComposer get groupId {
    final $$CreditPaymentGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.creditPaymentGroups,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CreditPaymentGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.creditPaymentGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> transactionTagsRefs<T extends Object>(
    Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f,
  ) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTags,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalContributionsRefs<T extends Object>(
    Expression<T> Function($$GoalContributionsTableAnnotationComposer a) f,
  ) {
    final $$GoalContributionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.goalContributions,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GoalContributionsTableAnnotationComposer(
                $db: $db,
                $table: $db.goalContributions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool accountId,
            bool transferAccountId,
            bool categoryId,
            bool savingGoalId,
            bool groupId,
            bool transactionTagsRefs,
            bool goalContributionsRefs,
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
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> transferAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<String?> savingGoalId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                accountId: accountId,
                transferAccountId: transferAccountId,
                categoryId: categoryId,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                date: date,
                note: note,
                type: type,
                idempotencyKey: idempotencyKey,
                savingGoalId: savingGoalId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                Value<String?> transferAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                required String type,
                Value<String?> idempotencyKey = const Value.absent(),
                Value<String?> savingGoalId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                accountId: accountId,
                transferAccountId: transferAccountId,
                categoryId: categoryId,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                date: date,
                note: note,
                type: type,
                idempotencyKey: idempotencyKey,
                savingGoalId: savingGoalId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                groupId: groupId,
                rowid: rowid,
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
                accountId = false,
                transferAccountId = false,
                categoryId = false,
                savingGoalId = false,
                groupId = false,
                transactionTagsRefs = false,
                goalContributionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionTagsRefs) db.transactionTags,
                    if (goalContributionsRefs) db.goalContributions,
                  ],
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (transferAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transferAccountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._transferAccountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._transferAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
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
                        if (savingGoalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.savingGoalId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._savingGoalIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._savingGoalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionTagsRefs)
                        await $_getPrefetchedData<
                          TransactionRow,
                          $TransactionsTable,
                          TransactionTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalContributionsRefs)
                        await $_getPrefetchedData<
                          TransactionRow,
                          $TransactionsTable,
                          GoalContributionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._goalContributionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalContributionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({
        bool accountId,
        bool transferAccountId,
        bool categoryId,
        bool savingGoalId,
        bool groupId,
        bool transactionTagsRefs,
        bool goalContributionsRefs,
      })
    >;
typedef $$TransactionTagsTableCreateCompanionBuilder =
    TransactionTagsCompanion Function({
      required String transactionId,
      required String tagId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TransactionTagsTableUpdateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<String> transactionId,
      Value<String> tagId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$TransactionTagsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionTagsTable,
          TransactionTagRow
        > {
  $$TransactionTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactionTags.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.transactionTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTagsTable,
          TransactionTagRow,
          $$TransactionTagsTableFilterComposer,
          $$TransactionTagsTableOrderingComposer,
          $$TransactionTagsTableAnnotationComposer,
          $$TransactionTagsTableCreateCompanionBuilder,
          $$TransactionTagsTableUpdateCompanionBuilder,
          (TransactionTagRow, $$TransactionTagsTableReferences),
          TransactionTagRow,
          PrefetchHooks Function({bool transactionId, bool tagId})
        > {
  $$TransactionTagsTableTableManager(
    _$AppDatabase db,
    $TransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transactionId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion(
                transactionId: transactionId,
                tagId: tagId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transactionId,
                required String tagId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion.insert(
                transactionId: transactionId,
                tagId: tagId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, tagId = false}) {
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
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionTagsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionTagsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$TransactionTagsTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$TransactionTagsTableReferences
                                        ._tagIdTable(db)
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

typedef $$TransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTagsTable,
      TransactionTagRow,
      $$TransactionTagsTableFilterComposer,
      $$TransactionTagsTableOrderingComposer,
      $$TransactionTagsTableAnnotationComposer,
      $$TransactionTagsTableCreateCompanionBuilder,
      $$TransactionTagsTableUpdateCompanionBuilder,
      (TransactionTagRow, $$TransactionTagsTableReferences),
      TransactionTagRow,
      PrefetchHooks Function({bool transactionId, bool tagId})
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payload,
      Value<String> status,
      Value<int> attemptCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> sentAt,
      Value<String?> lastError,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<String> status,
      Value<int> attemptCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> sentAt,
      Value<String?> lastError,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
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

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
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

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntryRow,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntryRow,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
          ),
          OutboxEntryRow,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                status: status,
                attemptCount: attemptCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                status: status,
                attemptCount: attemptCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntryRow,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntryRow,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
      ),
      OutboxEntryRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String uid,
      Value<String?> name,
      Value<String?> currency,
      Value<String?> locale,
      Value<String?> photoUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> uid,
      Value<String?> name,
      Value<String?> currency,
      Value<String?> locale,
      Value<String?> photoUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                uid: uid,
                name: name,
                currency: currency,
                locale: locale,
                photoUrl: photoUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                Value<String?> name = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                uid: uid,
                name: name,
                currency: currency,
                locale: locale,
                photoUrl: photoUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String title,
      required String period,
      required DateTime startDate,
      Value<DateTime?> endDate,
      required double amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      required String scope,
      Value<List<String>> categories,
      Value<List<String>> accounts,
      Value<List<Map<String, dynamic>>> categoryAllocations,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> period,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<double> amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      Value<String> scope,
      Value<List<String>> categories,
      Value<List<String>> accounts,
      Value<List<Map<String, dynamic>>> categoryAllocations,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BudgetInstancesTable, List<BudgetInstanceRow>>
  _budgetInstancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetInstances,
    aliasName: $_aliasNameGenerator(db.budgets.id, db.budgetInstances.budgetId),
  );

  $$BudgetInstancesTableProcessedTableManager get budgetInstancesRefs {
    final manager = $$BudgetInstancesTableTableManager(
      $_db,
      $_db.budgetInstances,
    ).filter((f) => f.budgetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetInstancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get accounts => $composableBuilder(
    column: $table.accounts,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<Map<String, dynamic>>,
    List<Map<String, dynamic>>,
    String
  >
  get categoryAllocations => $composableBuilder(
    column: $table.categoryAllocations,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> budgetInstancesRefs(
    Expression<bool> Function($$BudgetInstancesTableFilterComposer f) f,
  ) {
    final $$BudgetInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetInstances,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetInstancesTableFilterComposer(
            $db: $db,
            $table: $db.budgetInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accounts => $composableBuilder(
    column: $table.accounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryAllocations => $composableBuilder(
    column: $table.categoryAllocations,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get categories =>
      $composableBuilder(
        column: $table.categories,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get accounts =>
      $composableBuilder(column: $table.accounts, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Map<String, dynamic>>, String>
  get categoryAllocations => $composableBuilder(
    column: $table.categoryAllocations,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> budgetInstancesRefs<T extends Object>(
    Expression<T> Function($$BudgetInstancesTableAnnotationComposer a) f,
  ) {
    final $$BudgetInstancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetInstances,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetInstancesTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetRow,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetRow, $$BudgetsTableReferences),
          BudgetRow,
          PrefetchHooks Function({bool budgetInstancesRefs})
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
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<List<String>> categories = const Value.absent(),
                Value<List<String>> accounts = const Value.absent(),
                Value<List<Map<String, dynamic>>> categoryAllocations =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                title: title,
                period: period,
                startDate: startDate,
                endDate: endDate,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                scope: scope,
                categories: categories,
                accounts: accounts,
                categoryAllocations: categoryAllocations,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String period,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                required String scope,
                Value<List<String>> categories = const Value.absent(),
                Value<List<String>> accounts = const Value.absent(),
                Value<List<Map<String, dynamic>>> categoryAllocations =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                title: title,
                period: period,
                startDate: startDate,
                endDate: endDate,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                scope: scope,
                categories: categories,
                accounts: accounts,
                categoryAllocations: categoryAllocations,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({budgetInstancesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (budgetInstancesRefs) db.budgetInstances,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (budgetInstancesRefs)
                    await $_getPrefetchedData<
                      BudgetRow,
                      $BudgetsTable,
                      BudgetInstanceRow
                    >(
                      currentTable: table,
                      referencedTable: $$BudgetsTableReferences
                          ._budgetInstancesRefsTable(db),
                      managerFromTypedResult: (p0) => $$BudgetsTableReferences(
                        db,
                        table,
                        p0,
                      ).budgetInstancesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.budgetId == item.id),
                      typedResults: items,
                    ),
                ];
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
      BudgetRow,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetRow, $$BudgetsTableReferences),
      BudgetRow,
      PrefetchHooks Function({bool budgetInstancesRefs})
    >;
typedef $$BudgetInstancesTableCreateCompanionBuilder =
    BudgetInstancesCompanion Function({
      required String id,
      required String budgetId,
      required DateTime periodStart,
      required DateTime periodEnd,
      required double amount,
      Value<String> amountMinor,
      Value<double> spent,
      Value<String> spentMinor,
      Value<int> amountScale,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetInstancesTableUpdateCompanionBuilder =
    BudgetInstancesCompanion Function({
      Value<String> id,
      Value<String> budgetId,
      Value<DateTime> periodStart,
      Value<DateTime> periodEnd,
      Value<double> amount,
      Value<String> amountMinor,
      Value<double> spent,
      Value<String> spentMinor,
      Value<int> amountScale,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$BudgetInstancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BudgetInstancesTable,
          BudgetInstanceRow
        > {
  $$BudgetInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) =>
      db.budgets.createAlias(
        $_aliasNameGenerator(db.budgetInstances.budgetId, db.budgets.id),
      );

  $$BudgetsTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<String>('budget_id')!;

    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetInstancesTable> {
  $$BudgetInstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spent => $composableBuilder(
    column: $table.spent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spentMinor => $composableBuilder(
    column: $table.spentMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BudgetInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetInstancesTable> {
  $$BudgetInstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spent => $composableBuilder(
    column: $table.spent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spentMinor => $composableBuilder(
    column: $table.spentMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableOrderingComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetInstancesTable> {
  $$BudgetInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => column);

  GeneratedColumn<String> get spentMinor => $composableBuilder(
    column: $table.spentMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$BudgetInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetInstancesTable,
          BudgetInstanceRow,
          $$BudgetInstancesTableFilterComposer,
          $$BudgetInstancesTableOrderingComposer,
          $$BudgetInstancesTableAnnotationComposer,
          $$BudgetInstancesTableCreateCompanionBuilder,
          $$BudgetInstancesTableUpdateCompanionBuilder,
          (BudgetInstanceRow, $$BudgetInstancesTableReferences),
          BudgetInstanceRow,
          PrefetchHooks Function({bool budgetId})
        > {
  $$BudgetInstancesTableTableManager(
    _$AppDatabase db,
    $BudgetInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetInstancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<double> spent = const Value.absent(),
                Value<String> spentMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetInstancesCompanion(
                id: id,
                budgetId: budgetId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                amount: amount,
                amountMinor: amountMinor,
                spent: spent,
                spentMinor: spentMinor,
                amountScale: amountScale,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String budgetId,
                required DateTime periodStart,
                required DateTime periodEnd,
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<double> spent = const Value.absent(),
                Value<String> spentMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetInstancesCompanion.insert(
                id: id,
                budgetId: budgetId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                amount: amount,
                amountMinor: amountMinor,
                spent: spent,
                spentMinor: spentMinor,
                amountScale: amountScale,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({budgetId = false}) {
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
                    if (budgetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.budgetId,
                                referencedTable:
                                    $$BudgetInstancesTableReferences
                                        ._budgetIdTable(db),
                                referencedColumn:
                                    $$BudgetInstancesTableReferences
                                        ._budgetIdTable(db)
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

typedef $$BudgetInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetInstancesTable,
      BudgetInstanceRow,
      $$BudgetInstancesTableFilterComposer,
      $$BudgetInstancesTableOrderingComposer,
      $$BudgetInstancesTableAnnotationComposer,
      $$BudgetInstancesTableCreateCompanionBuilder,
      $$BudgetInstancesTableUpdateCompanionBuilder,
      (BudgetInstanceRow, $$BudgetInstancesTableReferences),
      BudgetInstanceRow,
      PrefetchHooks Function({bool budgetId})
    >;
typedef $$GoalContributionsTableCreateCompanionBuilder =
    GoalContributionsCompanion Function({
      required String id,
      required String goalId,
      required String transactionId,
      required int amount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$GoalContributionsTableUpdateCompanionBuilder =
    GoalContributionsCompanion Function({
      Value<String> id,
      Value<String> goalId,
      Value<String> transactionId,
      Value<int> amount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GoalContributionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GoalContributionsTable,
          GoalContributionRow
        > {
  $$GoalContributionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingGoalsTable _goalIdTable(_$AppDatabase db) =>
      db.savingGoals.createAlias(
        $_aliasNameGenerator(db.goalContributions.goalId, db.savingGoals.id),
      );

  $$SavingGoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<String>('goal_id')!;

    final manager = $$SavingGoalsTableTableManager(
      $_db,
      $_db.savingGoals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.goalContributions.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingGoalsTableFilterComposer get goalId {
    final $$SavingGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableFilterComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$GoalContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingGoalsTableOrderingComposer get goalId {
    final $$SavingGoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableOrderingComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SavingGoalsTableAnnotationComposer get goalId {
    final $$SavingGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$GoalContributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalContributionsTable,
          GoalContributionRow,
          $$GoalContributionsTableFilterComposer,
          $$GoalContributionsTableOrderingComposer,
          $$GoalContributionsTableAnnotationComposer,
          $$GoalContributionsTableCreateCompanionBuilder,
          $$GoalContributionsTableUpdateCompanionBuilder,
          (GoalContributionRow, $$GoalContributionsTableReferences),
          GoalContributionRow,
          PrefetchHooks Function({bool goalId, bool transactionId})
        > {
  $$GoalContributionsTableTableManager(
    _$AppDatabase db,
    $GoalContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalContributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> goalId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalContributionsCompanion(
                id: id,
                goalId: goalId,
                transactionId: transactionId,
                amount: amount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String goalId,
                required String transactionId,
                required int amount,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalContributionsCompanion.insert(
                id: id,
                goalId: goalId,
                transactionId: transactionId,
                amount: amount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalContributionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false, transactionId = false}) {
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
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable:
                                    $$GoalContributionsTableReferences
                                        ._goalIdTable(db),
                                referencedColumn:
                                    $$GoalContributionsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$GoalContributionsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$GoalContributionsTableReferences
                                        ._transactionIdTable(db)
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

typedef $$GoalContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalContributionsTable,
      GoalContributionRow,
      $$GoalContributionsTableFilterComposer,
      $$GoalContributionsTableOrderingComposer,
      $$GoalContributionsTableAnnotationComposer,
      $$GoalContributionsTableCreateCompanionBuilder,
      $$GoalContributionsTableUpdateCompanionBuilder,
      (GoalContributionRow, $$GoalContributionsTableReferences),
      GoalContributionRow,
      PrefetchHooks Function({bool goalId, bool transactionId})
    >;
typedef $$UpcomingPaymentsTableCreateCompanionBuilder =
    UpcomingPaymentsCompanion Function({
      required String id,
      required String title,
      required String accountId,
      required String categoryId,
      required double amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      required int dayOfMonth,
      Value<int> notifyDaysBefore,
      Value<String> notifyTimeHhmm,
      Value<String?> note,
      Value<bool> autoPost,
      Value<bool> isActive,
      Value<int?> nextRunAt,
      Value<int?> nextNotifyAt,
      Value<String?> lastGeneratedPeriod,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$UpcomingPaymentsTableUpdateCompanionBuilder =
    UpcomingPaymentsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> accountId,
      Value<String> categoryId,
      Value<double> amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      Value<int> dayOfMonth,
      Value<int> notifyDaysBefore,
      Value<String> notifyTimeHhmm,
      Value<String?> note,
      Value<bool> autoPost,
      Value<bool> isActive,
      Value<int?> nextRunAt,
      Value<int?> nextNotifyAt,
      Value<String?> lastGeneratedPeriod,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$UpcomingPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UpcomingPaymentsTable,
          UpcomingPaymentRow
        > {
  $$UpcomingPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.upcomingPayments.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.upcomingPayments.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

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
}

class $$UpcomingPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $UpcomingPaymentsTable> {
  $$UpcomingPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifyDaysBefore => $composableBuilder(
    column: $table.notifyDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notifyTimeHhmm => $composableBuilder(
    column: $table.notifyTimeHhmm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoPost => $composableBuilder(
    column: $table.autoPost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextNotifyAt => $composableBuilder(
    column: $table.nextNotifyAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
}

class $$UpcomingPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $UpcomingPaymentsTable> {
  $$UpcomingPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifyDaysBefore => $composableBuilder(
    column: $table.notifyDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notifyTimeHhmm => $composableBuilder(
    column: $table.notifyTimeHhmm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoPost => $composableBuilder(
    column: $table.autoPost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextNotifyAt => $composableBuilder(
    column: $table.nextNotifyAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
}

class $$UpcomingPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpcomingPaymentsTable> {
  $$UpcomingPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifyDaysBefore => $composableBuilder(
    column: $table.notifyDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notifyTimeHhmm => $composableBuilder(
    column: $table.notifyTimeHhmm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get autoPost =>
      $composableBuilder(column: $table.autoPost, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<int> get nextNotifyAt => $composableBuilder(
    column: $table.nextNotifyAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
}

class $$UpcomingPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpcomingPaymentsTable,
          UpcomingPaymentRow,
          $$UpcomingPaymentsTableFilterComposer,
          $$UpcomingPaymentsTableOrderingComposer,
          $$UpcomingPaymentsTableAnnotationComposer,
          $$UpcomingPaymentsTableCreateCompanionBuilder,
          $$UpcomingPaymentsTableUpdateCompanionBuilder,
          (UpcomingPaymentRow, $$UpcomingPaymentsTableReferences),
          UpcomingPaymentRow,
          PrefetchHooks Function({bool accountId, bool categoryId})
        > {
  $$UpcomingPaymentsTableTableManager(
    _$AppDatabase db,
    $UpcomingPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpcomingPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpcomingPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UpcomingPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<int> notifyDaysBefore = const Value.absent(),
                Value<String> notifyTimeHhmm = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> autoPost = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> nextRunAt = const Value.absent(),
                Value<int?> nextNotifyAt = const Value.absent(),
                Value<String?> lastGeneratedPeriod = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UpcomingPaymentsCompanion(
                id: id,
                title: title,
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                dayOfMonth: dayOfMonth,
                notifyDaysBefore: notifyDaysBefore,
                notifyTimeHhmm: notifyTimeHhmm,
                note: note,
                autoPost: autoPost,
                isActive: isActive,
                nextRunAt: nextRunAt,
                nextNotifyAt: nextNotifyAt,
                lastGeneratedPeriod: lastGeneratedPeriod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String accountId,
                required String categoryId,
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                required int dayOfMonth,
                Value<int> notifyDaysBefore = const Value.absent(),
                Value<String> notifyTimeHhmm = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> autoPost = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> nextRunAt = const Value.absent(),
                Value<int?> nextNotifyAt = const Value.absent(),
                Value<String?> lastGeneratedPeriod = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UpcomingPaymentsCompanion.insert(
                id: id,
                title: title,
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                dayOfMonth: dayOfMonth,
                notifyDaysBefore: notifyDaysBefore,
                notifyTimeHhmm: notifyTimeHhmm,
                note: note,
                autoPost: autoPost,
                isActive: isActive,
                nextRunAt: nextRunAt,
                nextNotifyAt: nextNotifyAt,
                lastGeneratedPeriod: lastGeneratedPeriod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UpcomingPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$UpcomingPaymentsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$UpcomingPaymentsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$UpcomingPaymentsTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$UpcomingPaymentsTableReferences
                                        ._categoryIdTable(db)
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

typedef $$UpcomingPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpcomingPaymentsTable,
      UpcomingPaymentRow,
      $$UpcomingPaymentsTableFilterComposer,
      $$UpcomingPaymentsTableOrderingComposer,
      $$UpcomingPaymentsTableAnnotationComposer,
      $$UpcomingPaymentsTableCreateCompanionBuilder,
      $$UpcomingPaymentsTableUpdateCompanionBuilder,
      (UpcomingPaymentRow, $$UpcomingPaymentsTableReferences),
      UpcomingPaymentRow,
      PrefetchHooks Function({bool accountId, bool categoryId})
    >;
typedef $$PaymentRemindersTableCreateCompanionBuilder =
    PaymentRemindersCompanion Function({
      required String id,
      required String title,
      required double amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      required int whenAt,
      Value<String?> note,
      Value<bool> isDone,
      Value<int?> lastNotifiedAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$PaymentRemindersTableUpdateCompanionBuilder =
    PaymentRemindersCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<double> amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      Value<int> whenAt,
      Value<String?> note,
      Value<bool> isDone,
      Value<int?> lastNotifiedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$PaymentRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentRemindersTable> {
  $$PaymentRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get whenAt => $composableBuilder(
    column: $table.whenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentRemindersTable> {
  $$PaymentRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whenAt => $composableBuilder(
    column: $table.whenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentRemindersTable> {
  $$PaymentRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get whenAt =>
      $composableBuilder(column: $table.whenAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PaymentRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentRemindersTable,
          PaymentReminderRow,
          $$PaymentRemindersTableFilterComposer,
          $$PaymentRemindersTableOrderingComposer,
          $$PaymentRemindersTableAnnotationComposer,
          $$PaymentRemindersTableCreateCompanionBuilder,
          $$PaymentRemindersTableUpdateCompanionBuilder,
          (
            PaymentReminderRow,
            BaseReferences<
              _$AppDatabase,
              $PaymentRemindersTable,
              PaymentReminderRow
            >,
          ),
          PaymentReminderRow,
          PrefetchHooks Function()
        > {
  $$PaymentRemindersTableTableManager(
    _$AppDatabase db,
    $PaymentRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<int> whenAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> lastNotifiedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentRemindersCompanion(
                id: id,
                title: title,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                whenAt: whenAt,
                note: note,
                isDone: isDone,
                lastNotifiedAt: lastNotifiedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                required int whenAt,
                Value<String?> note = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> lastNotifiedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentRemindersCompanion.insert(
                id: id,
                title: title,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                whenAt: whenAt,
                note: note,
                isDone: isDone,
                lastNotifiedAt: lastNotifiedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentRemindersTable,
      PaymentReminderRow,
      $$PaymentRemindersTableFilterComposer,
      $$PaymentRemindersTableOrderingComposer,
      $$PaymentRemindersTableAnnotationComposer,
      $$PaymentRemindersTableCreateCompanionBuilder,
      $$PaymentRemindersTableUpdateCompanionBuilder,
      (
        PaymentReminderRow,
        BaseReferences<
          _$AppDatabase,
          $PaymentRemindersTable,
          PaymentReminderRow
        >,
      ),
      PaymentReminderRow,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      required String id,
      required String accountId,
      Value<String?> name,
      required double amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      required DateTime dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String?> name,
      Value<double> amount,
      Value<String> amountMinor,
      Value<int> amountScale,
      Value<DateTime> dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$DebtsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTable, DebtRow> {
  $$DebtsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.debts.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountScale => $composableBuilder(
    column: $table.amountScale,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          DebtRow,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (DebtRow, $$DebtsTableReferences),
          DebtRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                accountId: accountId,
                name: name,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                Value<String?> name = const Value.absent(),
                required double amount,
                Value<String> amountMinor = const Value.absent(),
                Value<int> amountScale = const Value.absent(),
                required DateTime dueDate,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                accountId: accountId,
                name: name,
                amount: amount,
                amountMinor: amountMinor,
                amountScale: amountScale,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DebtsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$DebtsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$DebtsTableReferences
                                    ._accountIdTable(db)
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

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      DebtRow,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (DebtRow, $$DebtsTableReferences),
      DebtRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$CreditCardsTableCreateCompanionBuilder =
    CreditCardsCompanion Function({
      required String id,
      required String accountId,
      required double creditLimit,
      Value<String> creditLimitMinor,
      Value<int> creditLimitScale,
      required int statementDay,
      required int paymentDueDays,
      required double interestRateAnnual,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CreditCardsTableUpdateCompanionBuilder =
    CreditCardsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<double> creditLimit,
      Value<String> creditLimitMinor,
      Value<int> creditLimitScale,
      Value<int> statementDay,
      Value<int> paymentDueDays,
      Value<double> interestRateAnnual,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$CreditCardsTableReferences
    extends BaseReferences<_$AppDatabase, $CreditCardsTable, CreditCardRow> {
  $$CreditCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.creditCards.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CreditCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitScale => $composableBuilder(
    column: $table.creditLimitScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentDueDays => $composableBuilder(
    column: $table.paymentDueDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitScale => $composableBuilder(
    column: $table.creditLimitScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentDueDays => $composableBuilder(
    column: $table.paymentDueDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditLimitScale => $composableBuilder(
    column: $table.creditLimitScale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentDueDays => $composableBuilder(
    column: $table.paymentDueDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CreditCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditCardsTable,
          CreditCardRow,
          $$CreditCardsTableFilterComposer,
          $$CreditCardsTableOrderingComposer,
          $$CreditCardsTableAnnotationComposer,
          $$CreditCardsTableCreateCompanionBuilder,
          $$CreditCardsTableUpdateCompanionBuilder,
          (CreditCardRow, $$CreditCardsTableReferences),
          CreditCardRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$CreditCardsTableTableManager(_$AppDatabase db, $CreditCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<String> creditLimitMinor = const Value.absent(),
                Value<int> creditLimitScale = const Value.absent(),
                Value<int> statementDay = const Value.absent(),
                Value<int> paymentDueDays = const Value.absent(),
                Value<double> interestRateAnnual = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditCardsCompanion(
                id: id,
                accountId: accountId,
                creditLimit: creditLimit,
                creditLimitMinor: creditLimitMinor,
                creditLimitScale: creditLimitScale,
                statementDay: statementDay,
                paymentDueDays: paymentDueDays,
                interestRateAnnual: interestRateAnnual,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required double creditLimit,
                Value<String> creditLimitMinor = const Value.absent(),
                Value<int> creditLimitScale = const Value.absent(),
                required int statementDay,
                required int paymentDueDays,
                required double interestRateAnnual,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditCardsCompanion.insert(
                id: id,
                accountId: accountId,
                creditLimit: creditLimit,
                creditLimitMinor: creditLimitMinor,
                creditLimitScale: creditLimitScale,
                statementDay: statementDay,
                paymentDueDays: paymentDueDays,
                interestRateAnnual: interestRateAnnual,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CreditCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$CreditCardsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$CreditCardsTableReferences
                                    ._accountIdTable(db)
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

typedef $$CreditCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditCardsTable,
      CreditCardRow,
      $$CreditCardsTableFilterComposer,
      $$CreditCardsTableOrderingComposer,
      $$CreditCardsTableAnnotationComposer,
      $$CreditCardsTableCreateCompanionBuilder,
      $$CreditCardsTableUpdateCompanionBuilder,
      (CreditCardRow, $$CreditCardsTableReferences),
      CreditCardRow,
      PrefetchHooks Function({bool accountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$SavingGoalsTableTableManager get savingGoals =>
      $$SavingGoalsTableTableManager(_db, _db.savingGoals);
  $$CreditsTableTableManager get credits =>
      $$CreditsTableTableManager(_db, _db.credits);
  $$CreditPaymentSchedulesTableTableManager get creditPaymentSchedules =>
      $$CreditPaymentSchedulesTableTableManager(
        _db,
        _db.creditPaymentSchedules,
      );
  $$CreditPaymentGroupsTableTableManager get creditPaymentGroups =>
      $$CreditPaymentGroupsTableTableManager(_db, _db.creditPaymentGroups);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$BudgetInstancesTableTableManager get budgetInstances =>
      $$BudgetInstancesTableTableManager(_db, _db.budgetInstances);
  $$GoalContributionsTableTableManager get goalContributions =>
      $$GoalContributionsTableTableManager(_db, _db.goalContributions);
  $$UpcomingPaymentsTableTableManager get upcomingPayments =>
      $$UpcomingPaymentsTableTableManager(_db, _db.upcomingPayments);
  $$PaymentRemindersTableTableManager get paymentReminders =>
      $$PaymentRemindersTableTableManager(_db, _db.paymentReminders);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$CreditCardsTableTableManager get creditCards =>
      $$CreditCardsTableTableManager(_db, _db.creditCards);
}
