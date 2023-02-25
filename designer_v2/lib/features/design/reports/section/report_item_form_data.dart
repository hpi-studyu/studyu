import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ReportSectionFormData extends IFormData {

  final bool isPrimary;
  final ReportSection section;
  final void Function() remove;
  final void Function(ReportSection) updateSection;

  ReportSectionFormData(this.isPrimary, this.section, this.remove, this.updateSection);
  get title => null;

  @override
  // TODO: implement id
  FormDataID get id => throw UnimplementedError();

  static fromDomainModel() {
    // TODO
    final List<ReportSectionFormData> reportFormData = [];
    return reportFormData;
  }

  @override
  IFormData copy() {
    // TODO: implement copy
    return ReportSectionFormData();
  }
}
