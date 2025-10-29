class SuggestedPerson {
  final String name;
  final String title;
  final String image;
  bool isConnected;

  SuggestedPerson({
    required this.name,
    required this.title,
    required this.image,
    this.isConnected = false,
  });
}
