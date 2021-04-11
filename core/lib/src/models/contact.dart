class Contact {
  String organization;
  String institutionalReviewBoard;
  String institutionalReviewBoardNumber;
  String researchers;
  String email;
  String website;
  String phone;

  Contact();

  Contact.designerDefault()
      : organization = '',
        institutionalReviewBoard = '',
        institutionalReviewBoardNumber = '',
        researchers = '',
        email = '',
        website = '',
        phone = '';

  factory Contact.fromJson(Map<String, dynamic> json) => Contact()
    ..organization = json['organization'] as String
    ..institutionalReviewBoard = json['institutionalReviewBoard'] as String
    ..institutionalReviewBoardNumber = json['institutionalReviewBoardNumber'] as String
    ..researchers = json['researchers'] as String
    ..email = json['email'] as String
    ..website = json['website'] as String
    ..phone = json['phone'] as String;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'organization': organization,
        'institutionalReviewBoard': institutionalReviewBoard,
        'institutionalReviewBoardNumber': institutionalReviewBoardNumber,
        'researchers': researchers,
        'email': email,
        'website': website,
        'phone': phone,
      };

  @override
  String toString() => toJson().toString();
}
