import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/credit_card_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? transactionId;
  final TransactionType? initialType;

  const AddTransactionScreen({super.key, this.transactionId, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _installmentsController = TextEditingController(text: '1');

  TransactionType _selectedType = TransactionType.expense;
  TransactionStatus _selectedStatus = TransactionStatus.pending;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedCreditCard;
  bool _isRecurrent = false;
  bool _isLoading = false;
  Transaction? _editingTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransaction();
      context.read<CreditCardProvider>().loadCreditCards();
    });
  }

  Future<void> _loadTransaction() async {
    if (widget.transactionId != null) {
      final provider = context.read<TransactionProvider>();
      _editingTransaction = provider.transactions.firstWhere(
        (t) => t.id == widget.transactionId,
      );

      setState(() {
        _descriptionController.text = _editingTransaction!.description;
        _amountController.text = _editingTransaction!.amount.toStringAsFixed(2);
        _notesController.text = _editingTransaction!.notes ?? '';
        _selectedType = _editingTransaction!.type;
        _selectedStatus = _editingTransaction!.status;
        _selectedDate = _editingTransaction!.date;
        _selectedCategory = _editingTransaction!.category;
        _selectedCreditCard = _editingTransaction!.creditCardId;
        _isRecurrent = _editingTransaction!.isRecurrent;
        if (_editingTransaction!.installments != null) {
          _installmentsController.text = _editingTransaction!.installments
              .toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.income
        ? DefaultCategories.incomeCategories
        : DefaultCategories.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionId != null
              ? AppStrings.editTransaction
              : AppStrings.addTransaction,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de Transação
            const Text(
              'Tipo de Transação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip(
                  TransactionType.expense,
                  'Despesa',
                  Icons.arrow_upward,
                ),
                _buildTypeChip(
                  TransactionType.income,
                  'Receita',
                  Icons.arrow_downward,
                ),
                _buildTypeChip(TransactionType.tithe, 'Dízimo', Icons.church),
                _buildTypeChip(
                  TransactionType.offering,
                  'Oferta',
                  Icons.volunteer_activism,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Ex: Conta de luz',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor *',
                hintText: '0,00',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoria
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma categoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Data
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data'),
              subtitle: Text(
                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const Divider(),

            // Status
            DropdownButtonFormField<TransactionStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: const [
                DropdownMenuItem(
                  value: TransactionStatus.pending,
                  child: Text('Pendente'),
                ),
                DropdownMenuItem(
                  value: TransactionStatus.overdue,
                  child: Text('Atrasado'),
                ),
                DropdownMenuItem(
                  value: TransactionStatus.paid,
                  child: Text('Pago'),
                ),
                DropdownMenuItem(
                  value: TransactionStatus.scheduled,
                  child: Text('Agendado'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Cartão de Crédito (apenas para despesas)
            if (_selectedType == TransactionType.expense)
              Consumer<CreditCardProvider>(
                builder: (context, provider, child) {
                  if (provider.cards.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCreditCard,
                        decoration: const InputDecoration(
                          labelText: 'Cartão de Crédito (Opcional)',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ...provider.cards.map((card) {
                            return DropdownMenuItem(
                              value: card.id,
                              child: Text(card.displayName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCreditCard = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

            // Parcelamento
            if (_selectedCreditCard != null)
              TextFormField(
                controller: _installmentsController,
                decoration: const InputDecoration(
                  labelText: 'Parcelas',
                  hintText: '1',
                  prefixIcon: Icon(Icons.calendar_view_month),
                  suffixText: 'x',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            if (_selectedCreditCard != null) const SizedBox(height: 16),

            // Recorrente
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Transação Recorrente'),
              subtitle: const Text('Repete todo mês'),
              value: _isRecurrent,
              onChanged: (value) {
                setState(() {
                  _isRecurrent = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Observações
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (Opcional)',
                hintText: 'Adicione detalhes...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.transactionId != null
                          ? 'Salvar Alterações'
                          : 'Adicionar Transação',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(TransactionType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    final color = _getColorByType(type);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
          _selectedCategory = null; // Reset category when type changes
        });
      },
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getColorByType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.tithe:
        return AppColors.tithe;
      case TransactionType.offering:
        return AppColors.offering;
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final installments = _selectedCreditCard != null
          ? int.tryParse(_installmentsController.text)
          : null;

      final transaction = Transaction(
        id: widget.transactionId ?? const Uuid().v4(),
        description: _descriptionController.text,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
        status: _selectedStatus,
        category: _selectedCategory!,
        isRecurrent: _isRecurrent,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        creditCardId: _selectedCreditCard,
        installments: installments,
        currentInstallment: installments != null ? 1 : null,
        createdAt: _editingTransaction?.createdAt ?? DateTime.now(),
        updatedAt: widget.transactionId != null ? DateTime.now() : null,
      );

      final provider = context.read<TransactionProvider>();
      if (widget.transactionId != null) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);

        // Se for receita, perguntar se deseja criar dízimo
        if (_selectedType == TransactionType.income && mounted) {
          _askCreateTithe(transaction);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionId != null
                  ? 'Transação atualizada com sucesso!'
                  : 'Transação adicionada com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar transação: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _askCreateTithe(Transaction income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Dízimo?'),
        content: Text(
          'Deseja criar automaticamente o dízimo de ${CurrencyFormatter.format(income.amount * 0.10)} (10% de ${CurrencyFormatter.format(income.amount)})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionProvider>().createTitheFromIncome(income);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dízimo criado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Sim, Criar'),
          ),
        ],
      ),
    );
  }
}
