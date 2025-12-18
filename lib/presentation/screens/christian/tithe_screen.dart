import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/bible_verses.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import 'package:go_router/go_router.dart';

class TitheScreen extends StatefulWidget {
  const TitheScreen({super.key});

  @override
  State<TitheScreen> createState() => _TitheScreenState();
}

class _TitheScreenState extends State<TitheScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dízimos e Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories),
            onPressed: () {
              _showBibleVerses();
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalTithe = provider.totalTithe;
          final totalOffering = provider.totalOffering;
          final totalContributed = totalTithe + totalOffering;
          final thisMonthTithes = provider.tithes.where((t) {
            return DateFormatter.isThisMonth(t.date);
          }).toList();
          final thisMonthOfferings = provider.offerings.where((t) {
            return DateFormatter.isThisMonth(t.date);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumo
                _buildSummaryCard(totalTithe, totalOffering, totalContributed),
                const SizedBox(height: 24),

                // Versículo sobre Dízimo
                _buildVerseCard(),
                const SizedBox(height: 24),

                // Gráfico
                if (provider.tithes.isNotEmpty || provider.offerings.isNotEmpty)
                  _buildChart(provider),
                const SizedBox(height: 24),

                // Dízimos deste mês
                Text(
                  'Dízimos deste Mês',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (thisMonthTithes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Nenhum dízimo neste mês')),
                    ),
                  )
                else
                  ...thisMonthTithes.map((t) => _buildTransactionCard(t)),
                const SizedBox(height: 24),

                // Ofertas deste mês
                Text(
                  'Ofertas deste Mês',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (thisMonthOfferings.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Nenhuma oferta neste mês')),
                    ),
                  )
                else
                  ...thisMonthOfferings.map((t) => _buildTransactionCard(t)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddOptions();
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalTithe,
    double totalOffering,
    double totalContributed,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.church, color: AppColors.tithe, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Total Contribuído',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              CurrencyFormatter.format(totalContributed),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.tithe,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Dízimos',
                    totalTithe,
                    Icons.church,
                    AppColors.tithe,
                  ),
                ),
                Container(width: 1, height: 60, color: AppColors.divider),
                Expanded(
                  child: _buildStatItem(
                    'Ofertas',
                    totalOffering,
                    Icons.volunteer_activism,
                    AppColors.offering,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(value),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard() {
    final verse = BibleVerses.getVersesByTopic('tithe').first;
    return Card(
      color: AppColors.tithe.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book, color: AppColors.tithe),
                SizedBox(width: 8),
                Text(
                  'Palavra de Deus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${verse.text}"',
              style: const TextStyle(fontStyle: FontStyle.italic, height: 1.5),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${verse.reference}',
                style: const TextStyle(
                  color: AppColors.tithe,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(TransactionProvider provider) {
    // Últimos 6 meses
    final now = DateTime.now();
    final months = <String, Map<String, double>>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormatter.toMonthYearShort(month);
      months[monthKey] = {'tithe': 0.0, 'offering': 0.0};
    }

    for (var tithe in provider.tithes.where((t) => t.isPaid)) {
      final monthKey = DateFormatter.toMonthYearShort(tithe.date);
      if (months.containsKey(monthKey)) {
        months[monthKey]!['tithe'] = months[monthKey]!['tithe']! + tithe.amount;
      }
    }

    for (var offering in provider.offerings.where((t) => t.isPaid)) {
      final monthKey = DateFormatter.toMonthYearShort(offering.date);
      if (months.containsKey(monthKey)) {
        months[monthKey]!['offering'] =
            months[monthKey]!['offering']! + offering.amount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico (últimos 6 meses)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      months.values.fold<double>(0, (max, m) {
                        final total = m['tithe']! + m['offering']!;
                        return total > max ? total : max;
                      }) *
                      1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months.keys.elementAt(index),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: months.entries.map((entry) {
                    final index = months.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['tithe']! + entry.value['offering']!,
                          color: AppColors.tithe,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final color = transaction.isTithe ? AppColors.tithe : AppColors.offering;
    final icon = transaction.isTithe ? Icons.church : Icons.volunteer_activism;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(transaction.description),
        subtitle: Text(DateFormatter.toDayMonthYear(transaction.date)),
        trailing: Text(
          CurrencyFormatter.format(transaction.amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          context.push('/edit-transaction/${transaction.id}');
        },
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.church, color: AppColors.tithe),
              title: const Text('Adicionar Dízimo'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-transaction?type=tithe');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.volunteer_activism,
                color: AppColors.offering,
              ),
              title: const Text('Adicionar Oferta'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-transaction?type=offering');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBibleVerses() {
    final verses = BibleVerses.getVersesByTopic('tithe');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Versículos sobre Dízimo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verse.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tithe,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${verse.text}"',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
