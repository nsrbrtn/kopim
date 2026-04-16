import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

Map<String, dynamic> mapAccountSyncPayload(AccountEntity account) {
  final Map<String, dynamic> json = account.toJson();
  json['updatedAt'] = account.updatedAt.toIso8601String();
  json['createdAt'] = account.createdAt.toIso8601String();
  json['isPrimary'] = account.isPrimary;
  json['color'] = account.color;
  json['gradientId'] = account.gradientId;
  json['iconName'] = account.iconName;
  json['iconStyle'] = account.iconStyle;
  json['typeVersion'] = account.typeVersion;
  final MoneyAmount balance = account.balanceAmount;
  final MoneyAmount openingBalance = account.openingBalanceAmount;
  json['balance'] = balance.toDouble();
  json['openingBalance'] = openingBalance.toDouble();
  json['balanceMinor'] = balance.minor.toString();
  json['openingBalanceMinor'] = openingBalance.minor.toString();
  json['currencyScale'] = account.currencyScale;
  return json;
}
