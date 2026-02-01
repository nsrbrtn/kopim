import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_providers.g.dart';

@riverpod
Stream<List<CreditPaymentScheduleEntity>> creditSchedule(
  Ref ref,
  String creditId,
) {
  final CreditRepository repository = ref.watch(creditRepositoryProvider);
  return repository.watchSchedule(creditId);
}

@riverpod
Future<CreditPaymentScheduleEntity?> nextUpcomingPayment(
  Ref ref,
  String creditId,
) async {
  final List<CreditPaymentScheduleEntity> schedule =
      await ref.watch(creditScheduleProvider(creditId).future);
  if (schedule.isEmpty) return null;

  // Filter for planned or partially paid items and sort by due date
  final List<CreditPaymentScheduleEntity> upcoming =
      schedule
          .where(
            (CreditPaymentScheduleEntity item) =>
                item.status == CreditPaymentStatus.planned ||
                item.status == CreditPaymentStatus.partiallyPaid,
          )
          .toList()
        ..sort(
          (CreditPaymentScheduleEntity a, CreditPaymentScheduleEntity b) =>
              a.dueDate.compareTo(b.dueDate),
        );

  return upcoming.isNotEmpty ? upcoming.first : null;
}
