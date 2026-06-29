import os
import glob

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        if ".saveEnabledState(" in content:
            content = content.replace(".saveEnabledState(", ".saveEnabledState(\nactivationCompleted: true,")
            modified = True
            
        if modified:
            with open(f, 'w') as file:
                file.write(content)
                
fix_fake_repo()
