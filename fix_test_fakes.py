import os
import glob

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        
        if "Future<void> saveEnabledState({" in content:
            if "activationCompleted: activationCompleted," not in content and "version: 1," in content:
                content = content.replace("version: 1,", "version: 1,\n      activationCompleted: activationCompleted,")
                modified = True
            if "Future<void> saveInProgressScenario({" not in content:
                in_progress = """
  @override
  Future<void> saveInProgressScenario({
    required String uid,
    required String scenario,
  }) async {
    state = CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: DateTime.utc(2024, 1, 1),
      localFingerprint: null,
      remoteFingerprint: null,
      version: 1,
      activationCompleted: false,
    );
  }
"""
                content = content.replace("Future<void> saveEnabledState({", in_progress + "\n  @override\n  Future<void> saveEnabledState({")
                modified = True
        
        if modified:
            with open(f, 'w') as file:
                file.write(content)
                
fix_fake_repo()
