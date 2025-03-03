import 'package:flutter/material.dart';

class BottomTabs extends StatefulWidget {
  const BottomTabs({
    super.key,
    required double scale,
  }) : _scale = scale;

  final double _scale;

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        elevation: 0.0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        // TODO: shifted will not work since you need to tap the icon itself
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        unselectedFontSize: 14 * widget._scale,
        selectedFontSize: 14 * widget._scale,
        items: [
          BottomNavigationBarItem(
              label: "Mensajes",
              icon: IconButton(
                  // padding: EdgeInsets.all(20),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/opciones/mensajes');
                  },
                  icon: Badge(
                      label: Text("24",
                          style: TextStyle(fontSize: 12 * widget._scale)),
                      backgroundColor: Colors.orangeAccent,
                      textColor: Colors.black87,
                      child: const Icon(Icons.message)))),
          BottomNavigationBarItem(
              label: "Lola",
              icon: IconButton(
                  onPressed: () {},
                  icon: const Badge(
                      // label: Text("24"),
                      backgroundColor: Colors.orangeAccent,
                      textColor: Colors.black87,
                      child: Icon(Icons.auto_awesome_mosaic))))
        ]);
  }
}
