import 'package:flutter/material.dart';

/// Fonte única de cores do app.
///
/// Para alterar a identidade visual, mude apenas as constantes abaixo.
/// A cor [primary] é a cor geral/principal do app.
class AppColors {
  // ===========================================================================
  // COR PRINCIPAL DO APP (azul — remete a confiança/dinheiro)
  // Altere estes 3 valores para trocar a cor geral do app.
  // ===========================================================================
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF5E92F3);
  static const primaryDark = Color(0xFF003C8F);

  // Cor secundária / destaque
  static const secondary = Color(0xFF00897B);
  static const secondaryLight = Color(0xFF4EBAAA);
  static const secondaryDark = Color(0xFF005B4F);

  // Categorias de transação
  static const income = Color(0xFF43A047);
  static const expense = Color(0xFFE53935);
  static const creditCard = Color(0xFF5E35B1);
  static const savings = Color(0xFF00897B);

  // Status
  static const pending = Color(0xFFFF9800);
  static const paid = Color(0xFF43A047);
  static const overdue = Color(0xFFEF5350);

  // Neutros
  static const background = Color(0xFFF4F6F9);
  static const surface = Colors.white;
  static const surfaceDark = Color(0xFF121212);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);

  // Feedback
  static const success = Color(0xFF43A047);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
}
