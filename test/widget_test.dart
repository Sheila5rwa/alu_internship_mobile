import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aluinternship/firebase_options.dart';
import 'package:aluinternship/main.dart';

void main() {
  testWidgets('shows the ALU app welcome experience', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
