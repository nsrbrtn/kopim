import os
import glob
import re

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        
        # Replace .saveEnabledState(
        # with .saveEnabledState(activationCompleted: true, 
        
        # Using regex to find all calls and inject if not already there
        # but skip the fake repo definition where it's Future<void> saveEnabledState
        # We only want to patch the Mock calls or verifications.
        
        pattern = re.compile(r'\.saveEnabledState\(\s*(?!activationCompleted)')
        
        if pattern.search(content):
            content = pattern.sub('.saveEnabledState(activationCompleted: true, ', content)
            modified = True
            
        if modified:
            with open(f, 'w') as file:
                file.write(content)
                
fix_fake_repo()
