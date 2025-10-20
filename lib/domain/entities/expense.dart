import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class Expense {
  final String id;
  final String name;
  final String? description;
  final double amount;
  final String categoryId;
  final String groupId;
  final String createdByUserId;
  final List<ExpenseParticipant> participants;
  final ExpenseType type;
  final ExpenseStatus status;
  final DateTime date;
  final DateTime? dueDate;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Expense({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.categoryId,
    required this.groupId,
    required this.createdByUserId,
    required this.participants,
    required this.type,
    required this.status,
    required this.date,
    this.dueDate,
    this.isRecurring = false,
    this.recurrencePattern,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Expense copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? categoryId,
    String? groupId,
    String? createdByUserId,
    List<ExpenseParticipant>? participants,
    ExpenseType? type,
    ExpenseStatus? status,
    DateTime? date,
    DateTime? dueDate,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      groupId: groupId ?? this.groupId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      participants: participants ?? this.participants,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'groupId': groupId,
      'createdByUserId': createdByUserId,
      'participants': participants.map((p) => p.toMap()).toList(),
      'type': type.name,
      'status': status.name,
      'date': date.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern?.toMap(),
      'attachments': attachments,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      amount: map['amount']?.toDouble() ?? 0.0,
      categoryId: map['categoryId'] ?? '',
      groupId: map['groupId'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      participants: List<ExpenseParticipant>.from(
        map['participants']?.map((x) => ExpenseParticipant.fromMap(x)) ?? [],
      ),
      type: ExpenseType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ExpenseType.variable,
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      isRecurring: map['isRecurring'] ?? false,
      recurrencePattern: map['recurrencePattern'] != null
          ? RecurrencePattern.fromMap(map['recurrencePattern'])
          : null,
      attachments: List<String>.from(map['attachments'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isSynced: map['isSynced'] ?? false,
    );
  }

  factory Expense.create({
    required String name,
    String? description,
    required double amount,
    required String categoryId,
    required String groupId,
    required String createdByUserId,
    required List<ExpenseParticipant> participants,
    required ExpenseType type,
    ExpenseStatus status = ExpenseStatus.pending,
    DateTime? date,
    DateTime? dueDate,
    bool isRecurring = false,
    RecurrencePattern? recurrencePattern,
    List<String>? attachments,
  }) {
    final now = DateTime.now();
    return Expense(
      id: const Uuid().v4(),
      name: name,
      description: description,
      amount: amount,
      categoryId: categoryId,
      groupId: groupId,
      createdByUserId: createdByUserId,
      participants: participants,
      type: type,
      status: status,
      date: date ?? now,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      attachments: attachments,
      createdAt: now,
      updatedAt: now,
    );
  }

  double getTotalAmountForUser(String userId) {
    final participant =
        participants.where((p) => p.userId == userId).firstOrNull;
    return participant?.amount ?? 0.0;
  }

  bool isUserParticipant(String userId) {
    return participants.any((p) => p.userId == userId);
  }

  Expense markAsPaid() {
    return copyWith(
      status: ExpenseStatus.paid,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  Expense markAsPending() {
    return copyWith(
      status: ExpenseStatus.pending,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Expense(id: $id, name: $name, amount: $amount, status: $status)';
  }
}

class ExpenseParticipant {
  final String userId;
  final double amount;
  final double percentage;
  final bool hasPaid;

  const ExpenseParticipant({
    required this.userId,
    required this.amount,
    required this.percentage,
    this.hasPaid = false,
  });

  ExpenseParticipant copyWith({
    String? userId,
    double? amount,
    double? percentage,
    bool? hasPaid,
  }) {
    return ExpenseParticipant(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      hasPaid: hasPaid ?? this.hasPaid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'percentage': percentage,
      'hasPaid': hasPaid,
    };
  }

  factory ExpenseParticipant.fromMap(Map<String, dynamic> map) {
    return ExpenseParticipant(
      userId: map['userId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      percentage: map['percentage']?.toDouble() ?? 0.0,
      hasPaid: map['hasPaid'] ?? false,
    );
  }

  static List<ExpenseParticipant> distributeEqually(
    List<String> userIds,
    double totalAmount,
  ) {
    final amountPerUser = totalAmount / userIds.length;
    final percentage = 100.0 / userIds.length;

    return userIds
        .map((userId) => ExpenseParticipant(
              userId: userId,
              amount: amountPerUser,
              percentage: percentage,
            ))
        .toList();
  }

  static List<ExpenseParticipant> distributeByPercentage(
    Map<String, double> userPercentages,
    double totalAmount,
  ) {
    return userPercentages.entries
        .map((entry) => ExpenseParticipant(
              userId: entry.key,
              amount: (totalAmount * entry.value) / 100,
              percentage: entry.value,
            ))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseParticipant && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'ExpenseParticipant(userId: $userId, amount: $amount, percentage: $percentage%)';
  }
}

enum RecurrenceType { daily, weekly, monthly, yearly }

class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final DateTime? endDate;
  final int? occurrences;

  const RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.endDate,
    this.occurrences,
  });

  RecurrencePattern copyWith({
    RecurrenceType? type,
    int? interval,
    DateTime? endDate,
    int? occurrences,
  }) {
    return RecurrencePattern(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      endDate: endDate ?? this.endDate,
      occurrences: occurrences ?? this.occurrences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'interval': interval,
      'endDate': endDate?.millisecondsSinceEpoch,
      'occurrences': occurrences,
    };
  }

  factory RecurrencePattern.fromMap(Map<String, dynamic> map) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RecurrenceType.monthly,
      ),
      interval: map['interval'] ?? 1,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      occurrences: map['occurrences'],
    );
  }

  DateTime getNextOccurrence(DateTime currentDate) {
    switch (type) {
      case RecurrenceType.daily:
        return currentDate.add(Duration(days: interval));
      case RecurrenceType.weekly:
        return currentDate.add(Duration(days: 7 * interval));
      case RecurrenceType.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + interval,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
      case RecurrenceType.yearly:
        return DateTime(
          currentDate.year + interval,
          currentDate.month,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
    }
  }

  @override
  String toString() {
    return 'RecurrencePattern(type: $type, interval: $interval)';
  }
}
