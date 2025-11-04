/// Script para resetar o banco de dados
/// Execute isso uma única vez ao inicializar o app em desenvolvimento
/// Ou chame manualmente quando quiser zerar tudo
import '../data/datasources/local_database.dart';

/// Função para resetar o banco de dados com dados padrão
Future<void> resetDatabaseForDevelopment() async {
  try {
    final database = LocalDatabase();
    print('🔄 Zerando banco de dados...');
    await database.resetDatabaseWithDefaults();
    print('✅ Banco de dados resetado com sucesso!');
    print('📚 Categorias padrão adicionadas:');
    print('   - Alimentação');
    print('   - Transporte');
    print('   - Saúde');
    print('   - Educação');
    print('   - Lazer');
    print('   - Utilidades');
    print('   - Roupas');
    print('   - Casa');
    print('   - Outros');
  } catch (e) {
    print('❌ Erro ao resetar banco de dados: $e');
  }
}

/// Função para apenas deletar o banco (sem recriar)
Future<void> deleteDatabase() async {
  try {
    final database = LocalDatabase();
    print('🗑️  Deletando banco de dados...');
    await database.deleteDatabase();
    print('✅ Banco de dados deletado!');
  } catch (e) {
    print('❌ Erro ao deletar banco de dados: $e');
  }
}
