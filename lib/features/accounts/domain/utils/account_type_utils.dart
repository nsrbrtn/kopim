const String kAccountTypeBank = 'bank';
const String kAccountTypeCash = 'cash';
const String kAccountTypeCredit = 'credit';
const String kAccountTypeCreditCard = 'credit_card';
const String kAccountTypeDebt = 'debt';
const String kAccountTypeInvestment = 'investment';
const String kAccountTypeSavings = 'savings';
const String kAccountTypeLegacyUnknown = 'legacy_unknown';
const int kLegacyAccountTypeVersion = 0;
const int kCurrentAccountTypeVersion = 1;

const Set<String> kUserCreatableAccountTypes = <String>{
  kAccountTypeCash,
  kAccountTypeBank,
  kAccountTypeCreditCard,
  kAccountTypeInvestment,
};

const Set<String> kBackfillableAccountTypes = <String>{
  kAccountTypeCash,
  kAccountTypeBank,
  kAccountTypeCredit,
  kAccountTypeCreditCard,
  kAccountTypeDebt,
  kAccountTypeInvestment,
  kAccountTypeSavings,
};

String normalizeAccountType(String value) {
  final String trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return '';
  }

  switch (trimmed) {
    case 'card':
      return kAccountTypeBank;
    case kAccountTypeCash:
    case kAccountTypeBank:
    case kAccountTypeCredit:
    case kAccountTypeCreditCard:
    case kAccountTypeDebt:
    case kAccountTypeInvestment:
    case kAccountTypeSavings:
      return trimmed;
    default:
      return kAccountTypeLegacyUnknown;
  }
}

bool isCanonicalUserCreatableAccountType(String rawType) {
  return kUserCreatableAccountTypes.contains(normalizeAccountType(rawType));
}

String? resolveBackfillAccountType(String rawType) {
  final String normalized = normalizeAccountType(rawType);
  if (normalized.isEmpty ||
      normalized == kAccountTypeLegacyUnknown ||
      !kBackfillableAccountTypes.contains(normalized)) {
    return null;
  }
  return normalized;
}

bool shouldBackfillAccountType(
  String rawType, {
  required int typeVersion,
  int targetTypeVersion = kCurrentAccountTypeVersion,
}) {
  if (typeVersion >= targetTypeVersion) {
    return false;
  }
  return resolveBackfillAccountType(rawType) != null;
}

int resolveStoredAccountTypeVersion(
  String rawType, {
  int currentTypeVersion = kLegacyAccountTypeVersion,
}) {
  if (currentTypeVersion >= kCurrentAccountTypeVersion) {
    return currentTypeVersion;
  }
  return resolveBackfillAccountType(rawType) == null
      ? currentTypeVersion
      : kCurrentAccountTypeVersion;
}

bool isLegacyUnknownAccountType(String rawType) {
  return normalizeAccountType(rawType) == kAccountTypeLegacyUnknown;
}

bool isLegacySavingsAccountType(String rawType) {
  return normalizeAccountType(rawType) == kAccountTypeSavings;
}

bool isCreditAccountType(String rawType) {
  return normalizeAccountType(rawType) == kAccountTypeCredit;
}

bool isCreditCardAccountType(String rawType) {
  return normalizeAccountType(rawType) == kAccountTypeCreditCard;
}

bool isLiabilityAccountType(String rawType) {
  final String type = normalizeAccountType(rawType);
  return type == kAccountTypeCredit ||
      type == kAccountTypeCreditCard ||
      type == kAccountTypeDebt;
}

bool isInvestmentAccountType(String rawType) {
  return normalizeAccountType(rawType) == kAccountTypeInvestment;
}

bool isCashAccountType(String rawType) {
  final String type = normalizeAccountType(rawType);
  return type == kAccountTypeCash ||
      type == kAccountTypeBank ||
      type == kAccountTypeSavings;
}
