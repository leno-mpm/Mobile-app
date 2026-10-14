
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../mock/mock_users.dart';
import '../model/user_model.dart';
import '../service/user_service.dart';
import '../viewModel/profile_view_model.dart';
import '../widget/dashboard_bottom_nav.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;

  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(UserService());
    _viewModel.loadProfile(MockUsers.currentUser.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Obtener las iniciales del usuario
  String _getInitials(UserModel user) {
    final first = user.firstName.trim();
    final last = user.lastName.trim();

    return '${first.isNotEmpty ? first[0] : ''}'
        '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  // Mostrar mensaje para funcionalidades pendientes
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature estará disponible próximamente')));
  }

  // Seleccionar foto desde la galería
  Future<void> _changeProfilePhoto() async {
    try {
      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      // El usuario canceló la selección
      if (selectedImage == null) {
        return;
      }
      if (!mounted) return;
      setState(() {
        _profileImage = File(selectedImage.path);
      });
    } catch (e) {
      debugPrint('Error al seleccionar foto: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo seleccionar la imagen')));
    }
  }

  // Mostrar opciones para cambiar o eliminar la foto
  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Seleccionar de la galería',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _changeProfilePhoto();
                  },
                ),

                if (_profileImage != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Eliminar foto',
                      style: TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _profileImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Construir una opción de configuración
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
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

  // Construir una sección con tarjeta blanca
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 5,
            bottom: 9,
          ),
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

  // Editar información personal
  Future<void> _editProfile(UserModel user) async {
    final firstNameController = TextEditingController(
      text: user.firstName,
    );

    final lastNameController = TextEditingController(
      text: user.lastName,
    );

    final emailController = TextEditingController(
      text: user.email,
    );

    final phoneController = TextEditingController(
      text: user.phone,
    );

    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Información personal',
            ),

            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: firstNameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Apellido
                    TextFormField(
                      controller: lastNameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa tu apellido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Correo
                    TextFormField(
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Ingresa un correo válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Teléfono
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Ingresa tu teléfono';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancelar'),
              ),

              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.pop(dialogContext, {
                    'firstName':
                    firstNameController.text.trim(),
                    'lastName':
                    lastNameController.text.trim(),
                    'email':
                    emailController.text.trim(),
                    'phone':
                    phoneController.text.trim(),
                  });
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (!mounted || result == null) {
        return;
      }

      final success = await _viewModel.updateProfile(
        firstName: result['firstName']!,
        lastName: result['lastName']!,
        email: result['email']!,
        phone: result['phone']!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Información actualizada correctamente'
                : (_viewModel.errorMessage ??
                'No se pudo actualizar el perfil'),
          ),
        ),
      );
    } finally {
      // Mantener la espera utilizada en la
      // corrección anterior del formulario.
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      firstNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  // Botones superiores: regresar y editar
  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Barra inferior
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 3,
        onItemSelected: (index) {
          if (index == 3) return;

          if (index == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              _showComingSoon('Navegación a Inicio');
            }

            return;
          }

          _showComingSoon(
            index == 1 ? 'Movimientos' : 'Pagos',
          );
        },
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = _viewModel.user;

            if (user == null) {
              return Center(
                child: Text(
                  _viewModel.errorMessage ??
                      'No se encontró el usuario',
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                30,
                18,
                30,
                30,
              ),
              children: [
                // ENCABEZADO
                Row(
                  children: [
                    _headerButton(
                      icon:
                      Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          _showComingSoon('Regresar');
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

                    _headerButton(
                      icon: Icons.edit_outlined,
                      onTap: () => _editProfile(user),
                    ),
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
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                            _profileImage!,
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                          )
                              : Center(
                            child: Text(
                              _getInitials(user),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 36,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Botón de cámara
                      Positioned(
                        right: -2,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
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

                // NOMBRE
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

                // CORREO
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 11),

                // IDENTIDAD VERIFICADA
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
                      iconBackground:
                      const Color(0xFFE7EFFC),
                      onTap: () => _showComingSoon(
                        'Cambiar contraseña',
                      ),
                    ),

                    _buildOption(
                      icon: Icons.fingerprint_rounded,
                      title: 'Ingreso con huella',
                      iconColor: AppColors.primary,
                      iconBackground:
                      const Color(0xFFE7EFFC),
                      onTap: () => _showComingSoon(
                        'Ingreso con huella',
                      ),
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
                      iconBackground:
                      const Color(0xFFE2F3EC),
                      onTap: () => _editProfile(user),
                    ),

                    _buildOption(
                      icon: Icons.credit_card_outlined,
                      title: 'Mis cuentas',
                      iconColor: AppColors.secondary,
                      iconBackground:
                      const Color(0xFFE2F3EC),
                      onTap: () => _showComingSoon(
                        'Mis cuentas',
                      ),
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
                    onTap: () => _showComingSoon(
                      'Cerrar sesión',
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
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
