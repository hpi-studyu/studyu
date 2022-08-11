import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';

abstract class IAppRepository {
  Future<AppConfig> fetchAppConfig();
  void dispose();
}

class AppRepository implements IAppRepository {
  AppRepository(this.apiClient);

  final StudyUApi apiClient;

  @override
  Future<AppConfig> fetchAppConfig() async {
    final appConfig = await apiClient.fetchAppConfig();
    return appConfig;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

final appConfigProvider = FutureProvider.autoDispose<AppConfig>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppRepository(apiClient).fetchAppConfig();
});