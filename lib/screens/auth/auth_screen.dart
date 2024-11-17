import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

extension _BuildContextExtensions on BuildContext {
  void navigateToInitialScreen() => Navigator.pushNamed(this, '/initial');

  void showErrorSnackBar(Object error) =>
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
}

abstract class _AuthConfig {
  // TODO: change url scheme
  static const redirectUrl = "myjamon://com.example.lola_ai_app";

  static const emailLocalization = SupaEmailAuthLocalization(
    enterEmail: "Ingresa tu email",
    validEmailError: 'Ingresa un email valido',
    enterPassword: "Ingresa tu contraseña",
    passwordLengthError: 'La contraseña debe tener al menos 6 caracteres',
    signIn: 'Inicia sesión',
    signUp: 'Crear cuenta',
    forgotPassword: '¿Olvidaste tu contraseña?',
    dontHaveAccount: 'Si no tienes una cuenta, ¡crea una aquí!',
    haveAccount: '¿Ya tienes una cuenta? Inicia sesión',
    sendPasswordReset: 'Mandar un correo para restablecer la contraseña',
    backToSignIn: 'Regresar a iniciar sesión',
    unexpectedError: 'Se produjo un error inesperado',
  );
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24.0, 96.0, 24.0, 24.0),
        children: [
          Column(
            children: [
              const Text(
                'Lola App',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24.0),
              SupaEmailAuth(
                redirectTo: _AuthConfig.redirectUrl,
                localization: _AuthConfig.emailLocalization,
                onSignInComplete: (_) => context.navigateToInitialScreen(),
                onSignUpComplete: (_) => context.navigateToInitialScreen(),
                onError: (error) => context.showErrorSnackBar(error),
              ),
              // SupaSocialsAuth(
              //   socialProviders: const [
              //     OAuthProvider.google,
              //     OAuthProvider.github,
              //   ],
              //   redirectUrl: "myjamon://com.example.lola_ai_app",
              //   onSuccess: (session) =>
              //       Navigator.pushNamed(context, '/initial'),
              //   onError: (error) => SnackBar(
              //     content: Text(error.toString()),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
