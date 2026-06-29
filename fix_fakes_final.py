import re

files = [
    'test/features/profile/presentation/data_mode_controller_test.dart',
    'test/features/profile/application/cloud_activation_execution_service_test.dart',
    'test/features/profile/application/fresh_upload_execution_service_test.dart',
    'test/features/profile/application/local_to_cloud_migration_integration_test.dart'
]

in_progress_template = """
  @override
  Future<void> saveInProgressScenario({
    required String uid,
    required String scenario,
  }) async {
    {state_var} = CloudActivationState(
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

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    modified = False
    
    if "Future<void> saveEnabledState({" in content:
        # Determine if the class uses `state =` or `savedState =`
        state_var = "state"
        if "savedState =" in content:
            state_var = "savedState"
            
        # Add activationCompleted: true to the signature
        if "bool activationCompleted = true," not in content:
            content = content.replace("Future<void> saveEnabledState({", "Future<void> saveEnabledState({\n    bool activationCompleted = true,")
            modified = True
            
        # Add activationCompleted: activationCompleted to CloudActivationState inside saveEnabledState
        # Note: only do this if it's not already there
        pattern = re.compile(r'(%s = CloudActivationState\([\s\S]*?version:\s*1,)\s*(?!\s*activationCompleted:)' % state_var)
        if pattern.search(content):
            content = pattern.sub(r'\1\n      activationCompleted: activationCompleted,', content)
            modified = True
            
        # Add saveInProgressScenario
        if "Future<void> saveInProgressScenario" not in content:
            in_progress = in_progress_template.replace("{state_var}", state_var)
            content = content.replace("Future<void> saveEnabledState({", in_progress + "\n  @override\n  Future<void> saveEnabledState({")
            modified = True

    if modified:
        with open(f, 'w') as file:
            file.write(content)

