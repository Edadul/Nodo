import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/main.dart';
import 'package:nodo/widgets/opportunity_card.dart';

void main() {
  testWidgets('Muestra la tarjeta de oportunidad en el home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(OpportunityCard), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    expect(find.text('3 de 6 cupos'), findsOneWidget);
  });
}
