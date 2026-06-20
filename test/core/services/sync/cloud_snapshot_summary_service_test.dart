import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/services/sync/cloud_snapshot_summary_service.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CloudSnapshotSummaryService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = CloudSnapshotSummaryService(firestore: firestore);
  });

  test('returns empty when remote workspace has no documents', () async {
    final CloudSnapshotSummary summary = await service.summarize('user-1');

    expect(summary.state, RemoteSnapshotState.empty);
    expect(summary.hasUserData, isFalse);
    expect(summary.hasMetadata, isFalse);
  });

  test('returns metadata-only when only profile document exists', () async {
    await firestore
        .collection('users')
        .doc('user-1')
        .collection('profile')
        .doc('profile')
        .set(<String, dynamic>{'name': 'Alice'});

    final CloudSnapshotSummary summary = await service.summarize('user-1');

    expect(summary.state, RemoteSnapshotState.hasOnlyMetadata);
    expect(summary.hasMetadata, isTrue);
    expect(summary.hasUserData, isFalse);
  });

  test(
    'returns hasUserData when a financial document exists remotely',
    () async {
      await firestore
          .collection('users')
          .doc('user-1')
          .collection('accounts')
          .doc('acc-1')
          .set(<String, dynamic>{'id': 'acc-1', 'isDeleted': false});

      final CloudSnapshotSummary summary = await service.summarize('user-1');

      expect(summary.state, RemoteSnapshotState.hasUserData);
      expect(summary.hasUserData, isTrue);
    },
  );

  test(
    'returns tombstones-only when financial docs are all terminal',
    () async {
      await firestore
          .collection('users')
          .doc('user-1')
          .collection('transactions')
          .doc('tx-1')
          .set(<String, dynamic>{'id': 'tx-1', 'isDeleted': true});

      final CloudSnapshotSummary summary = await service.summarize('user-1');

      expect(summary.state, RemoteSnapshotState.hasTombstonesOnly);
      expect(summary.hasTombstonesOnly, isTrue);
    },
  );

  test(
    'never normalizes tombstones plus metadata into metadata-only',
    () async {
      await firestore
          .collection('users')
          .doc('user-1')
          .collection('transactions')
          .doc('tx-1')
          .set(<String, dynamic>{'id': 'tx-1', 'isDeleted': true});
      await firestore
          .collection('users')
          .doc('user-1')
          .collection('profile')
          .doc('profile')
          .set(<String, dynamic>{'name': 'Alice'});

      final CloudSnapshotSummary summary = await service.summarize('user-1');

      expect(summary.state, RemoteSnapshotState.unknown);
    },
  );

  test(
    'returns unauthenticated for blank uid without probing firestore',
    () async {
      final CloudSnapshotSummary summary = await service.summarize('');

      expect(summary.state, RemoteSnapshotState.unauthenticated);
    },
  );

  test('maps permission denied and unavailable errors explicitly', () async {
    final CloudSnapshotSummaryService permissionDeniedService =
        CloudSnapshotSummaryService(
          firestore: firestore,
          readCollection: (String uid, String collection) async {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            );
          },
        );
    final CloudSnapshotSummaryService unavailableService =
        CloudSnapshotSummaryService(
          firestore: firestore,
          readCollection: (String uid, String collection) async {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
            );
          },
        );

    final CloudSnapshotSummary permissionDenied = await permissionDeniedService
        .summarize('user-1');
    final CloudSnapshotSummary unavailable = await unavailableService.summarize(
      'user-1',
    );

    expect(permissionDenied.state, RemoteSnapshotState.permissionDenied);
    expect(unavailable.state, RemoteSnapshotState.unavailable);
  });

  test('summary probe is read-only and does not mutate remote docs', () async {
    final DocumentReference<Map<String, dynamic>> doc = firestore
        .collection('users')
        .doc('user-1')
        .collection('accounts')
        .doc('acc-1');
    await doc.set(<String, dynamic>{'id': 'acc-1', 'isDeleted': false});
    final Map<String, dynamic>? before = (await doc.get()).data();

    await service.summarize('user-1');

    final Map<String, dynamic>? after = (await doc.get()).data();
    expect(after, before);
  });
}
