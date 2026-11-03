import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_go/main.dart';

void main() {
  testWidgets('PromptGo shows its branded splash screen', (tester) async {
    await tester.pumpWidget(const PromptGoApp());
    expect(find.text('PromptGo'), findsOneWidget);
  });
}
