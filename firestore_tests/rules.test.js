const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const fs = require("fs");
const path = require("path");

const PROJECT_ID = "kopim-rules-test-project";
const RULES_PATH = path.resolve(__dirname, "../firestore.rules");

const SYNC_COLLECTIONS = [
  "accounts",
  "categories",
  "tags",
  "transaction_tags",
  "transactions",
  "credits",
  "credit_cards",
  "debts",
  "profile",
  "progress",
  "budgets",
  "budget_instances",
  "saving_goals",
  "recurring_payments",
  "reminders",
  "credit_payment_groups",
  "credit_payment_schedules",
  "sync_registry",
];

describe("Kopim Firestore Security Rules", () => {
  let testEnv;
  const futureExpiry = Date.now() + 3600 * 1000;
  const pastExpiry = Date.now() - 3600 * 1000;

  function activeClaims(plan = "trial") {
    return {
      cloudAccess: true,
      cloudPlan: plan,
      cloudAccessUntilMillis: futureExpiry,
    };
  }

  function getDb(userId, claims = null) {
    if (!userId) {
      return testEnv.unauthenticatedContext().firestore();
    }
    return testEnv.authenticatedContext(userId, claims || undefined).firestore();
  }

  async function seedCloudState(userId, data) {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("cloud_meta")
        .doc("state")
        .set(data);
    });
  }

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync(RULES_PATH, "utf8"),
        host: "127.0.0.1",
        port: 8080,
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  describe("Entitlements collection (/entitlements/{userId})", () => {
    const userId = "user123";

    it("allows owner to read their own entitlement", async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context
          .firestore()
          .collection("entitlements")
          .doc(userId)
          .set({ status: "active" });
      });

      await assertSucceeds(getDb(userId).collection("entitlements").doc(userId).get());
    });

    it("denies other users to read user entitlement", async () => {
      await assertFails(getDb("other-user").collection("entitlements").doc(userId).get());
    });

    it("denies unauthenticated users to read entitlement", async () => {
      await assertFails(getDb(null).collection("entitlements").doc(userId).get());
    });

    it("denies client writes to entitlements", async () => {
      const db = getDb(userId, activeClaims());
      await assertFails(db.collection("entitlements").doc(userId).set({ status: "trialActive" }));
      await assertFails(db.collection("entitlements").doc(userId).update({ status: "trialActive" }));
      await assertFails(db.collection("entitlements").doc(userId).delete());
    });
  });

  describe("Cloud metadata state machine", () => {
    const userId = "user123";

    it("allows owner to create active metadata with valid claims", async () => {
      const db = getDb(userId, activeClaims());

      await assertSucceeds(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").set({
          cloudDataState: "active",
          updatedAt: new Date(),
        }),
      );
    });

    it("denies metadata create without active claims", async () => {
      const db = getDb(userId, {});

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").set({
          cloudDataState: "active",
          updatedAt: new Date(),
        }),
      );
    });

    it("allows deleted -> freshUploadInProgress only for owner", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertSucceeds(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
        }),
      );
    });

    it("denies deleted -> freshUploadInProgress without active entitlement", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb(userId, {});

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
        }),
      );
    });

    it("denies deleted -> freshUploadInProgress with expired entitlement", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb(userId, {
        cloudAccess: true,
        cloudPlan: "trial",
        cloudAccessUntilMillis: pastExpiry,
      });

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
        }),
      );
    });

    it("denies foreign user metadata transition", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb("other-user", activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
        }),
      );
    });

    it("denies deleted -> active direct transition", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "active",
        }),
      );
    });

    it("denies cleanupPending -> active transition", async () => {
      await seedCloudState(userId, {
        cloudDataState: "cleanupPending",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "active",
        }),
      );
    });

    it("allows freshUploadInProgress -> active transition", async () => {
      await seedCloudState(userId, {
        cloudDataState: "freshUploadInProgress",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertSucceeds(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "active",
        }),
      );
    });

    it("denies active -> freshUploadInProgress transition", async () => {
      await seedCloudState(userId, {
        cloudDataState: "active",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
        }),
      );
    });

    it("denies repeated transition after metadata is already active", async () => {
      await seedCloudState(userId, {
        cloudDataState: "active",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "active",
        }),
      );
    });

    it("denies updates that change protected metadata timestamps", async () => {
      const entitlementExpiresAt = new Date("2026-12-01T00:00:00Z");
      const cloudDeleteAfter = new Date("2026-12-15T00:00:00Z");
      const cloudDeletedAt = new Date("2026-11-01T00:00:00Z");
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        entitlementExpiresAt,
        cloudDeleteAfter,
        cloudDeletedAt,
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());

      await assertFails(
        db.collection("users").doc(userId).collection("cloud_meta").doc("state").update({
          cloudDataState: "freshUploadInProgress",
          cloudDeleteAfter: new Date("2027-01-01T00:00:00Z"),
        }),
      );
    });
  });

  describe("Sync collections access based on claims plus cloud metadata", () => {
    const userId = "user123";

    it("blocks normal writes when cloud metadata is missing", async () => {
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("allows normal create, update, delete when state is active", async () => {
      await seedCloudState(userId, {
        cloudDataState: "active",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertSucceeds(docRef.set({ test: "value" }));
      await assertSucceeds(docRef.update({ test: "value2" }));
      await assertSucceeds(docRef.delete());
    });

    it("allows normal writes during grace before cloudDeleteAfter", async () => {
      await seedCloudState(userId, {
        cloudDataState: "grace",
        cloudDeleteAfter: new Date(Date.now() + 3600 * 1000),
        updatedAt: new Date(),
      });
      const db = getDb(userId, {});
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertSucceeds(docRef.set({ test: "value" }));
      await assertSucceeds(docRef.update({ test: "value2" }));
      await assertSucceeds(docRef.delete());
    });

    it("blocks grace writes after cloudDeleteAfter has passed", async () => {
      await seedCloudState(userId, {
        cloudDataState: "grace",
        cloudDeleteAfter: new Date(Date.now() - 3600 * 1000),
        updatedAt: new Date(),
      });
      const db = getDb(userId, {});
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("blocks writes when cloudDeleteAfter is not a timestamp", async () => {
      await seedCloudState(userId, {
        cloudDataState: "grace",
        cloudDeleteAfter: "2026-12-01T00:00:00Z",
        updatedAt: new Date(),
      });
      const db = getDb(userId, {});
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("blocks normal writes when state is cleanupPending", async () => {
      await seedCloudState(userId, {
        cloudDataState: "cleanupPending",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("blocks normal writes when state is deleted", async () => {
      await seedCloudState(userId, {
        cloudDataState: "deleted",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("allows fresh upload creates while freshUploadInProgress", async () => {
      await seedCloudState(userId, {
        cloudDataState: "freshUploadInProgress",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("fresh-doc");

      await assertSucceeds(docRef.set({ test: "value" }));
    });

    it("blocks updates while freshUploadInProgress", async () => {
      await seedCloudState(userId, {
        cloudDataState: "freshUploadInProgress",
        updatedAt: new Date(),
      });
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context
          .firestore()
          .collection("users")
          .doc(userId)
          .collection("accounts")
          .doc("existing-doc")
          .set({ test: "value" });
      });
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("existing-doc");

      await assertFails(docRef.update({ test: "value2" }));
      await assertFails(docRef.delete());
    });

    it("denies writes if cloudAccess is false and state is active", async () => {
      await seedCloudState(userId, {
        cloudDataState: "active",
        updatedAt: new Date(),
      });
      const db = getDb(userId, {
        cloudAccess: false,
        cloudPlan: "trial",
        cloudAccessUntilMillis: futureExpiry,
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
    });

    it("allows owner to read sync data without active claim", async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context
          .firestore()
          .collection("users")
          .doc(userId)
          .collection("accounts")
          .doc("doc1")
          .set({ balance: 100 });
      });

      await assertSucceeds(getDb(userId, {}).collection("users").doc(userId).collection("accounts").doc("doc1").get());
    });

    it("allows batch writing to allowlisted collections when active", async () => {
      await seedCloudState(userId, {
        cloudDataState: "active",
        updatedAt: new Date(),
      });
      const db = getDb(userId, activeClaims());
      const batch = db.batch();

      for (let i = 0; i < 50; i += 1) {
        const collection = SYNC_COLLECTIONS[i % SYNC_COLLECTIONS.length];
        const docRef = db.collection("users").doc(userId).collection(collection).doc(`doc_${i}`);
        batch.set(docRef, { data: `value_${i}` });
      }

      await assertSucceeds(batch.commit());
    });
  });

  describe("Paths restrictions and fallback denies", () => {
    const userId = "user123";

    it("denies write to unknown collections inside /users/{userId}", async () => {
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId).collection("unknown_collection").doc("doc1");

      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("denies write to root /users/{userId} document itself", async () => {
      const db = getDb(userId, activeClaims());
      const docRef = db.collection("users").doc(userId);

      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("denies write/read to deeper nested paths", async () => {
      const db = getDb(userId, activeClaims());
      const docRef = db
        .collection("users")
        .doc(userId)
        .collection("accounts")
        .doc("doc1")
        .collection("deeper")
        .doc("subdoc");

      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("denies access to unrelated root collections", async () => {
      const db = getDb(userId, activeClaims());

      await assertFails(db.collection("random_root_collection").doc("doc1").set({ test: "value" }));
      await assertFails(db.collection("random_root_collection").doc("doc1").get());
    });
  });
});
