import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.debugAuthAutoRefreshSync = null;
    appConnectionStatusController.reset();
  });

  test('connection status syncs auth refresh only when status changes', () {
    final calls = <AppConnectionStatus>[];
    appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
    appConnectionStatusController.setStatus(
      AppConnectionStatus.backendUnavailable,
    );
    appConnectionStatusController.setStatus(AppConnectionStatus.healthy);

    expect(calls, [
      AppConnectionStatus.deviceOffline,
      AppConnectionStatus.backendUnavailable,
      AppConnectionStatus.healthy,
    ]);
  });

  test('syncAuthAutoRefresh reapplies current connection status', () {
    final calls = <AppConnectionStatus>[];
    appConnectionStatusController.debugAuthAutoRefreshSync = calls.add;

    appConnectionStatusController.setStatus(
      AppConnectionStatus.backendUnavailable,
    );
    calls.clear();

    appConnectionStatusController.syncAuthAutoRefresh();

    expect(calls, [AppConnectionStatus.backendUnavailable]);
  });

  test('connectionStatusFromError maps explicit offline transport errors', () {
    expect(
      connectionStatusFromError(
        Exception('SocketException: Network is unreachable'),
      ),
      AppConnectionStatus.deviceOffline,
    );
  });

  test(
    'connectionStatusFromError keeps generic fetch failures as backend unavailable',
    () {
      expect(
        connectionStatusFromError(
          Exception('ClientException: Failed to fetch'),
        ),
        AppConnectionStatus.backendUnavailable,
      );
    },
  );
}
