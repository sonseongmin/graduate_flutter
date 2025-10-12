class StubFileAdapter {
  Future<dynamic> pickVideo() async {
    print('[STUB] File picking not supported on this platform.');
    return null;
  }
}
