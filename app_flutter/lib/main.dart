import 'package:flutter/material.dart';
import 'package:ngirit_app/config/theme.dart';
import 'package:ngirit_app/providers/budget_provider.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/providers/expense_provider.dart';
import 'package:ngirit_app/providers/summaries_provider.dart';
import 'package:ngirit_app/widgets/common/generic/server_down_fallback.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/common/generic/exit_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = CommonProvider();
            provider.checkHealth();
            provider.getFrankfurterCurrencies();
            // provider.getExchangeRate();
            // provider.startHealthCheck();
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<CommonProvider, AuthProvider>(
          create: (_) => AuthProvider(CommonProvider()),
          update: (_, common, __) => AuthProvider(common),
        ),
        ChangeNotifierProxyProvider<CommonProvider, ExpenseProvider>(
          // Use context.read to get the instance created above, NOT a new one
          create: (context) => ExpenseProvider(
            Provider.of<CommonProvider>(context, listen: false),
          ),

          // Update ensures that if CommonProvider notifies, AuthProvider gets the fresh data
          update: (context, common, previousProvider) {
            // If AuthProvider was already created, just update its reference
            if (previousProvider != null) {
              return previousProvider..commonProvider = common;
            }
            return ExpenseProvider(common);
          },
        ),

        ChangeNotifierProxyProvider<CommonProvider, BudgetProvider>(
          // Use context.read to get the instance created above, NOT a new one
          create: (context) => BudgetProvider(
            Provider.of<CommonProvider>(context, listen: false),
          ),

          // Update ensures that if CommonProvider notifies, AuthProvider gets the fresh data
          update: (context, common, previousProvider) {
            // If AuthProvider was already created, just update its reference
            if (previousProvider != null) {
              return previousProvider..commonProvider = common;
            }
            return BudgetProvider(common);
          },
        ),

        ChangeNotifierProxyProvider<CommonProvider, SummariesProvider>(
          // Use context.read to get the instance created above, NOT a new one
          create: (context) => SummariesProvider(
            Provider.of<CommonProvider>(context, listen: false),
          ),

          // Update ensures that if CommonProvider notifies, AuthProvider gets the fresh data
          update: (context, common, previousProvider) {
            // If AuthProvider was already created, just update its reference
            if (previousProvider != null) {
              return previousProvider..commonProvider = common;
            }
            return SummariesProvider(common);
          },
        ),
        // ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        // ChangeNotifierProvider(create: (_) => BudgetProvider()),
        // ChangeNotifierProvider(create: (_) => SummariesProvider()),
      ],
      child: MaterialApp(
        title: 'Ngirit App',
        theme: AppTheme.lightTheme(context),
        home: Consumer<CommonProvider>(
          builder: (context, common, _) {
            if (!common.serverReachable) {
              // 🔥 Close ALL dialogs/routes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
              });

              // return const ServerDownScreen();
              return ExitWrapper(child: ServerDownScreen());
            }
            // return const SizedBox.shrink();
            return ExitWrapper(
              child: Navigator(
                onGenerateRoute: AppRoutes.generateRoute,
                initialRoute: AppRoutes.login,
              ),
            );
          },
        ),
        // darkTheme: AppTheme.darkTheme(context),
        // themeMode: ThemeMode.system,
        // initialRoute: AppRoutes.login,
        // onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
