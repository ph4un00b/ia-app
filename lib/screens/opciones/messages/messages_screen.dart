import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/App/components/setting_text.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/features/core/constants.dart';
import 'package:lola_ai_app/features/core/debounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesScreen extends StatefulWidget {
  final List<String> items;
  const MessagesScreen({super.key, required this.items});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final controller = MessagesController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MessagesTitle(),
      ),
      body: Container(
        padding: const EdgeInsets.all(18),
        child: MessageChildren(controller: controller),
      ),
    );
  }
}

class MessagesTitle extends StatelessWidget {
  const MessagesTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Mensajes - Sr. Luis',
      style: GoogleFonts.satisfy(
        textStyle: Theme.of(context).textTheme.displayLarge,
        fontSize: 28,
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}

class SingleMessage<T1, T2, T3> {
  final T1 title;
  final T2 content;
  final T3 from;
  final String? path;
  final DateTime createdAt;

  SingleMessage(this.title, this.content, this.from, this.path, this.createdAt);
}

class MessageChildren extends StatefulWidget {
  final MessagesController controller;

  const MessageChildren({
    super.key,
    required this.controller,
  });

  @override
  State<MessageChildren> createState() => _MessageChildrenState();
}

class _MessageChildrenState extends State<MessageChildren> {
  Stream<MessagesScreenState>? screenState;
  var scale = Constants.scale;

  @override
  void initState() {
    super.initState();
    _loadUserPrefereces();
    screenState = widget.controller.messagesState.stream;
    widget.controller.loadInitialMessages();
  }

  Future<void> _loadUserPrefereces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scale = prefs.getDouble('app-setting-messages') ?? Constants.scale;
    });
  }

  @override
  void dispose() {
    debugPrint('disposing messages screen');
    super.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SettingAppText(
            scale: scale,
            onChangedValue: (value) async {
              setState(() => scale = value);
              final prefs = await SharedPreferences.getInstance();
              prefs.setDouble(
                'app-setting-messages',
                value,
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: MessagesSearch(controller: widget.controller, scale: scale),
        ),
        const SizedBox(height: 18),
        // Expanded(
        //   flex: 1,
        //   child: MessagesCalendar(),
        // ),
        // const SizedBox(height: 18),
        Expanded(
          flex: 8,
          child: StreamBuilder(
            stream: screenState,
            builder: (_, snap) {
              final state = snap.data;
              return switch (state) {
                null => Container(),
                Initial() => Container(),
                Fetching() => const Center(child: CircularProgressIndicator()),
                Success() => MessagesList(
                    controller: widget.controller,
                    items: state.messages,
                    scale: scale),
                Error() => Center(child: Text(state.err.toString())),
              };
            },
          ),
        ),
      ],
    );
  }
}

// class MessagesContainer extends StatelessWidget {
//   const MessagesContainer({
//     super.key,
//     required PostgrestTransformBuilder<List<Map<String, dynamic>>> future,
//     required this.widget,
//   }) : _future = future;

//   final PostgrestTransformBuilder<List<Map<String, dynamic>>> _future;
//   final MessageChildren widget;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _future,
//       builder: (_, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final items = widget.controller.messagesFrom(snapshot.data!);
//         return MessagesList(items: items);
//       },
//     );
//   }
// }

class MessagesSearch extends StatefulWidget {
  final MessagesController controller;
  final double scale;

  const MessagesSearch({
    super.key,
    required this.controller,
    required this.scale,
  });

  @override
  State<MessagesSearch> createState() => _MessagesSearchState();
}

class _MessagesSearchState extends State<MessagesSearch> {
  // The query currently being searched for. If null, there is no pending
  // request.
  String? _searchingWithQuery;

  // The most recent options received from the API.
  late Iterable<Widget> _lastOptions = <Widget>[];

  final _debounce = Debounce(ms: 500);

  @override
  Widget build(BuildContext _) {
    return Card(
      child: SearchAnchor(
        builder: (BuildContext _, SearchController searchController) {
          return SearchBar(
            // TODO: look for advantages of using WidgetStatePropertyAll api!
            textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 24 * widget.scale),
            ),
            onSubmitted: (value) => debugPrint('onSubmitted: $value'),
            controller: searchController,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            // onTap: () {
            //   debugPrint('onTap');
            //   controller.openView();
            // },
            onChanged: (value) {
              _debounce.callback(() {
                debugPrint('onChanged: $value');
                widget.controller.search(value);
              });
            },
            textInputAction: TextInputAction.search,
            leading: Icon(Icons.search, size: 24 * widget.scale),
            // trailing: <Widget>[
            //   Tooltip(
            //     message: 'Change brightness mode',
            //     child: IconButton(
            //       isSelected: false,
            //       onPressed: () {},
            //       icon: const Icon(Icons.wb_sunny_outlined),
            //       selectedIcon: const Icon(Icons.brightness_2_outlined),
            //     ),
            //   )
            // ],
          );
        },
        viewBuilder: null,
        suggestionsBuilder: buildList,
      ),
    );
  }

  FutureOr<Iterable<Widget>> buildList(
    BuildContext _,
    SearchController searchController,
  ) async {
    _searchingWithQuery = searchController.text;

    // final List<String> options =
    //     await widget.controller.search(_searchingWithQuery!);

    // If another search happened after this one, throw away these options.
    // Use the previous options instead and wait for the newer request to
    // finish.
    if (_searchingWithQuery != searchController.text) {
      return _lastOptions;
    }

    // _lastOptions = List<Card>.generate(
    //   options.length,
    //   (int index) {
    //     final String item = options[index];
    //     return Card(
    //       clipBehavior: Clip.hardEdge,
    //       child: InkWell(
    //         onTap: () {},
    //         splashColor: Colors.purple.withAlpha(30),
    //         child: Text(
    //           item,
    //           textScaler: const TextScaler.linear(2.6),
    //           maxLines: 4,
    //           softWrap: true,
    //           overflow: TextOverflow.ellipsis,
    //         ),
    //       ),
    //     );
    //   },
    // );

    return _lastOptions;
  }
}

class MessagesCalendar extends StatelessWidget {
  const MessagesCalendar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.purple.withAlpha(30),
        onTap: () => {},
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  final List<SingleMessage<String, String, String>> items;
  final double scale;

  final MessagesController controller;

  const MessagesList({
    super.key,
    required this.items,
    required this.scale,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // prototypeItem: ListTile(
      //   title: Text(items.first),
      // ),
      itemBuilder: (_, index) {
        return items[index].from == "user"
            ? MessageUser(items: items, index: index, scale: scale)
            : MessageLola(
                controller: controller,
                items: items,
                audioPath: items[index].path,
                index: index,
                scale: scale);
      },
    );
  }
}

class MessageLola extends StatelessWidget {
  final MessagesController controller;
  final String? audioPath;

  const MessageLola({
    super.key,
    required this.items,
    required this.index,
    required this.scale,
    required this.controller,
    required this.audioPath,
  });

  final int index;
  final List<SingleMessage<String, String, String>> items;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text(
              timeago.format(items[index].createdAt, locale: "es"),
              textScaler: TextScaler.linear(1.2 * scale),
            ),
            onPressed: () {/* ... */},
          ),
          ListTile(
            // leading: const Icon(Icons.verified_user),
            // title: Text(items[index].title),
            subtitle: Text(
              items[index].content,
              textScaler: TextScaler.linear(1.6 * scale),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: TextButton.icon(
              //     label: Text(
              //       'Reproducir',
              //       textScaler: TextScaler.linear(1.0 * scale),
              //     ),
              //     onPressed: () {
              //       if (audioPath != null) {
              //         controller.playSpeech(path: audioPath!);
              //       }
              //     },
              //     icon: const Icon(Icons.play_arrow_rounded),
              //   ),
              // ),
              Expanded(
                child: audioPath != null
                    ? PlayButton(
                        scale: scale,
                        audioPath: audioPath,
                        controller: controller,
                      )
                    : DisabledPlayButton(scale: scale),
              ),
              Expanded(
                child: TextButton(
                  child: Text(
                    'Ver',
                    textScaler: TextScaler.linear(1.4 * scale),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        final content = items[index].content;
                        final kontext = ctx;
                        return Readable(
                          content: content,
                          kontext: kontext,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.scale,
    required this.audioPath,
    required this.controller,
  });

  final double scale;
  final String? audioPath;
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.play_arrow_rounded),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
        // iconColor: Colors.grey[700],
      ),
      onPressed: () {
        if (audioPath != null) {
          controller.playSpeech(path: audioPath!);
        }
      },
      label: Text(
        'Reproducir',
        // style: TextStyle(color: Colors.grey[700]),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}

class DisabledPlayButton extends StatelessWidget {
  const DisabledPlayButton({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.play_arrow_rounded),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
        backgroundColor: Colors.transparent,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
        iconColor: Colors.grey[600],
      ),
      onPressed: null,
      label: Text(
        'Reproducir',
        style: TextStyle(color: Colors.grey[600]),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}

class Readable extends StatelessWidget {
  const Readable({
    super.key,
    required this.content,
    required this.kontext,
  });

  final String content;
  final BuildContext kontext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Slider(
            value: 1.0,
            // value: 1.0,
            min: 0.5,
            max: 3.0,
            // divisions: 5,
            label: '1.0',
            onChanged: null,
            // onChanged: (double value) async {
            //   setState(() => screenScale = value);
            //   final prefs = await SharedPreferences.getInstance();
            //   prefs.setDouble(
            //     'app-setting-full-message-text',
            //     value,
            //   );
            // },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(content),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(kontext);
              },
              child: const Text(
                'Cerrar',
                textScaler: TextScaler.linear(1.4),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageUser extends StatelessWidget {
  const MessageUser({
    super.key,
    required this.items,
    required this.index,
    required this.scale,
  });

  final int index;
  final List<SingleMessage<String, String, String>> items;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text(
              timeago.format(items[index].createdAt, locale: "es"),
              textScaler: TextScaler.linear(1.2 * scale),
            ),
            onPressed: () {/* ... */},
          ),
          ListTile(
            // leading: const Icon(Icons.verified_user),
            // title: Text(items[index].title),
            subtitle: Text(
              items[index].content,
              textScaler: TextScaler.linear(1.6 * scale),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: DisabledPlayButton(scale: scale)),
              Expanded(
                child: TextButton(
                  child: Text(
                    'Ver',
                    textScaler: TextScaler.linear(1.4 * scale),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        final content = items[index].content;
                        final kontext = ctx;
                        return Readable(
                          content: content,
                          kontext: kontext,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
