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
  'accounts',
  'categories',
  'tags',
  'transaction_tags',
  'transactions',
  'credits',
  'credit_cards',
  'debts',
  'profile',
  'progress',
  'budgets',
  'budget_instances',
  'saving_goals',
  'recurring_payments',
  'reminders',
  'credit_payment_groups',
  'credit_payment_schedules',
  'sync_registry'
];

describe("Kopim Firestore Security Rules", () => {
  let testEnv;
  const futureExpiry = Math.floor(Date.now() / 1000) + 3600; // +1 hour
  const pastExpiry = Math.floor(Date.now() / 1000) - 3600; // -1 hour

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync(RULES_PATH, "utf8"),
        host: "127.0.0.1",
        port: 8080
      },
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  // Вспомогательная функция для получения Firestore контекста с claims
  function getDb(userId, claims = null) {
    if (!userId) {
      return testEnv.unauthenticatedContext().firestore();
    }
    return testEnv.authenticatedContext(userId, claims || undefined).firestore();
  }

  describe("Entitlements collection (/entitlements/{userId})", () => {
    const userId = "user123";

    it("should allow owner to read their own entitlement", async () => {
      const db = getDb(userId);
      // Сначала установим документ через admin контекст
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("entitlements").doc(userId).set({ status: "active" });
      });
      await assertSucceeds(db.collection("entitlements").doc(userId).get());
    });

    it("should deny other users to read user entitlement", async () => {
      const db = getDb("other_user");
      await assertFails(db.collection("entitlements").doc(userId).get());
    });

    it("should deny unauthenticated users to read entitlement", async () => {
      const db = getDb(null);
      await assertFails(db.collection("entitlements").doc(userId).get());
    });

    it("should deny client write to entitlements (even if owner)", async () => {
      const db = getDb(userId, { cloudAccess: true, cloudPlan: "testerCloud", cloudAccessExpiresAt: futureExpiry });
      await assertFails(db.collection("entitlements").doc(userId).set({ status: "trialActive" }));
      await assertFails(db.collection("entitlements").doc(userId).update({ status: "trialActive" }));
      await assertFails(db.collection("entitlements").doc(userId).delete());
    });
  });

  describe("Sync collections access based on Custom Claims", () => {
    const userId = "user123";

    // 1. Проверяем каждую разрешенную коллекцию на запись при валидном testerCloud claim
    SYNC_COLLECTIONS.forEach((collection) => {
      it(`should allow create, update, delete in users/{userId}/${collection} for active testerCloud claim`, async () => {
        const db = getDb(userId, {
          cloudAccess: true,
          cloudPlan: "testerCloud",
          cloudAccessExpiresAt: futureExpiry
        });
        const docRef = db.collection("users").doc(userId).collection(collection).doc("doc1");

        await assertSucceeds(docRef.set({ test: "value" }));
        await assertSucceeds(docRef.update({ test: "value2" }));
        await assertSucceeds(docRef.delete());
      });

      it(`should allow create, update, delete in users/{userId}/${collection} for active paidCloud claim`, async () => {
        const db = getDb(userId, {
          cloudAccess: true,
          cloudPlan: "paidCloud",
          cloudAccessExpiresAt: futureExpiry
        });
        const docRef = db.collection("users").doc(userId).collection(collection).doc("doc1");

        await assertSucceeds(docRef.set({ test: "value" }));
        await assertSucceeds(docRef.update({ test: "value2" }));
        await assertSucceeds(docRef.delete());
      });
    });

    it("should deny write if cloudAccess is false", async () => {
      const db = getDb(userId, {
        cloudAccess: false,
        cloudPlan: "testerCloud",
        cloudAccessExpiresAt: futureExpiry
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if cloudPlan is unknown", async () => {
      const db = getDb(userId, {
        cloudAccess: true,
        cloudPlan: "unknown",
        cloudAccessExpiresAt: futureExpiry
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if cloudAccessExpiresAt is in the past", async () => {
      const db = getDb(userId, {
        cloudAccess: true,
        cloudPlan: "testerCloud",
        cloudAccessExpiresAt: pastExpiry
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if cloudAccessExpiresAt is not an integer", async () => {
      const db = getDb(userId, {
        cloudAccess: true,
        cloudPlan: "testerCloud",
        cloudAccessExpiresAt: "futureExpiry" // string
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if expiresAt equals current request time", async () => {
      // Так как в тесте мы не можем легко симулировать точное совпадение request.time.seconds() с константой claim,
      // мы передадим значение, равное текущему Unix-времени (что практически совпадет с временем выполнения правила на сервере)
      const nowSec = Math.floor(Date.now() / 1000);
      const db = getDb(userId, {
        cloudAccess: true,
        cloudPlan: "testerCloud",
        cloudAccessExpiresAt: nowSec
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if no auth token claims", async () => {
      const db = getDb(userId, {}); // no claims
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write if unauthenticated", async () => {
      const db = getDb(null);
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should deny write to other user's data", async () => {
      const db = getDb("other_user", {
        cloudAccess: true,
        cloudPlan: "testerCloud",
        cloudAccessExpiresAt: futureExpiry
      });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
    });

    it("should allow owner to read their data even without active cloudAccess claim", async () => {
      const db = getDb(userId, { cloudAccess: false });
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1");
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc(userId).collection("accounts").doc("doc1").set({ balance: 100 });
      });
      await assertSucceeds(docRef.get());
    });
  });

  describe("Paths restrictions and fallback denies", () => {
    const userId = "user123";
    const activeClaims = {
      cloudAccess: true,
      cloudPlan: "testerCloud",
      cloudAccessExpiresAt: Math.floor(Date.now() / 1000) + 3600
    };

    it("should deny write to unknown collections inside /users/{userId}", async () => {
      const db = getDb(userId, activeClaims);
      const docRef = db.collection("users").doc(userId).collection("unknown_collection").doc("doc1");
      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("should deny write to root /users/{userId} document itself", async () => {
      const db = getDb(userId, activeClaims);
      const docRef = db.collection("users").doc(userId);
      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("should deny write/read to nested paths deeper than doc level", async () => {
      const db = getDb(userId, activeClaims);
      const docRef = db.collection("users").doc(userId).collection("accounts").doc("doc1").collection("deeper").doc("subdoc");
      await assertFails(docRef.set({ test: "value" }));
      await assertFails(docRef.get());
    });

    it("should deny access to any other root collection (fallback deny)", async () => {
      const db = getDb(userId, activeClaims);
      await assertFails(db.collection("random_root_collection").doc("doc1").set({ test: "value" }));
      await assertFails(db.collection("random_root_collection").doc("doc1").get());
    });
  });

  describe("Batch Write compatibility", () => {
    const userId = "user123";
    const activeClaims = {
      cloudAccess: true,
      cloudPlan: "testerCloud",
      cloudAccessExpiresAt: Math.floor(Date.now() / 1000) + 3600
    };

    it("should allow batch writing of 50 documents to allowlisted collections", async () => {
      const db = getDb(userId, activeClaims);
      const batch = db.batch();
      
      for (let i = 0; i < 50; i++) {
        // Чередуем разные коллекции для реалистичности batch sync
        const collection = SYNC_COLLECTIONS[i % SYNC_COLLECTIONS.length];
        const docRef = db.collection("users").doc(userId).collection(collection).doc(`doc_${i}`);
        batch.set(docRef, { data: `value_${i}` });
      }
      
      await assertSucceeds(batch.commit());
    });
  });
});
