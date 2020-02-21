import 'package:flutter_test/flutter_test.dart';
import 'package:gradual_stepper/gradual_stepper.dart';

void main() {
  testWidgets('Stepper is slidable', (WidgetTester tester) async {
    await tester.pumpWidget(GradualStepper(initialValue: 7,));

    final counterTextFinder = find.text('7');
    expect(counterTextFinder, findsOneWidget);
  });
}
