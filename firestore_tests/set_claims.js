const admin = require('firebase-admin');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');

// Парсинг аргументов командной строки
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const apply = args.includes('--apply');
const revoke = args.includes('--revoke');
const confirmProd = args.includes('--confirm-prod');

let projectId = null;
const projectIndex = args.indexOf('--project');
if (projectIndex !== -1 && projectIndex + 1 < args.length) {
  projectId = args[projectIndex + 1];
}

// Валидация аргументов
if (!dryRun && !apply) {
  console.error("Error: You must specify either --dry-run or --apply.");
  process.exit(2);
}

if (dryRun && apply) {
  console.error("Error: --dry-run and --apply are mutually exclusive. Choose only one.");
  process.exit(2);
}

if (apply && !projectId) {
  console.error("Error: --apply requires a target Firebase project specified via --project <projectId>.");
  process.exit(2);
}

if (projectId === 'kopim-prod' && apply && !confirmProd) {
  console.error("Error: Modifying production requires the --confirm-prod flag.");
  process.exit(2);
}

const uids = [
  'Y6fAgQX9ZBTYreHpD8JxqjuBnH42',
  '2uQQVczYPuQwjralgDuUctLF8XJ3',
  '7oAr5hmEqzg9McHoMzj4Ub6uETd2',
  'xjBXNMwWaGfiV85QRve2lpapSDQ2',
  'RlYJFDy2cuP4CS74jpeLHe9Sacs2',
  'X0XJCTbvCQQ8BcYERnr0rKcnDyv2'
];

const expiresAtStr = "2026-12-27T00:00:00Z";
const expiresAtUnix = Math.floor(new Date(expiresAtStr).getTime() / 1000);

// Инициализация Firebase Admin SDK (если не dry-run)
let db, auth;
if (apply) {
  console.log(`Initializing Firebase Admin for project: ${projectId}`);
  
  let credential = null;
  try {
    const fs = require('fs');
    const path = require('path');
    const os = require('os');
    const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config.tokens && config.tokens.access_token) {
        credential = {
          getAccessToken: () => Promise.resolve({
            access_token: config.tokens.access_token,
            expires_in: 3600
          })
        };
        console.log("Authenticated using Firebase CLI user credentials.");
      }
    }
  } catch (err) {
    console.warn("Warning: Failed to load credentials from firebase-tools.json:", err.message);
  }

  admin.initializeApp({
    credential: credential || admin.applicationDefault(),
    projectId: projectId
  });
  db = getFirestore();
  auth = getAuth();
}

console.log("\n========================================");
console.log(`Execution Mode: ${dryRun ? 'DRY-RUN (Simulation)' : 'APPLY (Write)'}`);
console.log(`Target Project: ${projectId || 'N/A'}`);
console.log(`Operation Type: ${revoke ? 'REVOKE Access' : 'GRANT Access'}`);
console.log(`Users Count:    ${uids.length}`);
if (!revoke) {
  console.log(`Expiry Date:    ${expiresAtStr} (Unix: ${expiresAtUnix})`);
}
console.log("========================================\n");

const summary = [];
let hasErrors = false;

async function processUser(uid) {
  const result = { uid, success: true, entitlementState: null, claimsState: null, error: null };
  try {
    if (revoke) {
      // REVOCATION FLOW
      if (dryRun) {
        result.entitlementState = "Simulated update entitlements/{uid} to status='inactive'";
        result.claimsState = "Simulated removing cloud claims, keeping other claims";
      } else {
        // 1. Обновляем Firestore entitlements
        const entitlementRef = db.collection('entitlements').doc(uid);
        const doc = await entitlementRef.get();
        if (doc.exists) {
          await entitlementRef.update({
            status: 'inactive',
            updatedAt: FieldValue.serverTimestamp()
          });
          result.entitlementState = "Firestore entitlement status set to 'inactive'";
        } else {
          result.entitlementState = "Firestore entitlement document not found, skipped";
        }

        // 2. Считываем и мержим custom claims (удаляем только cloud claims)
        const user = await auth.getUser(uid);
        const existingClaims = user.customClaims || {};
        const { cloudAccess, cloudPlan, cloudAccessExpiresAt, ...otherClaims } = existingClaims;
        
        await auth.setCustomUserClaims(uid, otherClaims);
        result.claimsState = `Auth claims updated (cloud claims removed). Merged claims: ${JSON.stringify(otherClaims)}`;
      }
    } else {
      // GRANT ACCESS FLOW
      if (dryRun) {
        result.entitlementState = "Simulated set/merge entitlements/{uid} with status='trialActive'";
        result.claimsState = `Simulated setting cloud claims: cloudAccess=true, cloudPlan='testerCloud', cloudAccessExpiresAt=${expiresAtUnix}`;
      } else {
        // 1. Записываем в Firestore (идемпотентно, не перезаписывая createdAt)
        const entitlementRef = db.collection('entitlements').doc(uid);
        const doc = await entitlementRef.get();
        
        const now = FieldValue.serverTimestamp();
        if (doc.exists) {
          // Если документ существует, делаем update только изменившихся полей
          await entitlementRef.update({
            status: 'trialActive',
            plan: 'testerCloud',
            expiresAt: Timestamp.fromDate(new Date(expiresAtStr)),
            source: 'manual',
            note: '6 month free tester access',
            updatedAt: now
          });
          result.entitlementState = "Firestore entitlement updated (createdAt preserved)";
        } else {
          // Если документа нет, создаем его полностью
          await entitlementRef.set({
            status: 'trialActive',
            plan: 'testerCloud',
            expiresAt: Timestamp.fromDate(new Date(expiresAtStr)),
            source: 'manual',
            note: '6 month free tester access',
            createdAt: now,
            updatedAt: now
          });
          result.entitlementState = "Firestore entitlement created (new document)";
        }

        // 2. Считываем и мержим custom claims
        const user = await auth.getUser(uid);
        const existingClaims = user.customClaims || {};
        
        const mergedClaims = {
          ...existingClaims,
          cloudAccess: true,
          cloudPlan: 'testerCloud',
          cloudAccessExpiresAt: expiresAtUnix
        };
        
        await auth.setCustomUserClaims(uid, mergedClaims);
        result.claimsState = `Auth claims updated. Merged claims: ${JSON.stringify(mergedClaims)}`;
      }
    }
  } catch (err) {
    result.success = false;
    result.error = err.message;
    hasErrors = true;
  }
  summary.push(result);
}

async function main() {
  for (const uid of uids) {
    await processUser(uid);
  }

  console.log("\n================ EXECUTION SUMMARY ================");
  summary.forEach((item) => {
    if (item.success) {
      console.log(`\nUID: ${item.uid} - SUCCESS`);
      console.log(`  Entitlement: ${item.entitlementState}`);
      console.log(`  Claims:      ${item.claimsState}`);
    } else {
      console.error(`\nUID: ${item.uid} - FAILED`);
      console.error(`  Error:       ${item.error}`);
    }
  });
  console.log("\n===================================================\n");

  if (hasErrors) {
    console.error("Execution completed with errors. One or more users failed.");
    process.exit(1);
  } else {
    console.log("All operations completed successfully.");
    process.exit(0);
  }
}

main();
