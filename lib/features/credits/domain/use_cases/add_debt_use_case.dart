import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';
import 'package:uuid/uuid.dart';

class AddDebtUseCase {
  AddDebtUseCase({
    required DebtRepository debtRepository,
    required CategoryRepository categoryRepository,
    required SaveCategoryUseCase saveCategoryUseCase,
    required Uuid uuid,
  }) : _debtRepository = debtRepository,
       _categoryRepository = categoryRepository,
       _saveCategoryUseCase = saveCategoryUseCase,
       _uuid = uuid;

  final DebtRepository _debtRepository;
  final CategoryRepository _categoryRepository;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final Uuid _uuid;

  static const String returnDebtCategoryName = 'Возврат долга';
  static const String receivedDebtCategoryName = 'Получение одолженных денег';
  static const String _returnDebtColor = '#F59E0B';
  static const String _receivedDebtColor = '#10B981';
  static const PhosphorIconDescriptor _returnDebtIcon = PhosphorIconDescriptor(
    name: 'arrowCounterClockwise',
    style: PhosphorIconStyle.fill,
  );
  static const PhosphorIconDescriptor _receivedDebtIcon =
      PhosphorIconDescriptor(name: 'handCoins', style: PhosphorIconStyle.fill);

  Future<DebtEntity> call({
    required String accountId,
    required String name,
    required MoneyAmount amount,
    required DateTime dueDate,
    String? note,
  }) async {
    final DateTime now = DateTime.now();
    await _ensureSystemCategory(
      name: returnDebtCategoryName,
      type: 'expense',
      color: _returnDebtColor,
      icon: _returnDebtIcon,
      timestamp: now,
    );
    await _ensureSystemCategory(
      name: receivedDebtCategoryName,
      type: 'income',
      color: _receivedDebtColor,
      icon: _receivedDebtIcon,
      timestamp: now,
    );
    final DebtEntity debt = DebtEntity(
      id: _uuid.v4(),
      accountId: accountId,
      name: name,
      amountMinor: amount.minor,
      amountScale: amount.scale,
      dueDate: dueDate,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _debtRepository.addDebt(debt);
    return debt;
  }

  Future<Category> _ensureSystemCategory({
    required String name,
    required String type,
    required String color,
    required PhosphorIconDescriptor icon,
    required DateTime timestamp,
  }) async {
    final Category? existing = await _categoryRepository.findByName(name);
    if (existing != null) {
      if (existing.isDeleted ||
          !existing.isSystem ||
          existing.type != type ||
          existing.color != color ||
          existing.icon != icon) {
        final Category restored = existing.copyWith(
          type: type,
          color: color,
          icon: icon,
          isDeleted: false,
          isSystem: true,
          updatedAt: timestamp,
        );
        await _saveCategoryUseCase.call(restored);
        return restored;
      }
      return existing;
    }
    final Category created = Category(
      id: _uuid.v4(),
      name: name,
      type: type,
      color: color,
      icon: icon,
      createdAt: timestamp,
      updatedAt: timestamp,
      isDeleted: false,
      isSystem: true,
    );
    await _saveCategoryUseCase.call(created);
    return created;
  }
}
