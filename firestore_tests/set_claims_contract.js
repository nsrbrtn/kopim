const CLOUD_CLAIM_KEYS = Object.freeze([
  'cloudAccess',
  'cloudPlan',
  'cloudAccessUntilMillis',
]);

function extractCloudClaimsSubset(claims = {}) {
  return {
    cloudAccess: claims.cloudAccess,
    cloudPlan: claims.cloudPlan,
    cloudAccessUntilMillis: claims.cloudAccessUntilMillis,
  };
}

function stripCloudClaims(claims = {}) {
  const { cloudAccess, cloudPlan, cloudAccessUntilMillis, ...otherClaims } = claims;
  return otherClaims;
}

function mergeGrantClaims(claims = {}, { cloudPlan, cloudAccessUntilMillis }) {
  return {
    ...claims,
    cloudAccess: true,
    cloudPlan,
    cloudAccessUntilMillis,
  };
}

function listPreservedClaimKeys(beforeClaims = {}, afterClaims = {}) {
  return Object.keys(afterClaims)
    .filter((key) => !CLOUD_CLAIM_KEYS.includes(key) && beforeClaims[key] === afterClaims[key])
    .sort();
}

function buildClaimsAudit(beforeClaims = {}, afterClaims = {}) {
  return {
    before: extractCloudClaimsSubset(beforeClaims),
    after: extractCloudClaimsSubset(afterClaims),
    preservedClaimKeys: listPreservedClaimKeys(beforeClaims, afterClaims),
  };
}

module.exports = {
  buildClaimsAudit,
  extractCloudClaimsSubset,
  mergeGrantClaims,
  stripCloudClaims,
};
