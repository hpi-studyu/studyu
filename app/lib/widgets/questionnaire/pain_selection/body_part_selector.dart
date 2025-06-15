import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/pain_selection/svg_service.dart';
import 'package:studyu_core/core.dart';
import 'package:touchable/touchable.dart';

typedef PainEditResult = ({
  String parentPartId,
  String childPartId,
  BodyPain pain
});

/// A widget that allows for selecting body parts and displays their pain level.
/// When a body part is tapped, a dialog is shown to select the pain level, type, and specific location.
class BodyPartSelector extends StatelessWidget {
  const BodyPartSelector({
    required this.body,
    required this.side,
    this.onPainChanged,
    this.scale = WongBakerScale.english,
    this.unselectedColor,
    this.unselectedOutlineColor,
    super.key,
  });

  final Body body;

  final BodySide side;

  final void Function(
      String parentPartId, String childPartId, BodyPain newPain)? onPainChanged;

  final WongBakerScale scale;

  final Color? unselectedColor;

  final Color? unselectedOutlineColor;

  Future<void> _showPainSelectorDialog(
    BuildContext context,
    String partId,
  ) async {
    final part = body.allPartsById[partId];
    if (part == null) {
      return;
    }

    final result = await showDialog<PainEditResult>(
      context: context,
      builder: (context) => PainEditDialog(
        tappedPart: part,
        scale: scale,
      ),
    );

    if (result != null && context.mounted) {
      onPainChanged?.call(result.parentPartId, result.childPartId, result.pain);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = SvgService.instance.getSide(side);
    return ValueListenableBuilder<SvgData?>(
      valueListenable: notifier,
      builder: (context, svgData, _) {
        if (svgData == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else {
          return _buildBody(context, svgData);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, SvgData svgData) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: LayoutBuilder(
        key: ValueKey(Object.hash(body, side)),
        builder: (context, constraints) {
          final size = Size.square(min(
              constraints.maxWidth,
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : constraints.maxWidth));

          return SizedBox(
            width: size.width,
            height: size.height,
            child: CanvasTouchDetector(
              gesturesToOverride: const [GestureType.onTapDown],
              builder: (context) => CustomPaint(
                size: size,
                painter: _BodyPainter(
                  pictureInfo: svgData.pictureInfo,
                  bodyPartPaths: svgData.paths,
                  body: body,
                  onTap: (id) => _showPainSelectorDialog(context, id),
                  context: context,
                  scale: scale,
                  unselectedColor: unselectedColor ??
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  unselectedOutlineColor: unselectedOutlineColor ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.pictureInfo,
    required this.bodyPartPaths,
    required this.body,
    required this.onTap,
    required this.context,
    required this.scale,
    required this.unselectedColor,
    required this.unselectedOutlineColor,
  });

  final PictureInfo pictureInfo;

  final Map<String, ui.Path> bodyPartPaths;
  final BuildContext context;
  final void Function(String) onTap;
  final Body body;
  final WongBakerScale scale;
  final Color unselectedColor;
  final Color unselectedOutlineColor;

  int getPainLevel(String key) => body.allPartsById[key]?.pain.painLevel ?? 0;

  ({Color fill, Color stroke}) _getPainColors(int painLevel) {
    if (painLevel == 0) {
      return (fill: unselectedColor, stroke: unselectedOutlineColor);
    }

    final scalePoints = scale.levels.keys.where((p) => p > 0).toList()..sort();
    if (scalePoints.isEmpty) {
      return (fill: Colors.red, stroke: Colors.white);
    }

    final firstPainPoint = scalePoints.first;
    if (painLevel >= scalePoints.last) {
      final style = scale.levels[scalePoints.last]!;
      return (fill: style.color, stroke: style.textColor);
    }

    final lowerBound = scalePoints.lastWhere((p) => p <= painLevel,
        orElse: () => firstPainPoint);
    final upperBound =
        scalePoints.firstWhere((p) => p >= painLevel, orElse: () => lowerBound);

    if (lowerBound == upperBound) {
      final style = scale.levels[lowerBound]!;
      return (fill: style.color, stroke: style.textColor);
    }

    final lowerStyle = scale.levels[lowerBound]!;
    final upperStyle = scale.levels[upperBound]!;
    final t = (painLevel - lowerBound) / (upperBound - lowerBound);

    final fillColor = Color.lerp(lowerStyle.color, upperStyle.color, t)!;
    final strokeColor =
        Color.lerp(lowerStyle.textColor, upperStyle.textColor, t)!;

    return (fill: fillColor, stroke: strokeColor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final viewBox = pictureInfo.size;
    final double scaleFactor = min(
      size.width / viewBox.width,
      size.height / viewBox.height,
    );
    final scaledHalfViewBoxSize = viewBox * scaleFactor / 2.0;
    final halfDesiredSize = size / 2.0;
    final shift = Offset(
      halfDesiredSize.width - scaledHalfViewBoxSize.width,
      halfDesiredSize.height - scaledHalfViewBoxSize.height,
    );
    final fittingMatrix = Matrix4.identity()
      ..translate(shift.dx, shift.dy)
      ..scale(scaleFactor);

    canvas.save();
    canvas.transform(fittingMatrix.storage);
    canvas.clipRect(Rect.fromLTWH(0, 0, viewBox.width, viewBox.height));
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();

    final touchyCanvas = TouchyCanvas(context, canvas);

    for (final entry in bodyPartPaths.entries) {
      final id = entry.key;
      final path = entry.value;

      final painLevel = getPainLevel(id);
      final colors = _getPainColors(painLevel);
      final bodyPartPath = path.transform(fittingMatrix.storage);

      touchyCanvas.drawPath(
        bodyPartPath,
        Paint()
          ..color = colors.fill
          ..style = PaintingStyle.fill,
        onTapDown: (_) => onTap(id),
      );

      canvas.drawPath(
        bodyPartPath,
        Paint()
          ..color = colors.stroke
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class PainEditDialog extends StatefulWidget {
  const PainEditDialog({
    required this.tappedPart,
    required this.scale,
    super.key,
  });

  final BodyPart tappedPart;
  final WongBakerScale scale;

  @override
  State<PainEditDialog> createState() => _PainEditDialogState();
}

class _PainEditDialogState extends State<PainEditDialog> {
  late int _currentPain;
  late PainType _selectedPainType;
  late String _selectedPartId;
  late List<BodyPart> _selectableParts;

  @override
  void initState() {
    super.initState();
    final mostSpecificPainfulPart = _findMostSpecificPain(widget.tappedPart);

    _currentPain = mostSpecificPainfulPart.pain.painLevel;
    _selectedPainType = mostSpecificPainfulPart.pain.type;
    _selectedPartId = mostSpecificPainfulPart.id;

    _selectableParts = _flattenHierarchy(widget.tappedPart);
  }

  BodyPart _findMostSpecificPain(BodyPart part) {
    for (final child in part.children) {
      final result = _findMostSpecificPain(child);
      if (result.pain.painLevel > 0) {
        return result;
      }
    }
    return part;
  }

  List<BodyPart> _flattenHierarchy(BodyPart part) {
    final list = [part];
    for (final child in part.children) {
      list.addAll(_flattenHierarchy(child));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scalePoints = widget.scale.levels.keys.toList()..sort();
    final painLevelKey = scalePoints.lastWhere((p) => p <= _currentPain,
        orElse: () => scalePoints.first);
    final painInfo = widget.scale.levels[painLevelKey]!;

    return AlertDialog(
      title: Text(widget.scale.dialogTitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          .copyWith(top: 20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: painInfo.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(painInfo.face, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    painInfo.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: painInfo.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${widget.scale.painIndicatorText}: $_currentPain',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: painInfo.textColor.withAlpha(204),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Slider(
              value: _currentPain.toDouble(),
              max: Body.maxPainLevel.toDouble(),
              divisions: Body.maxPainLevel,
              label: _currentPain.toString(),
              onChanged: (value) {
                setState(() => _currentPain = value.round());
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PainType>(
              value: _selectedPainType,
              decoration: InputDecoration(
                labelText: loc.painTypeLabel,
                border: const OutlineInputBorder(),
              ),
              items: PainType.values.map((PainType type) {
                return DropdownMenuItem<PainType>(
                  value: type,
                  child:
                      Text(type.name[0].toUpperCase() + type.name.substring(1)),
                );
              }).toList(),
              onChanged: (PainType? newValue) {
                if (newValue != null) {
                  setState(() => _selectedPainType = newValue);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_selectableParts.length > 1)
              DropdownButtonFormField<String>(
                value: _selectedPartId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: loc.bodyPartLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _selectableParts.map((BodyPart part) {
                  return DropdownMenuItem<String>(
                    value: part.id,
                    child: Text(
                      part.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedPartId = newValue);
                  }
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.scale.cancelButton),
        ),
        FilledButton(
          onPressed: () {
            final result = (
              parentPartId: widget.tappedPart.id,
              childPartId: _selectedPartId,
              pain: BodyPain(
                painLevel: _currentPain,
                type: _selectedPainType,
              )
            );
            Navigator.of(context).pop(result);
          },
          child: Text(widget.scale.okButton),
        ),
      ],
    );
  }
}

@immutable
class PainLevelStyle {
  const PainLevelStyle({
    required this.face,
    required this.description,
    required this.color,
    this.textColor = Colors.white,
  });

  final String face;
  final String description;
  final Color color;
  final Color textColor;
}

@immutable
class WongBakerScale {
  const WongBakerScale({
    required this.dialogTitle,
    required this.painIndicatorText,
    required this.okButton,
    required this.cancelButton,
    required this.levels,
  });

  final String dialogTitle;
  final String painIndicatorText;
  final String okButton;
  final String cancelButton;
  final Map<int, PainLevelStyle> levels;

  static const WongBakerScale english = WongBakerScale(
    dialogTitle: 'Select Pain Details',
    painIndicatorText: 'Pain',
    okButton: 'Save',
    cancelButton: 'Cancel',
    levels: {
      0: PainLevelStyle(
          face: '😄', description: 'No Hurt', color: Color(0xFF4CAF50)),
      2: PainLevelStyle(
          face: '😊',
          description: 'Hurts Little Bit',
          color: Color(0xFFFFCC80),
          textColor: Colors.black87),
      4: PainLevelStyle(
          face: '😐',
          description: 'Hurts Little More',
          color: Color(0xFFFFA726),
          textColor: Colors.black87),
      6: PainLevelStyle(
          face: '😕', description: 'Hurts Even More', color: Color(0xFFFF7043)),
      8: PainLevelStyle(
          face: '😢', description: 'Hurts Whole Lot', color: Color(0xFFF44336)),
      10: PainLevelStyle(
          face: '😭', description: 'Hurts Worst', color: Color(0xFFB71C1C)),
    },
  );
}
