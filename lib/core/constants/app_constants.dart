class AppConstants {
  // Nombre de la aplicación
  static const String appName = 'Mint';

  // Radio de los bordes de botones, tarjetas y campos
  static const double borderRadius = 14.0;

  // Espaciado general entre componentes
  static const double defaultPadding = 16.0;

  // ==========================================
  // SOLICITAR PRODUCTO
  // ==========================================

  // Tipos de producto que se pueden solicitar.
  // El valor es el que se envía a la Edge Function `request-product`.
  static const String productTypeAhorro = 'ahorro';
  static const String productTypeCorriente = 'corriente';
  static const String productTypePoliza = 'poliza';

  // Mapea el tipo de producto al account_type almacenado en Supabase.
  static const Map<String, String> accountTypeByProduct = {
    productTypeAhorro: 'Ahorros',
    productTypeCorriente: 'Corriente',
  };

  // Monto mínimo para invertir en una póliza. Debe coincidir con el
  // mínimo que valida la Edge Function `request-product`.
  static const double minPolicyAmount = 100;

  // ==========================================
  // CREAR USUARIO Y CONTRASEÑA — PASO 3
  // ==========================================

  // Simulado: nunca se envía ni se guarda en Supabase.
  static const List<String> jobSituationOptions = [
    'Empleado',
    'Independiente / Negocio propio',
    'Estudiante',
    'Jubilado',
    'Desempleado',
  ];

  static const List<String> accountUsageOptions = [
    'Ahorro personal',
    'Pago de nómina',
    'Gastos del hogar',
    'Negocio',
    'Otro',
  ];
}
