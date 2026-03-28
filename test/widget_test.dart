import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:usb_file_finder/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const App());
    // Wait for SettingsCubit.initialize() Future to complete
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // App should render something (the Container placeholder or the MacosApp)
    expect(find.byType(App), findsOneWidget);
  });
}
