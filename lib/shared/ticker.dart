class Ticker {
  const Ticker({this.name = "Ticker", this.intervalInMs = 1000});

  final String name;
  final int intervalInMs;

  Stream tick() {
    return Stream.periodic(Duration(milliseconds: intervalInMs));
  }

  @override
  String toString() => name;
}
