import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/components/action_btn.dart';

class VozEditAction extends StatelessWidget {
  const VozEditAction({super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.edit),
      text: 'Editar',
      scale: scale,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}

class VozEditDisabled extends StatelessWidget {
  const VozEditDisabled({super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.edit),
      text: 'Editar',
      color: Colors.grey,
      scale: scale,
    );
  }
}

class VozRequestAction extends StatelessWidget {
  const VozRequestAction({super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.send),
      text: 'Enviar',
      scale: scale,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}



class VozGrabarAction extends StatelessWidget {
  const VozGrabarAction({super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.record_voice_over_sharp),
      text: 'Grabar',
      // color: Colors.red,
      scale: scale,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}

class VozOpenMessageAction extends StatelessWidget {
  const VozOpenMessageAction({super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.expand_less),
      text: 'Ver Mensaje',
      scale: scale,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}

class VozOpenMessageDisabled extends StatelessWidget {
  const VozOpenMessageDisabled(
      {super.key, required this.scale, this.onPressed});

  final double scale;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButtonAlt(
      icon: const Icon(Icons.expand_less),
      text: 'Ver Mensaje',
      scale: scale,
      color: Colors.grey,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}
