const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');
const {
  buildClaimsAudit,
  mergeGrantClaims,
  stripCloudClaims,
} = require('./set_claims_contract');

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

let uids = [
  'Y6fAgQX9ZBTYreHpD8JxqjuBnH42',
  '2uQQVczYPuQwjralgDuUctLF8XJ3',
  '7oAr5hmEqzg9McHoMzj4Ub6uETd2',
  'xjBXNMwWaGfiV85QRve2lpapSDQ2',
  'RlYJFDy2cuP4CS74jpeLHe9Sacs2',
  'X0XJCTbvCQQ8BcYERnr0rKcnDyv2'
];
const uidIndex = args.indexOf('--uid');
if (uidIndex !== -1 && uidIndex + 1 < args.length) {
  uids = [args[uidIndex + 1]];
}

const expiresAtStr = "2026-12-27T00:00:00Z";
const accessUntilMillis = new Date(expiresAtStr).getTime();

// Загрузка токена из Firebase CLI config
let token = null;
try {
  const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  if (fs.existsSync(configPath)) {
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config.tokens && config.tokens.access_token) {
      token = config.tokens.access_token;
    }
  }
} catch (e) {
  console.error("Failed to load Firebase CLI token:", e.message);
}

if (apply && !token) {
  console.error("Error: Firebase CLI access token not found. Please run 'firebase login'.");
  process.exit(1);
}

console.log("\n========================================");
console.log(`Execution Mode: ${dryRun ? 'DRY-RUN (Simulation)' : 'APPLY (Write)'}`);
console.log(`Target Project: ${projectId || 'N/A'}`);
console.log(`Operation Type: ${revoke ? 'REVOKE Access' : 'GRANT Access'}`);
console.log(`Users Count:    ${uids.length}`);
if (!revoke) {
  console.log(`Expiry Date:    ${expiresAtStr} (Millis: ${accessUntilMillis})`);
}
console.log("========================================\n");

const summary = [];
let hasErrors = false;

function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(body ? JSON.parse(body) : {});
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${body}`));
        }
      });
    });
    req.on('error', (e) => reject(e));
    if (postData) {
      req.write(JSON.stringify(postData));
    }
    req.end();
  });
}

async function processUser(uid) {
  const result = { uid, success: true, entitlementState: null, claimsState: null, error: null };
  try {
    if (revoke) {
      // REVOCATION FLOW
      if (dryRun) {
        result.entitlementState = "Simulated update entitlements/{uid} to status='inactive'";
        result.claimsState = "Simulated removing cloud claims, keeping other claims";
      } else {
        // 1. Получаем существующий entitlement
        let existingDoc = null;
        try {
          existingDoc = await makeRequest({
            hostname: 'firestore.googleapis.com',
            path: `/v1/projects/${projectId}/databases/(default)/documents/entitlements/${uid}`,
            method: 'GET',
            headers: { 'Authorization': `Bearer ${token}` }
          });
        } catch (e) {
          // 404 is fine, doc doesn't exist
        }

        if (existingDoc && existingDoc.fields) {
          const payload = {
            fields: {
              ...existingDoc.fields,
              status: { stringValue: 'inactive' },
              updatedAt: { timestampValue: new Date().toISOString() }
            }
          };
          await makeRequest({
            hostname: 'firestore.googleapis.com',
            path: `/v1/projects/${projectId}/databases/(default)/documents/entitlements/${uid}?updateMask.fieldPaths=status&updateMask.fieldPaths=updatedAt`,
            method: 'PATCH',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }, payload);
          result.entitlementState = "Firestore entitlement status set to 'inactive'";
        } else {
          result.entitlementState = "Firestore entitlement document not found, skipped";
        }

        // 2. Считываем и мержим custom claims (удаляем только cloud claims)
        const lookup = await makeRequest({
          hostname: 'identitytoolkit.googleapis.com',
          path: `/v1/projects/${projectId}/accounts:lookup`,
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }, { localId: [uid] });

        const user = lookup.users && lookup.users[0];
        if (user) {
          const existingClaims = user.customAttributes ? JSON.parse(user.customAttributes) : {};
          const mergedClaims = stripCloudClaims(existingClaims);
          const audit = buildClaimsAudit(existingClaims, mergedClaims);

          await makeRequest({
            hostname: 'identitytoolkit.googleapis.com',
            path: `/v1/projects/${projectId}/accounts:update`,
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }, {
            localId: uid,
            customAttributes: JSON.stringify(mergedClaims)
          });
          result.claimsState = `Auth claims updated (cloud claims removed). Audit: ${JSON.stringify(audit)}`;
        } else {
          throw new Error("User not found in Firebase Auth");
        }
      }
    } else {
      // GRANT ACCESS FLOW
      if (dryRun) {
        result.entitlementState = "Simulated set/merge entitlements/{uid} with status='trialActive'";
        result.claimsState = `Simulated setting cloud claims: cloudAccess=true, cloudPlan='manual', cloudAccessUntilMillis=${accessUntilMillis}`;
      } else {
        // 1. Получаем существующий entitlement (для идемпотентности)
        let existingDoc = null;
        try {
          existingDoc = await makeRequest({
            hostname: 'firestore.googleapis.com',
            path: `/v1/projects/${projectId}/databases/(default)/documents/entitlements/${uid}`,
            method: 'GET',
            headers: { 'Authorization': `Bearer ${token}` }
          });
        } catch (e) {
          // 404
        }

        const nowIso = new Date().toISOString();
        const payload = {
          fields: {
            status: { stringValue: 'trialActive' },
            plan: { stringValue: 'manual' },
            expiresAt: { timestampValue: expiresAtStr },
            source: { stringValue: 'manual' },
            note: { stringValue: '6 month free tester access' },
            updatedAt: { timestampValue: nowIso }
          }
        };

        let updateMaskParams = "?updateMask.fieldPaths=status&updateMask.fieldPaths=plan&updateMask.fieldPaths=expiresAt&updateMask.fieldPaths=source&updateMask.fieldPaths=note&updateMask.fieldPaths=updatedAt";

        if (existingDoc && existingDoc.fields) {
          // Обновляем существующий (createdAt сохраняется)
          await makeRequest({
            hostname: 'firestore.googleapis.com',
            path: `/v1/projects/${projectId}/databases/(default)/documents/entitlements/${uid}${updateMaskParams}`,
            method: 'PATCH',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }, payload);
          result.entitlementState = "Firestore entitlement updated (createdAt preserved)";
        } else {
          // Создаем новый
          payload.fields.createdAt = { timestampValue: nowIso };
          updateMaskParams += "&updateMask.fieldPaths=createdAt";
          await makeRequest({
            hostname: 'firestore.googleapis.com',
            path: `/v1/projects/${projectId}/databases/(default)/documents/entitlements/${uid}${updateMaskParams}`,
            method: 'PATCH',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }, payload);
          result.entitlementState = "Firestore entitlement created (new document)";
        }

        // 2. Считываем и мержим custom claims
        const lookup = await makeRequest({
          hostname: 'identitytoolkit.googleapis.com',
          path: `/v1/projects/${projectId}/accounts:lookup`,
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }, { localId: [uid] });

        const user = lookup.users && lookup.users[0];
        if (user) {
          const existingClaims = user.customAttributes ? JSON.parse(user.customAttributes) : {};
          const mergedClaims = mergeGrantClaims(existingClaims, {
            cloudPlan: 'manual',
            cloudAccessUntilMillis: accessUntilMillis,
          });
          const audit = buildClaimsAudit(existingClaims, mergedClaims);

          await makeRequest({
            hostname: 'identitytoolkit.googleapis.com',
            path: `/v1/projects/${projectId}/accounts:update`,
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }, {
            localId: uid,
            customAttributes: JSON.stringify(mergedClaims)
          });
          result.claimsState = `Auth claims updated. Audit: ${JSON.stringify(audit)}`;
        } else {
          throw new Error("User not found in Firebase Auth");
        }
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
