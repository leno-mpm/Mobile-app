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
| 🔐 Iniciar sesión | Inicio de sesión con nombre de usuario y contraseña |
| 🆕 Crear usuario y contraseña | Alta de credenciales en 4 pasos: verificar cédula, confirmar datos personales, situación financiera (simulada, no se guarda) y elegir usuario/contraseña. Solo disponible para cédulas que ya tengan un producto solicitado |
| 🏦 Solicitar producto | Apertura de cuenta de ahorros, cuenta corriente o póliza para una cédula, con validación simulada de buró crediticio. Si la cédula no tiene usuario todavía, termina llevando a "Crear usuario y contraseña" |
| 🏠 Inicio | Resumen del saldo total y cuentas asociadas al usuario |
| 💳 Cuentas | Consulta de cuentas de ahorro y corriente |
| 📊 Movimientos | Historial de transacciones, ingresos y egresos (incluye pagos de servicios y aperturas de póliza) |
| 📄 Pólizas | Consulta de pólizas existentes y apertura de nuevas: monto mínimo $100, plazo de 1 mes a 3 años, con cálculo de ganancia estimada antes de confirmar |
| 💸 Pagos | Pago de servicios (agua, luz, internet, Netflix — fijos en el código) desde cualquiera de las cuentas del usuario |
| 👤 Perfil | Consulta de información personal, foto de perfil y pólizas |
| 🛡️ Seguridad | Cambio de contraseña mediante Supabase Auth |
| 🔄 Sesión | La sesión vive solo en memoria: se cierra automáticamente al salir de la app o pasarla a segundo plano, no persiste entre aperturas |

**En desarrollo / fuera del alcance actual:** autenticación biométrica real, transferencias entre cuentas propias o a terceros.

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
│   ├── app_lifecycle_guard.dart   # evita cerrar sesión por pausas del sistema (galería, compartir)
│   ├── constants/                 # tipos de producto, mínimos, listas fijas (situación laboral, etc.)
│   ├── routes/                    # Navegación
│   └── theme/                     # Colores y estilos
├── model/               # Modelos de datos
├── service/             # Servicios e integración con Supabase y Edge Functions
├── view/
│   ├── create_user/       # Flujo "Crear usuario y contraseña" (4 pasos)
│   ├── product_request/   # Flujo "Solicitar producto" (cuenta o póliza)
│   └── ...                # Dashboard, Movimientos, Pagos, Perfil, Pólizas
├── viewModel/            # Lógica y estado de las vistas
├── widget/              # Componentes reutilizables
├── mock/                # Datos antiguos de referencia (no activos)
└── main.dart            # Inicialización, sesión y navegación raíz

supabase/
├── functions/
│   ├── check-identification/   # Pública: ¿esta cédula ya tiene usuario/producto?
│   ├── request-product/        # Pública: crea cuentas/pólizas para una cédula
│   └── make-payment/           # Requiere sesión: paga un servicio desde una cuenta propia
└── migrations/
    └── 20261015_product_requests.sql   # Esquema, permisos y función de débito atómico
```

> La carpeta `mock/` puede conservarse como referencia histórica; las funcionalidades principales consultan Supabase.

## Datos en Supabase

La aplicación utiliza las siguientes tablas:

| Tabla | Contenido |
| --- | --- |
| `profiles` | Información de los usuarios |
| `accounts` | Cuentas bancarias y saldos. `user_id` es nulo mientras el producto está pendiente de un usuario (ver Edge Functions) |
| `transactions` | Movimientos asociados a las cuentas (incluye pagos de servicios y aperturas de póliza) |
| `policies` | Pólizas e inversiones a plazo fijo, con `source_account_id` apuntando a la cuenta que las financia |

Las consultas desde la app se realizan utilizando el usuario autenticado. Las políticas **RLS** deben mantenerse habilitadas y correctamente configuradas para impedir el acceso a registros de otros usuarios.

## ⚡ Edge Functions y migración de Supabase

Los flujos de **Crear usuario**, **Solicitar producto** y **Pagos** necesitan operaciones que un cliente autenticado normal no puede hacer (crear una cuenta antes de que exista un usuario, o escribir el saldo de una cuenta ajena a `auth.uid()`). Para eso existen 3 Edge Functions en `supabase/functions/`:

| Función | Verifica sesión | Uso |
| --- | --- | --- |
| `check-identification` | No | Dado un número de cédula, indica si ya tiene usuario y qué cuentas/pólizas tiene |
| `request-product` | No | Crea una cuenta o póliza para una cédula; vincula el producto al usuario si ya existe uno |
| `make-payment` | Sí | Paga un servicio desde una cuenta del usuario autenticado, validando que la cuenta sea suya |

**Configuración inicial (una sola vez por proyecto Supabase):**

1. Aplica `supabase/migrations/20261015_product_requests.sql` en el **SQL Editor** del dashboard. Agrega las columnas/permisos necesarios y la función `debit_account_balance` (débito atómico de saldo, evita condiciones de carrera).
2. Despliega las funciones:

```bash
supabase functions deploy check-identification --no-verify-jwt
supabase functions deploy request-product --no-verify-jwt
supabase functions deploy make-payment
```

`check-identification` y `request-product` se despliegan **sin verificación de JWT** porque se llaman antes de que el usuario tenga sesión (durante "Solicitar producto"). `make-payment` sí requiere sesión: valida el token del usuario dentro del propio código, independientemente de ese interruptor.

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

### 4. Aplicar la migración y desplegar las Edge Functions

Requerido para que "Crear usuario", "Solicitar producto" y "Pagos" funcionen — ver [Edge Functions y migración de Supabase](#-edge-functions-y-migración-de-supabase) más arriba para el detalle de cada una.

### 5. Ejecutar en desarrollo

```bash
flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

Si el emulador presenta problemas de renderizado con Impeller, puedes probar:

```bash
flutter run --no-enable-impeller --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

### 6. Verificar el código

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

- [ ] Solicitar una cuenta de ahorros/corriente con una cédula nueva y completar "Crear usuario y contraseña" desde ahí.
- [ ] Solicitar una póliza con una cédula sin cuentas (debe bloquear y pedir solicitar cuenta primero).
- [ ] Solicitar una póliza con una cédula con 2 cuentas (debe pedir elegir la cuenta de origen).
- [ ] Solicitar una póliza con monto menor a $100 o mayor al saldo disponible (debe rechazar con mensaje claro).
- [ ] Intentar "Crear usuario y contraseña" con una cédula sin productos, y con una que ya tiene usuario (debe bloquear en ambos casos).
- [ ] Iniciar sesión con nombre de usuario y contraseña.
- [ ] Pagar un servicio (Agua, Luz, Internet, Netflix) desde Pagos y verificar que el saldo se descuenta y aparece como egreso en Movimientos.
- [ ] Navegar entre Inicio, Movimientos, Pagos y Perfil usando la barra inferior desde cualquiera de las 4 pantallas.
- [ ] Consultar cuentas, saldos, movimientos y pólizas del usuario autenticado.
- [ ] Confirmar que un usuario no puede acceder a los datos de otro.
- [ ] Cambiar la contraseña e iniciar sesión con la nueva.
- [ ] Cerrar sesión manualmente y comprobar que no se pueda volver a pantallas protegidas.
- [ ] Pasar la app a segundo plano (botón Home) y volver: debe pedir iniciar sesión de nuevo.
- [ ] Cambiar la foto de perfil y compartir los datos de una cuenta: no deben cerrar la sesión a mitad de la acción.
- [ ] Instalar y probar el APK en un dispositivo Android.

La opción de **huella digital** aún no implementa autenticación biométrica real.

---

<div align="center">

**Mint · Banca móvil sencilla, organizada y conectada.** 💚

*Desarrollado con Flutter y Supabase.*

</div>
