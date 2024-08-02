class FakeAPI {
  static const List<String> _kOptions = <String>[
    'aardvark  sda sad as dsa dasdsdsada ds d a flutter: **** onAuthStateChange: AuthChangeEvent.initialSession',
    'bobcat 3422  fds f ds fsd f fdf dsfdsfdsfd Restarted application in 559ms.',
    'chameleon 32 2 r 23 32  f  sd fd f d sf fds ffdsfds flutter: RouteSettings("/voz", null)',
  ];

  // Searches the options, but injects a fake "network" delay.
  static Future<Iterable<String>> search(String query) async {
    await Future<void>.delayed(
        const Duration(seconds: 1)); // Fake 1 second delay.
    if (query == '') {
      return const Iterable<String>.empty();
    }
    return _kOptions.where((String option) {
      return option.contains(query.toLowerCase());
    });
  }
}
