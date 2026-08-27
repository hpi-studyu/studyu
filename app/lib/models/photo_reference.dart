/// A reference to a photo from the device gallery.
class PhotoReference {
  /// Creates a new [PhotoReference].
  const PhotoReference({
    required this.id,
    required this.createDateTime,
    this.thumbnailPath,
    this.isSelected = false,
  });

  /// Unique identifier from photo_manager.
  final String id;

  /// Time the photo was taken.
  final DateTime createDateTime;

  /// Local thumbnail path for display.
  final String? thumbnailPath;

  /// Whether this photo is selected by the user.
  final bool isSelected;

  /// Creates a copy of this [PhotoReference] with the given fields replaced.
  PhotoReference copyWith({
    String? id,
    DateTime? createDateTime,
    String? thumbnailPath,
    bool? isSelected,
  }) {
    return PhotoReference(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
