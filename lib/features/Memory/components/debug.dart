import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/LocalStore/local_store.dart';
import 'package:lola_ai_app/features/Lola/lola_stream.dart';

class DebugMemoryReadFile extends StatelessWidget {
  const DebugMemoryReadFile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card(
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          onTap: () => LocalStore.read("jamon.md"),
          child: const Center(child: Text('read memory file')),
        ),
      ),
    );
  }
}

class DebugMemorySaveFile extends StatelessWidget {
  const DebugMemorySaveFile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card(
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          onTap: () => LocalStore.save("jamon.md"),
          child: const Center(child: Text('save memory file')),
        ),
      ),
    );
  }
}

class DebugMemory extends StatelessWidget {
  const DebugMemory({
    super.key,
    required this.lola,
  });

  final Lola$ lola;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card.filled(
        child: InkWell(
          splashColor: Colors.purple.withAlpha(30),
          onTap: () async =>
              lola.loadReply(input: 'hola lola que debo hacer los viernes?'),
          child: const Center(child: Text('test lola with memory')),
        ),
      ),
    );
  }
}
