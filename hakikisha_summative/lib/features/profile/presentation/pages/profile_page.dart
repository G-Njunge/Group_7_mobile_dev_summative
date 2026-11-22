import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/widgets/auth_buttons.dart';
import '../../../auth/presentation/widgets/auth_colors.dart';
import '../../../auth/presentation/widgets/neumorphic.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.status == ProfileStatus.deleted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Your account was deleted.')),
            );
          } else if (state.status == ProfileStatus.error &&
              state.profile != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong.'),
              ),
            );
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            if (state.status == ProfileStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return _ProfileBody(
            profile: profile,
            busy: state.status == ProfileStatus.deleting,
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final bool busy;

  const _ProfileBody({required this.profile, required this.busy});

  Future<void> _confirmDelete(BuildContext context) async {
    if (busy) return;
    final confirmed = await showDeleteAccountDialog(context);
    if (confirmed && context.mounted) {
      context.read<ProfileCubit>().deleteAccount();
    }
  }

  void _openEdit(BuildContext context) {
    if (busy) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const EditProfilePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileAvatar(name: profile.fullName, photoUrl: profile.photoUrl),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AuthColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            profile.email,
            style: const TextStyle(color: AuthColors.textMuted),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: Neu.raisedBox(radius: 20, distance: 6, blur: 16),
            child: Column(
              children: [
                _InfoRow(label: 'Phone', value: profile.phone ?? 'Not set'),
                _InfoRow(
                  label: 'Signed in with',
                  value: signInMethodLabel(profile.authProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Edit profile',
            onPressed: () => _openEdit(context),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: busy ? 'Deleting…' : 'Delete account',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: AuthColors.textMuted),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

String signInMethodLabel(String authProvider) =>
    authProvider.toLowerCase().contains('google')
    ? 'Google'
    : 'Email and password';
