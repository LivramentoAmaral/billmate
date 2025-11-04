import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/category.dart';

/// Serviço de backup e exportação de dados
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Cria backup completo dos dados
  Future<File> createBackup({
    required List<Expense> expenses,
    required List<Group> groups,
    required List<Category> categories,
  }) async {
    try {
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'expenses': expenses.map((e) => _expenseToJson(e)).toList(),
          'groups': groups.map((g) => _groupToJson(g)).toList(),
          'categories': categories.map((c) => _categoryToJson(c)).toList(),
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Salvar em arquivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/billmate_backup_$timestamp.json');

      await file.writeAsString(jsonString);

      debugPrint('✅ Backup criado: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erro ao criar backup: $e');
      rethrow;
    }
  }

  /// Restaura backup dos dados
  Future<Map<String, dynamic>> restoreBackup(File file) async {
    try {
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validar versão
      final version = backupData['version'] as String?;
      if (version != '1.0') {
        throw Exception('Versão de backup não suportada: $version');
      }

      final data = backupData['data'] as Map<String, dynamic>;

      final expenses = (data['expenses'] as List)
          .map((e) => _jsonToExpense(e as Map<String, dynamic>))
          .toList();

      final groups = (data['groups'] as List)
          .map((g) => _jsonToGroup(g as Map<String, dynamic>))
          .toList();

      final categories = (data['categories'] as List)
          .map((c) => _jsonToCategory(c as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Backup restaurado com sucesso');

      return {
        'expenses': expenses,
        'groups': groups,
        'categories': categories,
      };
    } catch (e) {
      debugPrint('❌ Erro ao restaurar backup: $e');
      rethrow;
    }
  }

  /// Exporta despesas para CSV
  Future<File> exportExpensesToCSV(List<Expense> expenses) async {
    try {
      final buffer = StringBuffer();

      // Cabeçalho
      buffer.writeln('ID,Descrição,Valor,Categoria,Data,Status,Tipo');

      // Dados
      for (final expense in expenses) {
        final description = expense.description ?? '';
        final category = expense.categoryId;
        final status = expense.status.name;
        final type = (expense.groupId.isNotEmpty) ? 'Grupo' : 'Pessoal';
        buffer.writeln([
          expense.id,
          _escapeCsv(description),
          expense.amount.toStringAsFixed(2),
          category,
          expense.date.toIso8601String(),
          status,
          type,
        ].join(','));
      }

      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/billmate_expenses_$timestamp.csv');

      await file.writeAsString(buffer.toString());

      debugPrint('✅ Despesas exportadas para CSV: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erro ao exportar para CSV: $e');
      rethrow;
    }
  }

  /// Exporta relatório em formato texto
  Future<File> exportReport({
    required String title,
    required List<Expense> expenses,
    required Map<String, double> categoryTotals,
    required double total,
  }) async {
    try {
      final buffer = StringBuffer();

      // Cabeçalho
      buffer.writeln('=' * 50);
      buffer.writeln(title.toUpperCase());
      buffer.writeln('Gerado em: ${_formatDateTime(DateTime.now())}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      // Resumo
      buffer.writeln('RESUMO GERAL');
      buffer.writeln('-' * 50);
      buffer.writeln('Total de despesas: ${expenses.length}');
      buffer.writeln('Valor total: ${_formatCurrency(total)}');
      buffer.writeln();

      // Por categoria
      buffer.writeln('POR CATEGORIA');
      buffer.writeln('-' * 50);
      categoryTotals.forEach((category, value) {
        buffer.writeln('$category: ${_formatCurrency(value)}');
      });
      buffer.writeln();

      // Despesas detalhadas
      buffer.writeln('DESPESAS DETALHADAS');
      buffer.writeln('-' * 50);
      for (final expense in expenses) {
        final desc = expense.description ?? expense.name;
        final category = expense.categoryId;
        final status = expense.status.name;
        buffer.writeln('• $desc');
        buffer.writeln('  Valor: ${_formatCurrency(expense.amount)}');
        buffer.writeln('  Categoria: $category');
        buffer.writeln('  Data: ${_formatDate(expense.date)}');
        buffer.writeln('  Status: $status');
        buffer.writeln();
      }

      buffer.writeln('=' * 50);
      buffer.writeln('Fim do relatório');

      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/billmate_report_$timestamp.txt');

      await file.writeAsString(buffer.toString());

      debugPrint('✅ Relatório exportado: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erro ao exportar relatório: $e');
      rethrow;
    }
  }

  /// Compartilha arquivo
  Future<void> shareFile(File file, {String? subject}) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'Compartilhar Billmate',
      );
      debugPrint('✅ Arquivo compartilhado: ${file.path}');
    } catch (e) {
      debugPrint('❌ Erro ao compartilhar arquivo: $e');
      rethrow;
    }
  }

  /// Limpa backups antigos (mantém apenas os últimos N)
  Future<void> cleanOldBackups({int keepLast = 5}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('billmate_backup_'))
          .toList();

      // Ordenar por data de modificação (mais recente primeiro)
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Remover excedentes
      if (files.length > keepLast) {
        for (int i = keepLast; i < files.length; i++) {
          await files[i].delete();
          debugPrint('🗑️ Backup antigo removido: ${files[i].path}');
        }
      }

      debugPrint('✅ Limpeza de backups concluída');
    } catch (e) {
      debugPrint('❌ Erro ao limpar backups: $e');
    }
  }

  // ==================== HELPERS ====================

  Map<String, dynamic> _expenseToJson(Expense expense) {
    // Serializa usando o toMap da entidade para garantir compatibilidade
    return expense.toMap();
  }

  Expense _jsonToExpense(Map<String, dynamic> json) {
    // Tenta utilizar o factory fromMap da entidade (espera campos no formato toMap)
    return Expense.fromMap(json);
  }

  Map<String, dynamic> _groupToJson(Group group) {
    return group.toMap();
  }

  Group _jsonToGroup(Map<String, dynamic> json) {
    return Group.fromMap(json);
  }

  Map<String, dynamic> _categoryToJson(Category category) {
    return category.toMap();
  }

  Category _jsonToCategory(Map<String, dynamic> json) {
    return Category.fromMap(json);
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
