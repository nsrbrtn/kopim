import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';

Set<String> collectActiveLiabilityAccountIds({
  Iterable<CreditEntity> credits = const <CreditEntity>[],
  Iterable<CreditCardEntity> creditCards = const <CreditCardEntity>[],
  Iterable<DebtEntity> debts = const <DebtEntity>[],
}) {
  final Set<String> accountIds = <String>{};

  for (final CreditEntity credit in credits) {
    if (!credit.isDeleted && credit.accountId.isNotEmpty) {
      accountIds.add(credit.accountId);
    }
  }

  for (final CreditCardEntity creditCard in creditCards) {
    if (!creditCard.isDeleted && creditCard.accountId.isNotEmpty) {
      accountIds.add(creditCard.accountId);
    }
  }

  for (final DebtEntity debt in debts) {
    if (!debt.isDeleted && debt.accountId.isNotEmpty) {
      accountIds.add(debt.accountId);
    }
  }

  return accountIds;
}

bool isOrphanedLiabilityAccount(
  AccountEntity account, {
  required Set<String> activeLiabilityAccountIds,
}) {
  return isLiabilityAccountType(account.type) &&
      !activeLiabilityAccountIds.contains(account.id);
}

List<AccountEntity> excludeOrphanedLiabilityAccounts({
  required Iterable<AccountEntity> accounts,
  required Set<String> activeLiabilityAccountIds,
}) {
  return accounts
      .where(
        (AccountEntity account) => !isOrphanedLiabilityAccount(
          account,
          activeLiabilityAccountIds: activeLiabilityAccountIds,
        ),
      )
      .toList(growable: false);
}

List<AccountEntity> markOrphanedLiabilityAccountsDeleted({
  required Iterable<AccountEntity> accounts,
  required Set<String> activeLiabilityAccountIds,
}) {
  return accounts
      .map((AccountEntity account) {
        if (!isOrphanedLiabilityAccount(
          account,
          activeLiabilityAccountIds: activeLiabilityAccountIds,
        )) {
          return account;
        }
        return account.isDeleted ? account : account.copyWith(isDeleted: true);
      })
      .toList(growable: false);
}
