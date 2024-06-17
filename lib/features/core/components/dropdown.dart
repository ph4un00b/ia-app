import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

const List<String> list = <String>['One', 'Two', 'Three', 'Una voz de lola '];

class _DropdownState extends State<Dropdown> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24, 10, 0, 0),
              child: Text(
                'Voz de Lola',
                textScaler: TextScaler.linear(1.6),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: const AlignmentDirectional(-1, 0),
            child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 0, 0),
                child: DropdownMenu<String>(
                  // width: double.infinity, // error
                  textStyle: const TextStyle(fontSize: 20),
                  initialSelection: list.first,
                  onSelected: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  dropdownMenuEntries:
                      list.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(value: value, label: value);
                  }).toList(),
                )),
          ),
        ),
      ],
    );
  }
}
