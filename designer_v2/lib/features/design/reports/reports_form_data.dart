import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';


class ReportsFormData implements IStudyFormData {
  ReportsFormData({
    required this.reportsFormData,
  });

  final List<ReportSectionFormData> reportsFormData;

  factory ReportsFormData.fromStudy(Study study) {
    return ReportsFormData(
      reportsFormData: ReportSectionFormData.fromDomainModel(study.reportSpecification),
    );
  }

  @override
  Study apply(Study study) {
    for (ReportSectionFormData sectionFormData in reportsFormData) {
      if (sectionFormData.isPrimary) {
        study.reportSpecification.primary = sectionFormData.section;
      } else {
        study.reportSpecification.secondary.add(sectionFormData.section);
      }
    }
    return study;
  }

  @override
  IFormData copy() {
    throw UnimplementedError();
  }

  @override
  FormDataID get id => "123"; // todo
}
