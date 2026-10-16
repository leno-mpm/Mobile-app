// Datos que viajan entre los 4 pasos del flujo "Crear usuario y contraseña".
class RegistrationFlowData {
  final String identification;
  final bool skipIdentityStep;

  String firstName;
  String secondName;
  String lastName;
  String secondLastName;
  String email;
  String phone;

  String jobSituation;
  String accountUsage;
  String monthlyIncome;
  String monthlyExpenses;

  RegistrationFlowData({
    required this.identification,
    this.skipIdentityStep = false,
    this.firstName = '',
    this.secondName = '',
    this.lastName = '',
    this.secondLastName = '',
    this.email = '',
    this.phone = '',
    this.jobSituation = '',
    this.accountUsage = '',
    this.monthlyIncome = '',
    this.monthlyExpenses = '',
  });
}
