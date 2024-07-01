import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';

part 'app_repository.g.dart';

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

@riverpod
Future<AppConfig> appConfig(AppConfigRef ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return await AppRepository(apiClient).fetchAppConfig();
}
