class PhotoInfo {
  final String name;
  final String filename;
  final Map<String, String> versions;
  final DateTime timeStamp;

  PhotoInfo({
    required this.name,
    required this.filename,
    required this.versions,
    required this.timeStamp,
  });

  factory PhotoInfo.fromJson(Map<String, dynamic> json) {
    return PhotoInfo(
      name: json['name'],
      filename: json['filename'],
      versions: Map<String, String>.from(json['versions']),
      timeStamp: DateTime.parse(json['timestamp']),
    );
  }
}
