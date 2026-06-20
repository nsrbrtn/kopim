import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

typedef RemoteCollectionReader =
    Future<List<Map<String, dynamic>>> Function(String uid, String collection);

class CloudSnapshotSummaryService {
  CloudSnapshotSummaryService({
    required FirebaseFirestore firestore,
    RemoteCollectionReader? readCollection,
  }) : _readCollection =
           readCollection ??
           ((String uid, String collection) async {
             final QuerySnapshot<Map<String, dynamic>> snapshot =
                 await firestore
                     .collection('users')
                     .doc(uid)
                     .collection(collection)
                     .limit(1)
                     .get();
             return snapshot.docs
                 .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                   return doc.data();
                 })
                 .toList(growable: false);
           });

  static const Set<String> _metadataCollections = <String>{
    SyncContract.profileCollection,
    SyncContract.progressCollection,
  };

  final RemoteCollectionReader _readCollection;

  Future<CloudSnapshotSummary> summarize(String uid) async {
    final String normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      return const CloudSnapshotSummary(
        state: RemoteSnapshotState.unauthenticated,
        hasUserData: false,
        hasMetadata: false,
        hasTombstonesOnly: false,
        fingerprint: 'remote:unauthenticated',
      );
    }

    bool hasMetadata = false;
    bool hasActiveFinancialData = false;
    bool hasTerminalFinancialData = false;
    final Map<String, String> collectionStates = <String, String>{};

    try {
      for (final String collection in _metadataCollections.toList()..sort()) {
        final List<Map<String, dynamic>> docs = await _readCollection(
          normalizedUid,
          collection,
        );
        if (docs.isNotEmpty) {
          hasMetadata = true;
          collectionStates[collection] = 'metadata';
        } else {
          collectionStates[collection] = 'empty';
        }
      }

      final Iterable<SyncEntityManifestEntry> financialEntries = SyncContract
          .manifest
          .where((SyncEntityManifestEntry entry) {
            final String? collection = entry.remoteCollection;
            return collection != null &&
                !_metadataCollections.contains(collection) &&
                entry.participatesInLoginSync;
          });

      for (final SyncEntityManifestEntry entry in financialEntries) {
        final String collection = entry.remoteCollection!;
        final List<Map<String, dynamic>> docs = await _readCollection(
          normalizedUid,
          collection,
        );
        if (docs.isEmpty) {
          collectionStates[collection] = 'empty';
          continue;
        }

        final bool hasActiveDoc = docs.any(
          (Map<String, dynamic> doc) => !_isTerminalDocument(entry, doc),
        );
        if (hasActiveDoc) {
          hasActiveFinancialData = true;
          collectionStates[collection] = 'active';
          break;
        }

        hasTerminalFinancialData = true;
        collectionStates[collection] = 'terminal';
      }
    } on FirebaseException catch (error) {
      final RemoteSnapshotState state = switch (error.code) {
        'permission-denied' => RemoteSnapshotState.permissionDenied,
        'unauthenticated' => RemoteSnapshotState.unauthenticated,
        'unavailable' ||
        'network-request-failed' ||
        'deadline-exceeded' => RemoteSnapshotState.unavailable,
        _ => RemoteSnapshotState.unknown,
      };
      return CloudSnapshotSummary(
        state: state,
        hasUserData: false,
        hasMetadata: false,
        hasTombstonesOnly: false,
        fingerprint: 'remote:${state.name}|uid:$normalizedUid',
      );
    } catch (_) {
      return CloudSnapshotSummary(
        state: RemoteSnapshotState.unknown,
        hasUserData: false,
        hasMetadata: false,
        hasTombstonesOnly: false,
        fingerprint: 'remote:unknown|uid:$normalizedUid',
      );
    }

    final RemoteSnapshotState state;
    if (hasActiveFinancialData) {
      state = RemoteSnapshotState.hasUserData;
    } else if (hasTerminalFinancialData && !hasMetadata) {
      state = RemoteSnapshotState.hasTombstonesOnly;
    } else if (hasTerminalFinancialData && hasMetadata) {
      state = RemoteSnapshotState.unknown;
    } else if (hasMetadata) {
      state = RemoteSnapshotState.hasOnlyMetadata;
    } else {
      state = RemoteSnapshotState.empty;
    }

    final String collectionsFingerprint = collectionStates.entries
        .map((MapEntry<String, String> entry) {
          return '${entry.key}:${entry.value}';
        })
        .join(',');

    return CloudSnapshotSummary(
      state: state,
      hasUserData: hasActiveFinancialData,
      hasMetadata: hasMetadata,
      hasTombstonesOnly: hasTerminalFinancialData && !hasActiveFinancialData,
      fingerprint:
          'remote:${state.name}|uid:$normalizedUid|$collectionsFingerprint',
    );
  }

  bool _isTerminalDocument(
    SyncEntityManifestEntry entry,
    Map<String, dynamic> doc,
  ) {
    return switch (entry.deleteSemantics) {
      SyncDeleteSemantics.tombstone => doc['isDeleted'] as bool? ?? false,
      SyncDeleteSemantics.deactivate => !(doc['isActive'] as bool? ?? true),
      SyncDeleteSemantics.complete => doc['isDone'] as bool? ?? false,
      SyncDeleteSemantics.archive =>
        doc['archivedAt'] != null || (doc['isArchived'] as bool? ?? false),
      SyncDeleteSemantics.localOnly ||
      SyncDeleteSemantics.remoteDocumentDelete => false,
    };
  }
}

final Provider<CloudSnapshotSummaryService>
cloudSnapshotSummaryServiceProvider = Provider<CloudSnapshotSummaryService>((
  Ref ref,
) {
  return CloudSnapshotSummaryService(firestore: ref.watch(firestoreProvider));
});
