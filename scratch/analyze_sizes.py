import json
import os
import re

def clean_package_name(path):
    # 1. Внешние пакеты
    if ".pub-cache/hosted/pub.dev/" in path:
        match = re.search(r"\.pub-cache/hosted/pub.dev/([^/]+)", path)
        if match:
            folder = match.group(1)
            parts = folder.split("-")
            if len(parts) > 1 and parts[-1].replace(".", "").isdigit():
                return f"package:{'-'.join(parts[:-1])}"
            return f"package:{folder}"
    
    # 2. Фреймворк Flutter
    if "/packages/flutter/lib/src/" in path:
        return "package:flutter_framework"
    
    # 3. Внутренние пакеты Flutter SDK
    if "/packages/" in path:
        match = re.search(r"/packages/([^/]+)", path)
        if match:
            return f"package:flutter_sdk/{match.group(1)}"

    # 4. Dart SDK
    if "org-dartlang-sdk:///dart-sdk/lib/" in path:
        match = re.search(r"org-dartlang-sdk:///dart-sdk/lib/([^/]+)", path)
        if match:
            return f"dart:{match.group(1)}"
        return "dart:sdk"
        
    # 5. Flutter Web Engine
    if "org-dartlang-sdk:///lib/_engine/" in path or "org-dartlang-sdk:///lib/ui/" in path:
        return "package:flutter_web_engine"

    # 6. Собственный код приложения (kopim)
    if "../../../lib/" in path or path.startswith("lib/"):
        rel_path = path.replace("../../../lib/", "").replace("lib/", "")
        parts = rel_path.split("/")
        if len(parts) > 1 and parts[0] == "features":
            return f"app_feature:{parts[1]}"
        elif len(parts) > 1 and parts[0] == "core":
            return f"app_core:{parts[1]}"
        return "app:other"

    if path == "[no source]":
        return "meta:unmapped_or_no_source"

    return "other/misc"

def main():
    json_path = "/home/artem/StudioProjects/kopim/build/web/size_analysis.json"
    if not os.path.exists(json_path):
        print(f"Error: {json_path} not found.")
        return

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    files_data = {}
    if "results" in data:
        for result in data["results"]:
            if "files" in result:
                files_data.update(result["files"])
    elif "files" in data:
        files_data = data["files"]

    packages = {}
    app_details = {}
    
    for filepath, fileinfo in files_data.items():
        size = fileinfo if isinstance(fileinfo, int) else fileinfo.get("size", 0)
        pkg = clean_package_name(filepath)
        packages[pkg] = packages.get(pkg, 0) + size
        
        if pkg.startswith("app_feature:") or pkg.startswith("app_core:") or pkg.startswith("app:"):
            app_details[filepath] = app_details.get(filepath, 0) + size

    sorted_packages = sorted(packages.items(), key=lambda x: x[1], reverse=True)
    sorted_app = sorted(app_details.items(), key=lambda x: x[1], reverse=True)

    total_mapped = sum(packages.values())
    
    print("\n" + "="*80)
    print(f" {'TOP 35 HEAVIEST PACKAGES IN MAIN.DART.JS':^78}")
    print("="*80)
    print(f"{'Package/Component':<45} | {'Size (KB)':<12} | {'Percentage':<10}")
    print("-"*80)
    for name, size in sorted_packages[:35]:
        size_kb = size / 1024
        percentage = (size / total_mapped) * 100 if total_mapped > 0 else 0
        print(f"{name:<45} | {size_kb:<12.2f} | {percentage:<10.2f}%")

    print("\n" + "="*80)
    print(f" {'TOP 20 HEAVIEST FILES IN APP CODE (lib/)':^78}")
    print("="*80)
    print(f"{'File Path':<65} | {'Size (KB)':<12}")
    print("-"*80)
    for path, size in sorted_app[:20]:
        clean_path = path.replace("../../../", "")
        print(f"{clean_path:<65} | {size/1024:<12.2f}")

if __name__ == "__main__":
    main()
