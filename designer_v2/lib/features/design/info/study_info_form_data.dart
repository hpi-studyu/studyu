import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class StudyInfoFormData implements IStudyFormData {
  StudyInfoFormData({
    required this.title,
    this.description,
    required this.contactInfoFormData,
    required this.iconName,
    required this.lockPublisherInfo,
  });

  final String title;
  final String? description;
  final String iconName;
  final StudyContactInfoFormData contactInfoFormData;
  final bool lockPublisherInfo;

  factory StudyInfoFormData.fromStudy(Study study) {
    return StudyInfoFormData(
      title: study.title ?? '',
      description: study.description ?? '',
      iconName: study.iconName,
      contactInfoFormData: StudyContactInfoFormData.fromStudy(study),
      lockPublisherInfo: study.templateConfiguration?.lockPublisherInformation == true ||
          study.parentTemplate?.templateConfiguration?.lockPublisherInformation == true,
    );
  }

  @override
  Study apply(Study study) {
    study.title = title;
    study.description = description;
    study.iconName = iconName;
    contactInfoFormData.apply(study);
    study.templateConfiguration = study.templateConfiguration?.copyWith(lockPublisherInformation: lockPublisherInfo);
    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}

class StudyContactInfoFormData implements IStudyFormData {
  StudyContactInfoFormData({
    this.organization,
    this.institutionalReviewBoard,
    this.institutionalReviewBoardNumber,
    this.researchers,
    this.email,
    this.website,
    this.phone,
    this.additionalInfo,
  });

  final String? organization;
  final String? institutionalReviewBoard;
  final String? institutionalReviewBoardNumber;
  final String? researchers;
  final String? email;
  final String? website;
  final String? phone;
  final String? additionalInfo;

  factory StudyContactInfoFormData.fromStudy(Study study) {
    final contact = study.contact;
    final templateContactInfo =
        study.parentTemplate != null ? StudyContactInfoFormData.fromStudy(study.parentTemplate!) : null;
    final thisContactInfo = StudyContactInfoFormData(
      organization: contact.organization,
      institutionalReviewBoard: contact.institutionalReviewBoard ?? '',
      institutionalReviewBoardNumber: contact.institutionalReviewBoardNumber ?? '',
      researchers: contact.researchers ?? '',
      email: contact.email,
      website: contact.website,
      phone: contact.phone,
      additionalInfo: contact.additionalInfo,
    );

    return templateContactInfo != null
        ? StudyContactInfoFormData.merge(templateContactInfo, thisContactInfo)
        : thisContactInfo;
  }

  factory StudyContactInfoFormData.merge(StudyContactInfoFormData a, StudyContactInfoFormData b) {
    return StudyContactInfoFormData(
      organization: b.organization != null && b.organization!.isNotEmpty ? b.organization : a.organization,
      institutionalReviewBoard: b.institutionalReviewBoard != null && b.institutionalReviewBoard!.isNotEmpty
          ? b.institutionalReviewBoard
          : a.institutionalReviewBoard,
      institutionalReviewBoardNumber:
          b.institutionalReviewBoardNumber != null && b.institutionalReviewBoardNumber!.isNotEmpty
              ? b.institutionalReviewBoardNumber
              : a.institutionalReviewBoardNumber,
      researchers: b.researchers != null && b.researchers!.isNotEmpty ? b.researchers : a.researchers,
      email: b.email != null && b.email!.isNotEmpty ? b.email : a.email,
      website: b.website != null && b.website!.isNotEmpty ? b.website : a.website,
      phone: b.phone != null && b.phone!.isNotEmpty ? b.phone : a.phone,
      additionalInfo: b.additionalInfo != null && b.additionalInfo!.isNotEmpty ? b.additionalInfo : a.additionalInfo,
    );
  }

  @override
  Study apply(Study study) {
    final contact = Contact();
    contact.organization = organization ?? '';
    contact.institutionalReviewBoard = institutionalReviewBoard;
    contact.institutionalReviewBoardNumber = institutionalReviewBoardNumber;
    contact.researchers = researchers;
    contact.email = email ?? '';
    contact.website = website ?? '';
    contact.phone = phone ?? '';
    contact.additionalInfo = (additionalInfo == null || additionalInfo!.isEmpty) ? null : additionalInfo;
    study.contact = contact;
    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
