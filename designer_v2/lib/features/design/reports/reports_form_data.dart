import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/report/report_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ReportsFormData implements IStudyFormData {
  ReportsFormData({
    required this.reportSpecification,
    required this.reportsFormData,
  });

  final ReportSpecification reportSpecification;
  final List<ReportItemFormData> reportsFormData;

  factory ReportsFormData.fromStudy(Study study) {
    return ReportsFormData(
      reportSpecification: study.reportSpecification,
      reportsFormData: ReportItemFormData.fromDomainModel(),
    );
  }

  @override
  Study apply(Study study) {
    study.reportSpecification = reportSpecification;
    //reportsFormData.apply(study);
    return study;
  }

  @override
  IFormData copy() {
    throw UnimplementedError();
  }

  @override
  FormDataID get id => throw UnimplementedError();

}
