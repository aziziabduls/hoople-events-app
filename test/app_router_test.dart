import 'package:flutter_test/flutter_test.dart';
import 'package:hoople_mobile_app/routes/app_router.dart';

void main() {
  test('router exposes its initial location', () {
    final router = appRouter;

    expect(router.routeInformationProvider.value.location, '/');
  });
}
