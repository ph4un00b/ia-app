import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lola_ai_app/config/constants.dart';
import 'package:lola_ai_app/features/App/status.dart';
import 'package:lola_ai_app/features/Lola/components/lola_topbar.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:lola_ai_app/screens/voz/chat_screen.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

extension _BuildContextExtensions on BuildContext {
  void handleIdentifiedUser({required nextScreen}) {
    unawaited(AppEvent.userIdentified.track(params: {"user": AppStatus.instance.userId}));
    Navigator.pushNamed(this, nextScreen);
  }

  void showErrorSnackBar(Object error) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(error.toString())));
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  double screenScale = Constants.scale;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AuthListBody());
  }
}

class AuthListBody extends StatelessWidget {
  const AuthListBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24.0, 96.0, 24.0, 24.0),
      children: [
        Column(
          children: [
            const LolaAvatar(size: 84.0),
            const SizedBox(height: 24.0),
            Text("Lola App",
                style: GoogleFonts.satisfy(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                  fontStyle: FontStyle.normal,
                )),
            const SizedBox(height: 24.0),
            SupaEmailAuth(
              redirectTo: _AuthConfig.redirectUrl,
              localization: _AuthConfig.emailLocalization,
              onSignInComplete: (_) => context.handleIdentifiedUser(nextScreen: ChatScreen.routeName),
              onSignUpComplete: (_) => context.handleIdentifiedUser(nextScreen: ChatScreen.routeName),
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
    );
  }
}
