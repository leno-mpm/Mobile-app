import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../model/transaction_model.dart';
import '../model/user_model.dart';
import '../service/account_service.dart';
import '../viewModel/profile_view_model.dart';
import '../viewModel/security_view_model.dart';
import '../widget/dashboard_bottom_nav.dart';
import 'movements_view.dart';
import 'policies_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;
  late final SecurityViewModel _securityViewModel;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final userId = Supabase.instance.client.auth.currentUser?.id;

    _viewModel = ProfileViewModel();
    _securityViewModel = SecurityViewModel(userId ?? '');

    _viewModel.loadProfile();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _securityViewModel.dispose();
    super.dispose();
  }

  String _getInitials(UserModel user) {
    final first = user.firstName.trim();
    final last = user.lastName.trim();

    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  Future<void> _changeProfilePhoto() async {
    if (_viewModel.isUploadingPhoto) return;

    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (selectedImage == null || !mounted) return;

      final success = await _viewModel.uploadProfilePhoto(
        File(selectedImage.path),
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Foto de perfil guardada correctamente');
      } else {
        _showMessage(
          _viewModel.errorMessage ??
              'No se pudo guardar la fotografía',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo seleccionar la imagen');
      debugPrint('Error al seleccionar foto: $e');
    }
  }


  // ============================================================
  // CAMBIAR CONTRASEÑA
  // ============================================================

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    // Actualiza los requisitos mientras se escribe.
    final newPasswordNotifier = ValueNotifier<String>('');

    // Controla si se muestran las contraseñas.
    final currentVisible = ValueNotifier<bool>(false);
    final newVisible = ValueNotifier<bool>(false);
    final confirmVisible = ValueNotifier<bool>(false);

    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Cambiar contraseña',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CONTRASEÑA ACTUAL
                      ValueListenableBuilder<bool>(
                        valueListenable: currentVisible,
                        builder: (context, visible, child) {
                          return TextFormField(
                            controller: currentController,
                            obscureText: !visible,
                            decoration: _passwordInputDecoration(
                              label: 'Contraseña actual',
                              icon: Icons.lock_outline,
                              visible: visible,
                              onVisibilityPressed: () {
                                currentVisible.value = !visible;
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña actual';
                              }
                              return null;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // NUEVA CONTRASEÑA
                      ValueListenableBuilder<bool>(
                        valueListenable: newVisible,
                        builder: (context, visible, child) {
                          return TextFormField(
                            controller: newController,
                            obscureText: !visible,
                            onChanged: (value) {
                              newPasswordNotifier.value = value;
                            },
                            decoration: _passwordInputDecoration(
                              label: 'Nueva contraseña',
                              icon: Icons.lock_reset_outlined,
                              visible: visible,
                              onVisibilityPressed: () {
                                newVisible.value = !visible;
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa una contraseña nueva';
                              }

                              final hasMinLength = value.length >= 8;
                              final hasUppercase = RegExp(r'[A-Z]')
                                  .hasMatch(value);
                              final hasLowercase = RegExp(r'[a-z]')
                                  .hasMatch(value);
                              final hasNumber = RegExp(r'[0-9]')
                                  .hasMatch(value);

                              if (!hasMinLength ||
                                  !hasUppercase ||
                                  !hasLowercase ||
                                  !hasNumber) {
                                return 'No cumple los requisitos';
                              }

                              return null;
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // REQUISITOS EN TIEMPO REAL
                      ValueListenableBuilder<String>(
                        valueListenable: newPasswordNotifier,
                        builder: (context, password, child) {
                          final hasMinLength = password.length >= 8;
                          final hasUppercase = RegExp(r'[A-Z]')
                              .hasMatch(password);
                          final hasLowercase = RegExp(r'[a-z]')
                              .hasMatch(password);
                          final hasNumber = RegExp(r'[0-9]').hasMatch(password);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'La contraseña debe contener:',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                _passwordRequirement(
                                  'Mínimo 8 caracteres',
                                  hasMinLength,
                                ),

                                _passwordRequirement(
                                  'Una letra mayúscula',
                                  hasUppercase,
                                ),

                                _passwordRequirement(
                                  'Una letra minúscula',
                                  hasLowercase,
                                ),

                                _passwordRequirement('Un número', hasNumber),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // CONFIRMAR CONTRASEÑA
                      ValueListenableBuilder<bool>(
                        valueListenable: confirmVisible,
                        builder: (context, visible, child) {
                          return TextFormField(
                            controller: confirmController,
                            obscureText: !visible,
                            decoration: _passwordInputDecoration(
                              label: 'Confirmar contraseña',
                              icon: Icons.verified_user_outlined,
                              visible: visible,
                              onVisibilityPressed: () {
                                confirmVisible.value = !visible;
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirma tu contraseña';
                              }

                              if (value != newController.text) {
                                return 'Las contraseñas no coinciden';
                              }

                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.pop(dialogContext, {
                    'current': currentController.text,
                    'new': newController.text,
                    'confirm': confirmController.text,
                  });
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (!mounted || result == null) return;

      final error = await _securityViewModel.changePassword(
        currentPassword: result['current']!,
        newPassword: result['new']!,
        confirmPassword: result['confirm']!,
      );

      if (!mounted) return;

      _showMessage(error ?? 'Contraseña actualizada correctamente');
    } finally {
      // Espera a que termine la animación de cierre del diálogo.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      currentController.dispose();
      newController.dispose();
      confirmController.dispose();

      newPasswordNotifier.dispose();
      currentVisible.dispose();
      newVisible.dispose();
      confirmVisible.dispose();
    }
  }

  // DECORACIÓN DE LOS CAMPOS DE CONTRASEÑA
  InputDecoration _passwordInputDecoration({
    required String label,
    required IconData icon,
    required bool visible,
    required VoidCallback onVisibilityPressed,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: IconButton(
        onPressed: onVisibilityPressed,
        icon: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D8E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // INDICADOR DE REQUISITOS
  Widget _passwordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isValid ? AppColors.secondary : AppColors.textSecondary,
            size: 16,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? AppColors.secondary : AppColors.textSecondary,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMACIÓN PERSONAL - SOLO LECTURA
  // ============================================================

  void _showPersonalInformation(UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información personal',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Estos datos son únicamente de consulta.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                _informationRow('Nombres', user.firstName),
                _informationRow('Apellidos', user.lastName),
                _informationRow('Cédula', user.identification),
                _informationRow('Correo electrónico', user.email),
                _informationRow('Teléfono', user.phone),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _informationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Divider(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // IR A MOVIMIENTOS
  // ============================================================

  Future<void> _openMovements() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      _showMessage('Debes iniciar sesión');
      return;
    }
    final accountService = AccountService();

    final accounts = await accountService.getAccountsByUser(userId);

    final List<TransactionModel> transactions = [];
    for (final account in accounts) {
      transactions.addAll(
        await accountService.getTransactionsByAccount(account.id),
      );
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MovementsView(
          transactions: transactions,
          accounts: accounts,
        ),
      ),
    );
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _logout() async {
    final success = await _viewModel.logout();

    if (!mounted) return;

    if (!success) {
      _showMessage(
        _viewModel.errorMessage ?? 'No se pudo cerrar sesión',
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  // ============================================================
  // WIDGETS REUTILIZABLES
  // ============================================================

  Widget _buildOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBackground,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 9),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],

                  if (i < children.length - 1)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEF0F4),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }

  // ============================================================
  // INTERFAZ PRINCIPAL DEL PERFIL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 3,
        onItemSelected: (index) {
          if (index == 3) return;

          if (index == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
            return;
          }

          if (index == 1) {
            _openMovements();
            return;
          }

          _showMessage('Pagos estará disponible próximamente');
        },
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = _viewModel.user;

            if (user == null) {
              return Center(
                child: Text(
                  _viewModel.errorMessage ?? 'No se encontró el usuario',
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
              children: [
                // ENCABEZADO
                Row(
                  children: [
                    _headerButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.dashboard,
                          );
                        }
                      },
                    ),

                    const Expanded(
                      child: Text(
                        'Mi perfil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 18),

                // FOTO DE PERFIL
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDCE6F5),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,

                        child: ClipOval(
                          child: _viewModel.avatarUrl != null
                              ? Image.network(
                            _viewModel.avatarUrl!,
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  _getInitials(user),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text(
                              _getInitials(user),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      ),

                      Positioned(
                        right: -2,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _changeProfilePhoto,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 11),

                // INDICADOR VISUAL DE IDENTIDAD
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F3EB),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF13745A),
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Identidad verificada',
                          style: TextStyle(
                            color: Color(0xFF13745A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SEGURIDAD
                _buildSection(
                  title: 'SEGURIDAD',
                  children: [
                    _buildOption(
                      icon: Icons.lock_outline_rounded,
                      title: 'Cambiar contraseña',
                      iconColor: AppColors.primary,
                      iconBackground: const Color(0xFFE7EFFC),
                      onTap: _showChangePasswordDialog,
                    ),

                    ListenableBuilder(
                      listenable: _securityViewModel,
                      builder: (context, child) {
                        return _buildOption(
                          icon: Icons.fingerprint_rounded,
                          title: 'Ingreso con huella',
                          iconColor: AppColors.primary,
                          iconBackground: const Color(0xFFE7EFFC),
                          onTap: () {
                            final enabled =
                                !_securityViewModel.fingerprintEnabled;

                            _securityViewModel.setFingerprintEnabled(enabled);

                            _showMessage(
                              enabled
                                  ? 'Ingreso con huella simulado activado'
                                  : 'Ingreso con huella desactivado',
                            );
                          },
                          trailing: Switch(
                            value: _securityViewModel.fingerprintEnabled,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.secondary,
                            onChanged: (enabled) {
                              _securityViewModel.setFingerprintEnabled(enabled);

                              _showMessage(
                                enabled
                                    ? 'Ingreso con huella simulado activado'
                                    : 'Ingreso con huella desactivado',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // DATOS
                _buildSection(
                  title: 'DATOS',
                  children: [
                    _buildOption(
                      icon: Icons.person_outline_rounded,
                      title: 'Información personal',
                      iconColor: AppColors.secondary,
                      iconBackground: const Color(0xFFE2F3EC),
                      onTap: () {
                        _showPersonalInformation(user);
                      },
                    ),

                    _buildOption(
                      icon: Icons.account_balance_outlined,
                      title: 'Mis pólizas',
                      iconColor: AppColors.secondary,
                      iconBackground: const Color(0xFFE2F3EC),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PoliciesView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // CERRAR SESIÓN
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _logout,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 21,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
