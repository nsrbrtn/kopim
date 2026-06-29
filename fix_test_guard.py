import os
import glob

def fix_fake_repo():
    files = glob.glob('test/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'r') as file:
            content = file.read()
            
        modified = False
        if "syncConflictDao: " in content and "syncDispatchGuard:" not in content:
            content = content.replace("syncConflictDao: ", "syncDispatchGuard: SyncDispatchGuard(),\n      syncConflictDao: ")
            modified = True
        
        if modified:
            if 'import \'package:kopim/core/services/sync/sync_dispatch_guard.dart\';' not in content:
                 content = 'import \'package:kopim/core/services/sync/sync_dispatch_guard.dart\';\n' + content
            with open(f, 'w') as file:
                file.write(content)
                
fix_fake_repo()
