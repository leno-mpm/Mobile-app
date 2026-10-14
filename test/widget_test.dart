
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Mint muestra el Dashboard', (WidgetTester tester) async {
    // Iniciar nuestra aplicación
    await tester.pumpWidget(const MintApp());

    // Esperar a que terminen las cargas y animaciones
    await tester.pumpAndSettle();

    // Verificar que se muestra el Dashboard
    expect(find.text('Mis finanzas'), findsOneWidget);

    // Verificar que aparece la sección de cuentas
    expect(find.text('Mis cuentas'), findsOneWidget);
  });
}
