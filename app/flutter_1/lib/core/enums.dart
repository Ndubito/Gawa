enum UserStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  suspended('SUSPENDED');

  final String value; // The string value that matches the backend representation.
  const UserStatus(this.value); //constructor

  static UserStatus fromString(String v) =>
      UserStatus.values.firstWhere((e) => e.value == v); // Helper method to convert from string to enum.
}
  
enum Currency {
  kes('KES'),
  usd('USD'),
  eur('EUR');

  final String value;
  const Currency(this.value);

  static Currency fromString(String v) =>
      Currency.values.firstWhere((e) => e.value == v);
}

enum SubscriptionStatus {
  active('ACTIVE'),
  paused('PAUSED'),
  cancelled('CANCELLED');

  final String value;
  const SubscriptionStatus(this.value);

  static SubscriptionStatus fromString(String v) =>
      SubscriptionStatus.values.firstWhere((e) => e.value == v);
}

enum SubscriptionSchedule {
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY');

  final String value;
  const SubscriptionSchedule(this.value);

  static SubscriptionSchedule fromString(String v) =>
      SubscriptionSchedule.values.firstWhere((e) => e.value == v);
}

enum ShareType {
  fixed('FIXED'),
  percentage('PERCENTAGE');

  final String value;
  const ShareType(this.value);

  static ShareType fromString(String v) =>
      ShareType.values.firstWhere((e) => e.value == v);
}

enum CycleStatus {
  upcoming('UPCOMING'),
  active('ACTIVE'),
  closed('CLOSED');

  final String value;
  const CycleStatus(this.value);

  static CycleStatus fromString(String v) =>
      CycleStatus.values.firstWhere((e) => e.value == v);
}

enum ObligationStatus {
  pending('PENDING'),
  partial('PARTIAL'),
  paid('PAID'),
  cancelled('CANCELLED'),
  overdue('OVERDUE');

  final String value;
  const ObligationStatus(this.value);

  static ObligationStatus fromString(String v) =>
      ObligationStatus.values.firstWhere((e) => e.value == v);
}

enum ObligationSourceType {
  subscriptionCycle('SUBSCRIPTION_CYCLE'),
  expense('EXPENSE');

  final String value;
  const ObligationSourceType(this.value);

  static ObligationSourceType fromString(String v) =>
      ObligationSourceType.values.firstWhere((e) => e.value == v);
}

enum PaymentStatus {
  pending('PENDING'),
  succeeded('SUCCEEDED'),
  failed('FAILED'),
  refunded('REFUNDED');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String v) =>
      PaymentStatus.values.firstWhere((e) => e.value == v);
}
