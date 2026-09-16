import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/core/di/service_locator.dart';
import 'package:nodo/main.dart';
import 'package:nodo/features/home/data/datasources/mock_idea_datasource.dart';
import 'package:nodo/features/application/data/datasources/mock_application_datasource.dart';

void main() {
  setUp(() {
    // Hermético: inyectamos datasources en memoria (mismo patrón que
    // home_get_ideas_test) para que el test de widgets no dependa de
    // SQLite/FFI ni de IO real, evitando timeouts en pumpAndSettle.
    ServiceLocator.instance.reset();
    ServiceLocator.instance.init(
      ideaDataSourceOverride: MockIdeaDataSource(),
      applicationDataSourceOverride: MockApplicationDataSource(),
    );
  });

  testWidgets('Home muestra título Únete y feed SQLite', (tester) async {
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
