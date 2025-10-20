import '../../domain/entities/expense.dart';
import '../../core/constants/app_constants.dart';

class ExpenseModel {
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

  const ExpenseModel({
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

  // Converter de entidade para modelo
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      name: expense.name,
      description: expense.description,
      amount: expense.amount,
      categoryId: expense.categoryId,
      groupId: expense.groupId,
      createdByUserId: expense.createdByUserId,
      participants: expense.participants,
      type: expense.type,
      status: expense.status,
      date: expense.date,
      dueDate: expense.dueDate,
      isRecurring: expense.isRecurring,
      recurrencePattern: expense.recurrencePattern,
      attachments: expense.attachments,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isSynced: expense.isSynced,
    );
  }

  // Converter para entidade
  Expense toEntity() {
    return Expense(
      id: id,
      name: name,
      description: description,
      amount: amount,
      categoryId: categoryId,
      groupId: groupId,
      createdByUserId: createdByUserId,
      participants: participants,
      type: type,
      status: status,
      date: date,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      attachments: attachments,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'groupId': groupId,
      'createdByUserId': createdByUserId,
      'type': type.name,
      'status': status.name,
      'date': date.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrencePattern': recurrencePattern != null
          ? '${recurrencePattern!.type.name}:${recurrencePattern!.interval}:${recurrencePattern!.endDate?.millisecondsSinceEpoch ?? ''}:${recurrencePattern!.occurrences ?? ''}'
          : null,
      'attachments': attachments?.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Converter de Map (do SQLite)
  factory ExpenseModel.fromMap(
      Map<String, dynamic> map, List<ExpenseParticipant> participants) {
    return ExpenseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      amount: map['amount'] as double,
      categoryId: map['categoryId'] as String,
      groupId: map['groupId'] as String,
      createdByUserId: map['createdByUserId'] as String,
      participants: participants,
      type: ExpenseType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ExpenseType.variable,
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      isRecurring: (map['isRecurring'] as int) == 1,
      recurrencePattern: map['recurrencePattern'] != null
          ? _parseRecurrencePattern(map['recurrencePattern'] as String)
          : null,
      attachments: map['attachments'] != null
          ? (map['attachments'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isSynced: (map['isSynced'] as int) == 1,
    );
  }

  // Método auxiliar para parsear RecurrencePattern de string
  static RecurrencePattern? _parseRecurrencePattern(String value) {
    if (value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length != 4) return null;

    try {
      final type = RecurrenceType.values.firstWhere(
        (e) => e.name == parts[0],
        orElse: () => RecurrenceType.monthly,
      );
      final interval = int.parse(parts[1]);
      final endDate = parts[2].isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2]))
          : null;
      final occurrences = parts[3].isNotEmpty ? int.parse(parts[3]) : null;

      return RecurrencePattern(
        type: type,
        interval: interval,
        endDate: endDate,
        occurrences: occurrences,
      );
    } catch (e) {
      return null;
    }
  }

  ExpenseModel copyWith({
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
    return ExpenseModel(
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
}
