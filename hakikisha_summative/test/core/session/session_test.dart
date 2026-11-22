import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/core/session/session_cubit.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockUser extends Mock implements User {}

class _MockAuth extends Mock implements FirebaseAuth {}

void main() {
  group('FirebaseSessionSource', () {
    User user({required bool verified}) {
      final u = _MockUser();
      when(() => u.emailVerified).thenReturn(verified);
      return u;
    }

    test('maps Firebase users to session statuses', () {
      expect(FirebaseSessionSource.statusOf(null), SessionStatus.signedOut);
      expect(
        FirebaseSessionSource.statusOf(user(verified: false)),
        SessionStatus.unverified,
      );
      expect(
        FirebaseSessionSource.statusOf(user(verified: true)),
        SessionStatus.signedIn,
      );
    });

    test('watch() maps userChanges and drops repeats', () async {
      final auth = _MockAuth();
      final verified = user(verified: true);
      when(auth.userChanges).thenAnswer(
        (_) => Stream.fromIterable([null, verified, verified, null]),
      );

      expect(
        FirebaseSessionSource(auth).watch(),
        emitsInOrder([
          SessionStatus.signedOut,
          SessionStatus.signedIn,
          SessionStatus.signedOut,
          emitsDone,
        ]),
      );
    });

    test('current and signOut delegate to FirebaseAuth', () async {
      final auth = _MockAuth();
      when(() => auth.currentUser).thenReturn(null);
      when(auth.signOut).thenAnswer((_) async {});
      final source = FirebaseSessionSource(auth);

      expect(source.current, SessionStatus.signedOut);
      await source.signOut();
      verify(auth.signOut).called(1);
    });

    test(
      'a custom signOut (e.g. Firebase + Google) replaces the default',
      () async {
        final auth = _MockAuth();
        var customCalls = 0;
        final source = FirebaseSessionSource(
          auth,
          signOut: () async => customCalls++,
        );

        await source.signOut();
        expect(customCalls, 1);
        verifyNever(auth.signOut);
      },
    );
  });

  group('SessionCubit', () {
    test('starts unknown before the source reports', () {
      final cubit = SessionCubit(_NeverSource());
      expect(cubit.state, SessionStatus.unknown);
      cubit.close();
    });

    blocTest<SessionCubit, SessionStatus>(
      'follows the source stream',
      build: () => SessionCubit(FakeSessionSource(SessionStatus.signedOut)),
      act: (_) => Future<void>.delayed(Duration.zero),
      expect: () => [SessionStatus.signedOut],
    );

    blocTest<SessionCubit, SessionStatus>(
      'signOut asks the source and then reports signed out',
      build: () => SessionCubit(FakeSessionSource()),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.signOut();
      },
      expect: () => [SessionStatus.signedIn, SessionStatus.signedOut],
    );

    test('refresh re-reads the current status', () async {
      final source = _NeverSource()..status = SessionStatus.unverified;
      final cubit = SessionCubit(source)..refresh();
      expect(cubit.state, SessionStatus.unverified);
      source.status = SessionStatus.signedIn;
      cubit.refresh();
      expect(cubit.state, SessionStatus.signedIn);
      await cubit.close();
    });

    test('close cancels the source subscription', () async {
      final controller = StreamController<SessionStatus>();
      final cubit = SessionCubit(_StreamSource(controller.stream));
      await cubit.close();
      expect(controller.hasListener, isFalse);
    });
  });
}

/// A source whose stream never emits, to test the initial and refreshed state.
class _NeverSource implements SessionSource {
  SessionStatus status = SessionStatus.signedOut;

  @override
  SessionStatus get current => status;

  @override
  Stream<SessionStatus> watch() => const Stream.empty();

  @override
  Future<void> signOut() async {}
}

class _StreamSource extends _NeverSource {
  _StreamSource(this._stream);

  final Stream<SessionStatus> _stream;

  @override
  Stream<SessionStatus> watch() => _stream;
}
