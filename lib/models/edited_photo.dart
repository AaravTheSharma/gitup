class Sticker {
  final String emoji;
  final double x;
  final double y;
  final double scale;
  final double rotation;

  Sticker({
    required this.emoji,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'x': x,
      'y': y,
      'scale': scale,
      'rotation': rotation,
    };
  }

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      emoji: json['emoji'],
      x: json['x'],
      y: json['y'],
      scale: json['scale'],
      rotation: json['rotation'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sticker &&
        other.emoji == emoji &&
        other.x == x &&
        other.y == y &&
        other.scale == scale &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(emoji, x, y, scale, rotation);
}

class CropRegion {
  final double x;
  final double y;
  final double width;
  final double height;

  CropRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }

  factory CropRegion.fromJson(Map<String, dynamic> json) {
    return CropRegion(
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropRegion &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

class EditedPhoto {
  final String imagePath;
  final List<Sticker> stickers;
  final CropRegion? cropRegion;

  EditedPhoto({
    required this.imagePath,
    this.stickers = const [],
    this.cropRegion,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'stickers': stickers.map((sticker) => sticker.toJson()).toList(),
      'cropRegion': cropRegion?.toJson(),
    };
  }

  factory EditedPhoto.fromJson(Map<String, dynamic> json) {
    return EditedPhoto(
      imagePath: json['imagePath'],
      stickers: (json['stickers'] as List)
          .map((stickerJson) => Sticker.fromJson(stickerJson))
          .toList(),
      cropRegion: json['cropRegion'] != null
          ? CropRegion.fromJson(json['cropRegion'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditedPhoto &&
        other.imagePath == imagePath &&
        other.stickers.length == stickers.length &&
        other.cropRegion == cropRegion;
  }

  @override
  int get hashCode => Object.hash(imagePath, stickers, cropRegion);
}
