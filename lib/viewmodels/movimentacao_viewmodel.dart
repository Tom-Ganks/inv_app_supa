// src/view_models/movimentacao_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/movimentacao_model.dart';
import '../repositories/movimentacao_repository.dart';

class MovimentacaoViewModel extends ChangeNotifier {
  final MovimentacaoRepository _repository = MovimentacaoRepository();
  List<Movimentacao> movimentacoes = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchAllMovimentacoes() async {
    try {
      isLoading = true;
      notifyListeners();

      movimentacoes = await _repository.fetchAll();
      error = null;
    } catch (e) {
      error = 'Erro ao carregar movimentações: $e';
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Movimentacao>> fetchByTurma(int turmaId) async {
    try {
      return await _repository.fetchByTurma(turmaId);
    } catch (e) {
      print('Error fetching by turma: $e');
      rethrow;
    }
  }

  Future<List<Movimentacao>> fetchByUsuario(int usuarioId) async {
    try {
      return await _repository.fetchByUsuario(usuarioId);
    } catch (e) {
      print('Error fetching by usuario: $e');
      rethrow;
    }
  }

  Future<bool> insertMovimentacao(Movimentacao movimentacao) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repository.insert(movimentacao);
      await fetchAllMovimentacoes();
      error = null;
      return true;
    } catch (e) {
      error = 'Erro ao inserir movimentação: $e';
      print(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMovimentacao(Movimentacao movimentacao) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repository.update(movimentacao);
      await fetchAllMovimentacoes();
      error = null;
      return true;
    } catch (e) {
      error = 'Erro ao atualizar movimentação: $e';
      print(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMovimentacao(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repository.delete(id);
      await fetchAllMovimentacoes();
      error = null;
      return true;
    } catch (e) {
      error = 'Erro ao deletar movimentação: $e';
      print(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
