import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ReportItemFormData extends IFormData {
  ReportItemFormData();
  get title => null;

  @override
  // TODO: implement id
  FormDataID get id => throw UnimplementedError();

  static fromDomainModel() {
    // TODO
    final List<ReportItemFormData> reportFormData = [];
    return reportFormData;
  }

  @override
  IFormData copy() {
    // TODO: implement copy
    return ReportItemFormData();
  }
}
