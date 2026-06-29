import re
import glob

files = glob.glob('test/**/*.dart', recursive=True)

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    modified = False
    
    # We want to find `CloudActivationState(...)` and inject `activationCompleted: true` if missing.
    # It always ends with `version: 1,` usually.
    pattern = re.compile(r'(CloudActivationState\([\s\S]*?version:\s*1,)\s*(?!\s*activationCompleted:)')
    
    if pattern.search(content):
        content = pattern.sub(r'\1\n      activationCompleted: true,', content)
        modified = True

    if modified:
        with open(f, 'w') as file:
            file.write(content)

