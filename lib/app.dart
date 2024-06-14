import 'package:adsats_flutter/route/sms_route/view_specific_notice/specific_notice_widget.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:adsats_flutter/theme/theme_notifier.dart';
import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/amplifyconfiguration.dart';
import 'package:adsats_flutter/route/route.dart';
import 'package:adsats_flutter/scaffold/scaffold_widget.dart';

final _router = GoRouter(
  initialLocation: '/documents',
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
        builder: (context, state, child) {
          return MyScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/documents',
            builder: (context, state) => const DocumentsWidget(),
          ),
          GoRoute(
            path: '/add-a-document',
            builder: (context, state) => const AddADocument(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileWidget(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpWidget(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsWidget(),
          ),
          GoRoute(
            path: '/resetPassword',
            builder: (context, state) => const CustomResetPasswordForm(),
          ),
          GoRoute(
            path: '/sms',
            builder: (context, state) => const SMSWidget(),
          ),
          GoRoute(
            path: '/compliance',
            builder: (context, state) => const ComplianceWidget(),
          ),
          GoRoute(
            path: '/training',
            builder: (context, state) => const TrainingWidget(),
          ),
          GoRoute(
            path: '/purchases',
            builder: (context, state) => const PurchaseWidget(),
          ),
          GoRoute(
            path: '/send-notices',
            builder: (context, state) => const SendNotices(),
          ),
          GoRoute(
            path: '/:notice_id',
            builder: (context, state) {
              String? noticeID = state.pathParameters["notice_id"];
              if (noticeID != null && noticeID.isNotEmpty) {
                int? parsedID = int.tryParse(noticeID);
                if (parsedID != null) {
                  return SpecificNoticeWidget(
                    documentID: parsedID,
                  );
                }
              }
              return const Placeholder();
            },
          ),
        ]),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      final api = AmplifyAPI();
      final storage = AmplifyStorageS3();
      await Amplify.addPlugins([api, auth, storage]);

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      debugPrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) {
            return ThemeNotifier();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return AuthNotifier();
          },
        )
      ],
      builder: (context, child) => Authenticator(
        authenticatorBuilder: (context, state) {
          switch (state.currentStep) {
            case AuthenticatorStep.signIn:
              return const SignInScafold();
            default:
              return null;
          }
        },
        child: MaterialApp.router(
          builder: Authenticator.builder(),
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: Provider.of<ThemeNotifier>(context).themeMode,
          debugShowMaterialGrid: false,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
