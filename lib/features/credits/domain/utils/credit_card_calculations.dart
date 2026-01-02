double calculateCreditCardAvailableLimit({
  required double creditLimit,
  required double balance,
}) {
  return creditLimit + balance;
}

double calculateCreditCardDebt(double balance) {
  return balance < 0 ? -balance : 0;
}
