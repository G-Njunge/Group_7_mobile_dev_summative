import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.navProfile,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          if (profile != null) return _ProfileBody(profile: profile);
          if (state.status == ProfileStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.profileLoadError, textAlign: TextAlign.center),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final ProfileEntity profile;

  void _openEdit(BuildContext context) {
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
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final isGoogle = profile.authProvider.toLowerCase().contains('google');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          ProfileAvatar(name: profile.fullName, photoUrl: profile.photoUrl),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: palette.heading, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(profile.email, style: TextStyle(color: palette.textMuted)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: NeuCard(
              child: Column(
                children: [
                  _InfoRow(
                    label: l10n.profilePhone,
                    value: profile.phone ?? l10n.profileNotSet,
                  ),
                  _InfoRow(
                    label: l10n.profileSignedInWith,
                    value: isGoogle
                        ? l10n.profileSignInGoogle
                        : l10n.profileSignInPassword,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.profileEdit,
            onPressed: () => _openEdit(context),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

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
              style: TextStyle(color: context.palette.textMuted),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
