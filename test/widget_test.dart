import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/core/di/service_locator.dart';
import 'package:nodo/main.dart';

void main() {
  setUp(() {
    ServiceLocator.instance.reset();
    ServiceLocator.instance.init();
  });

  testWidgets('Home muestra título Únete y feed de ideas', (tester) async {
    await tester.pumpWidget(const NodoApp());
    await tester.pumpAndSettle();

    expect(find.text('Únete'), findsOneWidget);
    expect(
      find.text('Explora ideas en crecimiento o siembra la tuya'),
      findsOneWidget,
    );
    expect(find.text('TODAS'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
  });

  testWidgets('Filtrar por categoría actualiza el feed', (tester) async {
    await tester.pumpWidget(const NodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'TECNOLOGÍA'));
    await tester.pumpAndSettle();

    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsNothing);
  });
}
