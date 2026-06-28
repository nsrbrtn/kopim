const assert = require('assert');

const {
  buildClaimsAudit,
  mergeGrantClaims,
  stripCloudClaims,
} = require('./set_claims_contract');

describe('set_claims_contract', () => {
  it('preserves unrelated claims when granting cloud access', () => {
    const beforeClaims = {
      role: 'support',
      betaAccess: true,
      cloudAccess: false,
      cloudPlan: 'trial',
      cloudAccessUntilMillis: 1,
    };

    const afterClaims = mergeGrantClaims(beforeClaims, {
      cloudPlan: 'manual',
      cloudAccessUntilMillis: 123456789,
    });

    assert.deepStrictEqual(afterClaims, {
      role: 'support',
      betaAccess: true,
      cloudAccess: true,
      cloudPlan: 'manual',
      cloudAccessUntilMillis: 123456789,
    });

    assert.deepStrictEqual(buildClaimsAudit(beforeClaims, afterClaims), {
      before: {
        cloudAccess: false,
        cloudPlan: 'trial',
        cloudAccessUntilMillis: 1,
      },
      after: {
        cloudAccess: true,
        cloudPlan: 'manual',
        cloudAccessUntilMillis: 123456789,
      },
      preservedClaimKeys: ['betaAccess', 'role'],
    });
  });

  it('removes only cloud claims when revoking access', () => {
    const beforeClaims = {
      role: 'support',
      betaAccess: true,
      cloudAccess: true,
      cloudPlan: 'manual',
      cloudAccessUntilMillis: 123456789,
    };

    const afterClaims = stripCloudClaims(beforeClaims);

    assert.deepStrictEqual(afterClaims, {
      role: 'support',
      betaAccess: true,
    });

    assert.deepStrictEqual(buildClaimsAudit(beforeClaims, afterClaims), {
      before: {
        cloudAccess: true,
        cloudPlan: 'manual',
        cloudAccessUntilMillis: 123456789,
      },
      after: {
        cloudAccess: undefined,
        cloudPlan: undefined,
        cloudAccessUntilMillis: undefined,
      },
      preservedClaimKeys: ['betaAccess', 'role'],
    });
  });
});
