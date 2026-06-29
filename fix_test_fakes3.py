import os
import glob

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        
        # fix undefined name state in cloud_activation_execution_service_test.dart
        if "state = CloudActivationState(" in content and "CloudActivationState? state;" not in content:
            # wait, how did it save state before?
            pass
            
        # Fix undefined name activationCompleted in data_mode_controller_test.dart
        content = content.replace("activationCompleted: activationCompleted,", "activationCompleted: true,")
        
        # In mock tests where it uses any(named: 'activationCompleted'), it's failing because mockito doesn't know activationCompleted
        # wait, the error is `The named parameter 'activationCompleted' isn't defined` on saveEnabledState call in the test.
        # This is because the test mocks haven't been regenerated or the mock class doesn't have it!
        # Ah, the Mockito mocks in the test files are generated! We need to run build_runner to regenerate the mocks!
            
        if content != file.read():
            with open(f, 'w') as file:
                file.write(content)
                modified = True
                
fix_fake_repo()
