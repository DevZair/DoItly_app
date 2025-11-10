import 'package:doitly/injection_container.dart';
import 'package:doitly/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initDependencies();
  });

  tearDownAll(() async {
    await sl.reset();
  });

  testWidgets('Экран входа отображается по умолчанию', (tester) async {
    await tester.pumpWidget(DoitlyApp());
    await tester.pumpAndSettle();

    expect(find.text('DoItly'), findsWidgets);
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  });
}
