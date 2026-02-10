import 'dart:async';

import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchAccountTransactionsUseCase {
  WatchAccountTransactionsUseCase({
    required TransactionRepository transactionRepository,
    required CreditRepository creditRepository,
  }) : _transactionRepository = transactionRepository,
       _creditRepository = creditRepository;

  final TransactionRepository _transactionRepository;
  final CreditRepository _creditRepository;

  Stream<List<TransactionEntity>> call({required String accountId}) {
    return _combineLatest(
      _transactionRepository.watchRecentTransactions(),
      _creditRepository.watchCredits(),
      (List<TransactionEntity> transactions, List<CreditEntity> credits) {
        final Map<String, String> creditAccountByCategoryId = <String, String>{
          for (final CreditEntity credit in credits) ...<String, String>{
            if (credit.categoryId != null && credit.categoryId!.isNotEmpty)
              credit.categoryId!: credit.accountId,
            if (credit.interestCategoryId != null &&
                credit.interestCategoryId!.isNotEmpty)
              credit.interestCategoryId!: credit.accountId,
            if (credit.feesCategoryId != null &&
                credit.feesCategoryId!.isNotEmpty)
              credit.feesCategoryId!: credit.accountId,
          },
        };
        final Iterable<TransactionEntity> filtered = transactions.where((
          TransactionEntity transaction,
        ) {
          if (transaction.accountId == accountId ||
              transaction.transferAccountId == accountId) {
            return true;
          }
          final String? categoryId = transaction.categoryId;
          if (categoryId == null || categoryId.isEmpty) {
            return false;
          }
          return creditAccountByCategoryId[categoryId] == accountId;
        });
        return List<TransactionEntity>.unmodifiable(filtered);
      },
    );
  }
}

Stream<T> _combineLatest<A, B, T>(
  Stream<A> a,
  Stream<B> b,
  T Function(A, B) mapper,
) {
  late StreamController<T> controller;
  A? lastA;
  B? lastB;
  bool hasA = false;
  bool hasB = false;

  void emitIfReady() {
    if (hasA && hasB) {
      controller.add(mapper(lastA as A, lastB as B));
    }
  }

  controller = StreamController<T>(
    onListen: () {
      int doneCount = 0;
      void handleDone() {
        doneCount += 1;
        if (doneCount >= 2 && !controller.isClosed) {
          controller.close();
        }
      }

      final StreamSubscription<A> subA = a.listen(
        (A value) {
          lastA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      final StreamSubscription<B> subB = b.listen(
        (B value) {
          lastB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: handleDone,
      );
      controller.onCancel = () async {
        await subA.cancel();
        await subB.cancel();
      };
    },
  );

  return controller.stream;
}
