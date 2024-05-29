import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:adsats_flutter/scaffold/default_widget.dart';

bool rememberDevice = false;

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    safePrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    safePrint('Error signing user out: ${result.exception.message}');
  }
}

Future<void> forgetCurrentDevice() async {
  try {
    await Amplify.Auth.forgetDevice();
    safePrint('Forget device succeeded');
  } on AuthException catch (e) {
    safePrint('Forget device failed with error: $e');
  }
}

Future<void> rememberCurrentDevice() async {
  try {
    await Amplify.Auth.rememberDevice();
    safePrint('Remember device succeeded');
  } on AuthException catch (e) {
    safePrint('Remember device failed with error: $e');
  }
}

class CustomSignInForm extends StatefulWidget {
  const CustomSignInForm({super.key});

  @override
  State<CustomSignInForm> createState() => _CustomSignInFormState();
}

class _CustomSignInFormState extends State<CustomSignInForm> {
  @override
  Widget build(BuildContext context) {
    return AuthenticatorForm(
      child: Column(
        children: [
          SignInFormField.username(),
          SignInFormField.password(),
          CheckboxListTile(
            title: const Text("Remember this device"),
            controlAffinity: ListTileControlAffinity.leading,
            value: rememberDevice,
            onChanged: (value) {
              setState(() {
                rememberDevice = value!;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SignInButton(),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: ForgotPasswordButton(),
          )
        ],
      ),
    );
  }
}

class SignInScafold extends StatelessWidget {
  const SignInScafold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADSATS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // flutter logo
              const Center(child: DefaultLogoWidget()),
              Container(
                constraints:
                    const BoxConstraints(maxWidth: 500.0, minWidth: 100),
                child: const CustomSignInForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomResetPasswordForm extends StatelessWidget {
  const CustomResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // flutter logo
          const Center(child: DefaultLogoWidget()),
          Container(
            constraints: const BoxConstraints(maxWidth: 500.0, minWidth: 100),
            child: ResetPasswordForm(),
          ),
        ],
      ),
    );
  }
}
