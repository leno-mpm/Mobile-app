// Permite que acciones que abren UI del sistema (galería, hoja de
// compartir) marquen que el próximo AppLifecycleState.paused NO debe
// cerrar la sesión, porque es solo una interrupción temporal, no el
// usuario saliendo de la app de verdad.
class AppLifecycleGuard {
  AppLifecycleGuard._();

  static bool isSuppressed = false;
}
