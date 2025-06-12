import 'package:json_annotation/json_annotation.dart';

part 'body_parts.g.dart';

/// A class representing the different parts of the body and their associated
/// pain level, built using json_serializable.
@JsonSerializable()
class BodyParts {
  /// The maximum pain level that can be assigned to a body part.
  static const maxPainLevel = 10;

  // Parts with front and back distinction
  final int headFront;
  final int headBack;
  final int neckFront;
  final int neckBack;
  final int chest; // Replaces upperBody front
  final int upperBack; // Replaces upperBody back
  final int abdomen; // Front only
  final int lowerBack; // Back only

  // Limbs and other parts
  final int leftShoulder;
  final int leftUpperArm;
  final int leftElbow;
  final int leftLowerArm;
  final int leftHand;
  final int rightShoulder;
  final int rightUpperArm;
  final int rightElbow;
  final int rightLowerArm;
  final int rightHand;
  final int pelvis; // Front of lowerBody
  final int buttocks; // Back of lowerBody
  final int leftUpperLeg;
  final int leftKnee;
  final int leftLowerLeg;
  final int leftFoot;
  final int rightUpperLeg;
  final int rightKnee;
  final int rightLowerLeg;
  final int rightFoot;
  final int vestibular;

  /// Creates an instance of BodyParts.
  const BodyParts({
    this.headFront = 0,
    this.headBack = 0,
    this.neckFront = 0,
    this.neckBack = 0,
    this.chest = 0,
    this.upperBack = 0,
    this.abdomen = 0,
    this.lowerBack = 0,
    this.leftShoulder = 0,
    this.leftUpperArm = 0,
    this.leftElbow = 0,
    this.leftLowerArm = 0,
    this.leftHand = 0,
    this.rightShoulder = 0,
    this.rightUpperArm = 0,
    this.rightElbow = 0,
    this.rightLowerArm = 0,
    this.rightHand = 0,
    this.pelvis = 0,
    this.buttocks = 0,
    this.leftUpperLeg = 0,
    this.leftKnee = 0,
    this.leftLowerLeg = 0,
    this.leftFoot = 0,
    this.rightUpperLeg = 0,
    this.rightKnee = 0,
    this.rightLowerLeg = 0,
    this.rightFoot = 0,
    this.vestibular = 0,
  });

  /// Creates a new [BodyParts] object from a JSON object.
  factory BodyParts.fromJson(Map<String, dynamic> json) =>
      _$BodyPartsFromJson(json);

  /// Converts this object to a JSON object.
  Map<String, dynamic> toJson() => _$BodyPartsToJson(this);

  /// Returns a new [BodyParts] object with the pain level for the given [id]
  /// updated. Because the class is immutable, this creates a new instance.
  BodyParts withPainLevel(String id, int painLevel) {
    // Convert the current instance to a map.
    final map = toJson();

    // If the key doesn't exist, return the original object.
    if (!map.containsKey(id)) return this;

    // Update the value in the map, clamping it to the allowed range.
    map[id] = painLevel.clamp(0, maxPainLevel);

    // Create a new instance from the updated map.
    return BodyParts.fromJson(map);
  }

  /// Returns a Map representation of this object with int values.
  Map<String, int> toMap() {
    return toJson().map((key, value) => MapEntry(key, value as int));
  }

  /// Returns a list of the names of body parts that have a pain level
  /// greater than 0.
  List<String> get painfulParts {
    return toMap().entries.where((e) => e.value > 0).map((e) => e.key).toList();
  }
}

/// Represents the side from which the body is viewed.
///
/// Values are ordered as if looking at the person from the front, and them
/// then rotating them clockwise, so that their left side is visible next.
enum BodySide {
  /// The front (ventral) side of the body.
  ///
  /// As if looking the person in the face.
  front,

  /// The back (dorsal) side of the body.
  ///
  /// As if looking at the person's back.
  back;

  /// Returns the [BodySide] for the given index.
  static BodySide forIndex(int i) => values[i % values.length];

  /// Maps the side to a value of type [T].
  T map<T>({
    required T front,
    required T back,
  }) {
    switch (this) {
      case BodySide.front:
        return front;
      case BodySide.back:
        return back;
    }
  }
}
