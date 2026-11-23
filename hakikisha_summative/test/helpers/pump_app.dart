import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hakikisha_summative/core/l10n/app_localizations_delegates.dart';
import 'package:hakikisha_summative/core/l10n/generated/app_localizations.dart';
import 'package:hakikisha_summative/core/session/session_cubit.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';
import 'package:hakikisha_summative/core/theme/app_theme.dart';

/// In-memory [SessionSource] so widget tests never touch Firebase.
class FakeSessionSource implements SessionSource {
  FakeSessionSource([this.current = SessionStatus.signedIn]);

  // Replays the current status to the first listener, like Firebase does.
  // (A plain controller, not async*: cancelling an async* stream never
  // completes inside the widget-test zone, which would hang cubit.close().)
  late final StreamController<SessionStatus> _controller =
      StreamController.broadcast(onListen: () => _controller.add(current));
  int signOutCalls = 0;

  @override
  SessionStatus current;

  /// Simulates Firebase reporting a new auth state.
  void emit(SessionStatus status) {
    current = status;
    _controller.add(status);
  }

  @override
  Stream<SessionStatus> watch() => _controller.stream;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emit(SessionStatus.signedOut);
  }
}

extension PumpApp on WidgetTester {
  /// Pumps [page] as the only route of a router, with the app's theme,
  /// localizations and the given cubits, so pages using `AppScaffold`,
  /// `context.canPop()` or `AppLocalizations` work in isolation.
  ///
  /// Pass `settle: false` when the page has an endless animation (a loading
  /// spinner), which would otherwise make `pumpAndSettle` time out.
  Future<void> pumpPage(
    Widget page, {
    List<BlocProvider> providers = const [],
    Locale locale = const Locale('en'),
    bool settle = true,
  }) async {
    // The Scaffold gives bare widgets (fields, buttons) a Material ancestor
    // and a place for snackbars; full pages bring their own and nest fine.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: page),
        ),
      ],
    );
    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SessionCubit(FakeSessionSource())),
          ...providers,
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    settle ? await pumpAndSettle() : await pump();
  }
}
