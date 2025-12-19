import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/transactions/transaction_list_screen.dart';
import '../presentation/screens/transactions/add_transaction_screen.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/christian/tithe_screen.dart';
import '../data/models/transaction.dart';

class AppRoutes {
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const addTransaction = '/add-transaction';
  static const editTransaction = '/edit-transaction';
  static const calendar = '/calendar';
  static const tithe = '/tithe';
  static const creditCards = '/credit-cards';
  static const settings = '/settings';
}

int _locationToTabIndex(String location) {
  if (location == AppRoutes.transactions) return 1;
  if (location == AppRoutes.calendar) return 2;
  if (location == AppRoutes.tithe) return 3;
  return 0;
}

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final currentIndex = _locationToTabIndex(state.uri.path);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Transações',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendário',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.church),
                label: 'Dízimos',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.dashboard);
                  break;
                case 1:
                  context.go(AppRoutes.transactions);
                  break;
                case 2:
                  context.go(AppRoutes.calendar);
                  break;
                case 3:
                  context.go(AppRoutes.tithe);
                  break;
              }
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          name: 'transactions',
          builder: (context, state) => const TransactionListScreen(),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: AppRoutes.tithe,
          name: 'tithe',
          builder: (context, state) => const TitheScreen(),
        ),
      ],
    ),

    // Routes that should appear above the shell (full screen)
    GoRoute(
      path: AppRoutes.addTransaction,
      name: 'addTransaction',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'];
        TransactionType? transactionType;
        if (type != null) {
          transactionType = TransactionType.values.firstWhere(
            (e) => e.name == type,
            orElse: () => TransactionType.expense,
          );
        }
        return AddTransactionScreen(initialType: transactionType);
      },
    ),
    GoRoute(
      path: '${AppRoutes.editTransaction}/:id',
      name: 'editTransaction',
      builder: (context, state) {
        final transactionId = state.pathParameters['id']!;
        return AddTransactionScreen(transactionId: transactionId);
      },
    ),
  ],
);
