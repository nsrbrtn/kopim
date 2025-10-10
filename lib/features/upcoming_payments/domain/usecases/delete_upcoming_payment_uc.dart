import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

part 'delete_upcoming_payment_uc.freezed.dart';

@freezed
abstract class DeleteUpcomingPaymentInput with _$DeleteUpcomingPaymentInput {
  const factory DeleteUpcomingPaymentInput({required String id}) =
      _DeleteUpcomingPaymentInput;
}

class DeleteUpcomingPaymentUC {
  const DeleteUpcomingPaymentUC({required UpcomingPaymentsRepository repo})
    : _repo = repo;

  final UpcomingPaymentsRepository _repo;

  Future<void> call(DeleteUpcomingPaymentInput input) {
    return _repo.delete(input.id);
  }
}
