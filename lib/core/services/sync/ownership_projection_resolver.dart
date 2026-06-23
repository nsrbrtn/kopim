import 'dart:convert';

import 'package:kopim/core/data/database.dart';

const Set<String> kDirectProjectionEntityTypes = <String>{
  'account',
  'category',
  'tag',
  'transaction',
  'budget',
  'budget_instance',
  'saving_goal',
  'upcoming_payment',
  'payment_reminder',
  'debt',
  'credit',
  'credit_card',
  'credit_payment_schedule',
  'credit_payment_group',
};

const Set<String> kExcludedOwnershipEntityTypes = <String>{
  'profile',
  'goal_contribution',
  'progress',
};

const Set<String> kOwnershipStates = <String>{
  'localOnly',
  'cloudOwned',
  'systemDefault',
};

const Set<String> kOwnershipSources = <String>{
  'schema_backfill',
  'local_creation',
  'migration_conversion',
  'import_restore',
  'system_seed',
  'reset_cleanup',
};

class OwnershipLookupException implements Exception {
  const OwnershipLookupException(this.message);

  final String message;

  @override
  String toString() => 'OwnershipLookupException: $message';
}

class OwnershipProjectionResolver {
  const OwnershipProjectionResolver(this._db);

  final AppDatabase _db;

  Future<LocalRowOwnershipRow?> resolveForDispatch({
    required String entityType,
    required String entityId,
    String? payload,
  }) async {
    switch (entityType) {
      case 'transaction_tag':
        return resolveTransactionTagOwnership(payload: payload);
      case 'goal_account_link':
        return resolveGoalAccountLinkOwnership(payload: payload);
      default:
        return _db.getOwnership(entityType, entityId);
    }
  }

  Future<LocalRowOwnershipRow?> resolveTransactionTagOwnership({
    String? payload,
    String? transactionId,
  }) async {
    final String parentTransactionId =
        transactionId ?? _extractRequiredString(payload, 'transactionId');
    return _db.getOwnership('transaction', parentTransactionId);
  }

  Future<LocalRowOwnershipRow?> resolveGoalAccountLinkOwnership({
    String? payload,
    String? goalId,
    String? accountId,
  }) async {
    final String parentGoalId =
        goalId ?? _extractRequiredString(payload, 'goalId');
    return _db.getOwnership('saving_goal', parentGoalId);
  }

  String _extractRequiredString(String? payload, String fieldName) {
    if (payload == null) {
      throw OwnershipLookupException(
        'Payload is required to resolve inherited ownership for $fieldName.',
      );
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (error) {
      throw OwnershipLookupException(
        'Failed to decode payload while resolving $fieldName: $error',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw OwnershipLookupException(
        'Payload must decode to an object while resolving $fieldName.',
      );
    }
    final String? value = decoded[fieldName] as String?;
    if (value == null || value.isEmpty) {
      throw OwnershipLookupException(
        'Payload does not contain required field $fieldName.',
      );
    }
    return value;
  }
}
