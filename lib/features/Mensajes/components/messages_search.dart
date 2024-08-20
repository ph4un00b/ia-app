import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/Mensajes/mensajes_controller.dart';
import 'package:lola_ai_app/features/core/debounce.dart';

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
