import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Future<void> syncLanguageForAuthenticatedUser(BuildContext context) async {
  await context.read<AppLanguage>().syncWithAuthenticatedUser();
}
