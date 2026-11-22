import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/widgets/auth_buttons.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/edit_profile_form_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileFormCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == ProfileStatus.saved,
          listener: (context, state) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
            Navigator.of(context).pop();
          },
          builder: (context, state) {
            final profile = state.profile;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _EditProfileForm(
              profile: profile,
              saving: state.status == ProfileStatus.saving,
            );
          },
        ),
      ),
    );
  }
}

/// This State only owns the two text controllers. Errors live in
/// EditProfileFormCubit and the saved data in ProfileCubit.
class _EditProfileForm extends StatefulWidget {
  final ProfileEntity profile;
  final bool saving;

  const _EditProfileForm({required this.profile, required this.saving});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.fullName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.profile.phone ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.saving) return;
    final isValid = context.read<EditProfileFormCubit>().validate(
      fullName: _nameController.text,
      phone: _phoneController.text,
    );
    if (isValid) {
      context.read<ProfileCubit>().updateProfile(
        fullName: _nameController.text,
        phone: _phoneController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<EditProfileFormCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
        builder: (context, form) => Column(
          children: [
            ProfileAvatar(
              name: widget.profile.fullName,
              photoUrl: widget.profile.photoUrl,
            ),
            const SizedBox(height: 24),
            AuthTextField(
              label: 'Full name',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              errorText: form.nameError,
              onChanged: (_) => formCubit.clearNameError(),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Email',
              hint: widget.profile.email,
              enabled: false,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Phone',
              hint: '0712 345 678',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              errorText: form.phoneError,
              onChanged: (_) => formCubit.clearPhoneError(),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: widget.saving ? 'Saving…' : 'Save changes',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
