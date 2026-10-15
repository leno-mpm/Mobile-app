<div align="center">

# 💚 Mint

### Tu banca, más simple.

**Aplicación bancaria móvil desarrollada con Flutter y Supabase**

Consulta tus cuentas, movimientos y pólizas desde una experiencia clara, organizada y conectada a la nube.

![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Android](https://img.shields.io/badge/Android-APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)

</div>

---

## ✨ Acerca del proyecto

**Mint** es una aplicación móvil de consulta bancaria desarrollada con **Flutter** y organizada mediante el patrón **MVVM (Model–View–ViewModel)**. Utiliza **Supabase** para la autenticación y el acceso a información almacenada en una base de datos PostgreSQL.

Su objetivo es facilitar la consulta de información financiera desde una interfaz intuitiva, sin depender de datos simulados durante la ejecución de las funcionalidades principales.

> **Nota:** Proyecto de demostración académica. Los saldos, movimientos y pólizas de prueba son datos ficticios; Mint no representa una entidad bancaria real.

## 🚀 Funcionalidades

| Módulo | Funcionalidad |
| --- | --- |
| 🔐 Autenticación | Registro de usuarios e inicio de sesión con nombre de usuario y contraseña |
| 🏠 Inicio | Resumen del saldo total y cuentas asociadas al usuario |
| 💳 Cuentas | Consulta de cuentas de ahorro y corriente |
| 📊 Movimientos | Historial de transacciones, ingresos y egresos |
| 📄 Pólizas | Consulta de inversiones a plazo fijo y estimaciones de interés |
| 👤 Perfil | Consulta de información personal |
| 🛡️ Seguridad | Cambio de contraseña y cierre de sesión mediante Supabase Auth |
| 🔄 Sesión | Persistencia de la sesión entre aperturas de la aplicación |

**En desarrollo / fuera del alcance actual:** autenticación biométrica real, transferencias y pagos bancarios operativos.

## Tecnologías

- **Flutter:** desarrollo de la interfaz móvil.
- **Dart:** lenguaje de programación.
- **Supabase Auth:** registro, autenticación y gestión de sesiones.
- **Supabase / PostgreSQL:** almacenamiento y consulta de datos.
- **Row Level Security (RLS):** políticas de acceso por usuario a los registros de la base de datos.
- **Android Studio:** desarrollo y pruebas en emulador Android.

## 🏗️ Arquitectura

Mint utiliza el patrón **MVVM**, separando la interfaz de usuario, la lógica de presentación y el acceso a datos.

```text
┌──────────────────────┐
│      View            │  Pantallas y widgets de Flutter
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      ViewModel       │  Estado, validaciones y presentación
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      Service         │  Consultas y operaciones con Supabase
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│       Supabase       │  Auth + PostgreSQL
└──────────────────────┘
```

### Organización principal

```text
lib/
├── core/
│   ├── routes/          # Navegación
│   └── theme/           # Colores y estilos
├── model/               # Modelos de datos
├── service/             # Servicios e integración con Supabase
├── view/                # Pantallas
├── viewModel/            # Lógica y estado de las vistas
├── widget/              # Componentes reutilizables
├── mock/                # Datos antiguos de referencia (no activos)
└── main.dart            # Inicialización y configuración
```

> La carpeta `mock/` puede conservarse como referencia histórica; las funcionalidades principales consultan Supabase.

## Datos en Supabase

La aplicación utiliza las siguientes tablas:

| Tabla | Contenido |
| --- | --- |
| `profiles` | Información de los usuarios |
| `accounts` | Cuentas bancarias y saldos |
| `transactions` | Movimientos asociados a las cuentas |
| `policies` | Pólizas e inversiones a plazo fijo |

Las consultas se realizan utilizando el usuario autenticado. Las políticas **RLS** deben mantenerse habilitadas y correctamente configuradas para impedir el acceso a registros de otros usuarios.

## Instalación y ejecución

### Requisitos

- Flutter SDK instalado.
- Android Studio o un editor compatible con Flutter.
- Emulador Android o dispositivo físico.
- Acceso al proyecto Supabase correspondiente y su **publishable key**.

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd <NOMBRE_DEL_PROYECTO>
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Supabase

El proyecto inicializa Supabase desde `lib/main.dart` y recibe la clave pública mediante `--dart-define`:

```dart
const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
```

Verifica que la URL configurada en `Supabase.initialize()` corresponda a tu proyecto Supabase.

**Nunca incluyas la `service_role` key en la aplicación Flutter ni la subas al repositorio.** La publishable key es pública, pero la seguridad de los datos depende de la autenticación y las políticas RLS.

### 4. Ejecutar en desarrollo

```bash
flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

Si el emulador presenta problemas de renderizado con Impeller, puedes probar:

```bash
flutter run --no-enable-impeller --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

### 5. Verificar el código

```bash
flutter analyze
```

## 📦 Generar APK para Android

```bash
flutter build apk --release --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

El APK se genera normalmente en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

La aplicación instalada necesita conexión a internet para comunicarse con Supabase. **La base de datos no se almacena dentro del APK.**

> Para distribuir la aplicación públicamente, revisa la configuración de firma de Android, los permisos, las políticas RLS y las medidas de seguridad antes del lanzamiento.

## 🧪 Pruebas recomendadas

- [ ] Registrar un usuario nuevo.
- [ ] Iniciar sesión con nombre de usuario y contraseña.
- [ ] Consultar cuentas y saldos del usuario autenticado.
- [ ] Visualizar movimientos y pólizas.
- [ ] Confirmar que un usuario no puede acceder a los datos de otro.
- [ ] Cambiar la contraseña e iniciar sesión con la nueva.
- [ ] Cerrar sesión y comprobar que no se pueda volver a pantallas protegidas.
- [ ] Reiniciar la aplicación y comprobar la persistencia de sesión.
- [ ] Instalar y probar el APK en un dispositivo Android.

La opción de **huella digital** aún no implementa autenticación biométrica real.

---

<div align="center">

**Mint · Banca móvil sencilla, organizada y conectada.** 💚

*Desarrollado con Flutter y Supabase.*

</div>
