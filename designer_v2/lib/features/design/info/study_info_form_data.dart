import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class StudyInfoFormData implements IStudyFormData {
  StudyInfoFormData({
    required this.title,
    this.description,
    required this.tagsInfoFormData,
    required this.contactInfoFormData,
    required this.iconName,
  });

  final String title;
  final String? description;
  final StudyTagsInfoFormData tagsInfoFormData;
  final String iconName;
  final StudyContactInfoFormData contactInfoFormData;

  factory StudyInfoFormData.fromStudy(Study study) {
    return StudyInfoFormData(
      title: study.title ?? '',
      description: study.description ?? '',
      tagsInfoFormData: StudyTagsInfoFormData.fromStudy(study),
      iconName: study.iconName,
      contactInfoFormData: StudyContactInfoFormData.fromStudy(study),
    );
  }

  @override
  Study apply(Study study) {
    study.title = title;
    study.description = description;
    tagsInfoFormData.apply(study);
    study.iconName = iconName;
    contactInfoFormData.apply(study);
    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}

class StudyTagsInfoFormData implements IStudyFormData {
  StudyTagsInfoFormData({required this.tags});

  final List<StudyTag> tags;

  factory StudyTagsInfoFormData.fromStudy(Study study) {
    return StudyTagsInfoFormData(
      tags: study.tags,
    );
  }

  @override
  Study apply(Study study) {
    study.tags = tags;
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
    return StudyContactInfoFormData(
      organization: contact.organization,
      institutionalReviewBoard: contact.institutionalReviewBoard ?? '',
      institutionalReviewBoardNumber: contact.institutionalReviewBoardNumber ?? '',
      researchers: contact.researchers ?? '',
      email: contact.email,
      website: contact.website,
      phone: contact.phone,
      additionalInfo: contact.additionalInfo,
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
