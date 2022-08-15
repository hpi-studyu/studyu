import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';

typedef FormDataID = String;

abstract class IFormData {
  FormDataID get id;
  IFormData copy();
}
