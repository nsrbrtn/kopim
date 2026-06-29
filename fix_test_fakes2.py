import os
import glob
import re

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        
        # Add bool activationCompleted = true, to the signature of saveEnabledState
        if "Future<void> saveEnabledState({" in content and "activationCompleted = true" not in content:
            content = content.replace("Future<void> saveEnabledState({", "Future<void> saveEnabledState({\n    bool activationCompleted = true,")
            modified = True
            
        if modified:
            with open(f, 'w') as file:
                file.write(content)
                
fix_fake_repo()
