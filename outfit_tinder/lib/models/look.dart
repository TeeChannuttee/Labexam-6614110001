import 'dart:typed_data';

class Look {
  final String id;
  final String name;
  final String style;
  final int confidenceLevel;
  final String? imagePath;
  final Uint8List? imageBytes; // For web compatibility
  int swipeCount;
  bool isFavorite;

  Look({
    required this.id,
    required this.name,
    required this.style,
    required this.confidenceLevel,
    this.imagePath,
    this.imageBytes,
    this.swipeCount = 0,
    this.isFavorite = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'style': style,
      'confidenceLevel': confidenceLevel,
      'imagePath': imagePath,
      'imageBytes': imageBytes?.toList(),
      'swipeCount': swipeCount,
      'isFavorite': isFavorite,
    };
  }

  // Create from JSON
  factory Look.fromJson(Map<String, dynamic> json) {
    return Look(
      id: json['id'],
      name: json['name'],
      style: json['style'],
      confidenceLevel: json['confidenceLevel'],
      imagePath: json['imagePath'],
      imageBytes: json['imageBytes'] != null 
          ? Uint8List.fromList(List<int>.from(json['imageBytes']))
          : null,
      swipeCount: json['swipeCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Create a copy with modifications
  Look copyWith({
    String? id,
    String? name,
    String? style,
    int? confidenceLevel,
    String? imagePath,
    Uint8List? imageBytes,
    int? swipeCount,
    bool? isFavorite,
  }) {
    return Look(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      swipeCount: swipeCount ?? this.swipeCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
