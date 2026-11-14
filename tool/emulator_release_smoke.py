"""Signed-APK smoke checks on an explicitly selected Android emulator only.

Standard library + Android SDK tools. Never clears data, uninstalls, signs,
changes device settings, or targets a physical device. Evidence stays in build/.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET
from datetime import datetime, timezone

PACKAGE = "com.ahmedhassan.passthephone"
CERT = "68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575"
APK_HASH = "B601237EDDA7A421B10C67B784A2EF01D3E01D1053080D2359F6186068FE1386"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--serial", required=True)
    parser.add_argument("--api", required=True, type=int)
    parser.add_argument("--page-size", required=True, type=int)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--evidence", required=True, type=Path)
    args = parser.parse_args()
    if not re.fullmatch(r"emulator-\d+", args.serial):
        parser.error("Only an explicit emulator serial is accepted")
    root = Path(__file__).resolve().parents[1]
    evidence = args.evidence.resolve()
    if not evidence.is_relative_to(root / "build"):
        parser.error("Evidence must be inside this workspace's build directory")
    evidence.mkdir(parents=True, exist_ok=True)
    sdk = Path(os.environ["LOCALAPPDATA"]) / "Android/sdk"
    adb = sdk / "platform-tools/adb.exe"
    report = {
        "started_utc": datetime.now(timezone.utc).isoformat(),
        "serial": args.serial,
        "status": "RUNNING",
        "checks": [],
    }
    counter = 0

    def run(*command, binary=False):
        result = subprocess.run(command, capture_output=True, timeout=180)
        if result.returncode:
            raise RuntimeError(f"Command failed ({result.returncode}): {command}: "
                               + result.stderr.decode("utf-8", "replace"))
        return result.stdout if binary else result.stdout.decode("utf-8", "replace")

    def device(*command, binary=False):
        return run(str(adb), "-s", args.serial, *command, binary=binary)

    def check(name, condition, details=None):
        report["checks"].append({"name": name, "pass": bool(condition), "details": details})
        print(f"{'PASS' if condition else 'FAIL'}: {name}", flush=True)
        if not condition:
            raise AssertionError(name)

    def window(label, expected=None):
        nonlocal counter
        # Cold emulators can briefly expose only the empty Flutter host view.
        # Poll for a populated semantics tree (and the expected next screen)
        # rather than treating one stale dump as a completed transition.
        tree = None
        for _ in range(5):
            time.sleep(0.8)
            device("shell", "uiautomator", "dump", "/sdcard/ptp-qa-window.xml")
            raw = device("exec-out", "cat", "/sdcard/ptp-qa-window.xml", binary=True)
            tree = ET.fromstring(raw)
            populated = any(node.get("text") or node.get("content-desc") for node in tree.iter("node"))
            if populated and (expected is None or locate(tree, expected) is not None):
                break
        counter += 1
        (evidence / f"{counter:02d}-{label}.xml").write_bytes(raw)
        (evidence / f"{counter:02d}-{label}.png").write_bytes(
            device("exec-out", "screencap", "-p", binary=True))
        if expected is not None and locate(tree, expected) is None:
            raise AssertionError(f"Expected screen not ready after bounded wait: {expected}")
        return tree

    def locate(tree, label):
        return next((node for node in tree.iter("node")
                     if any(label in node.get(field, "").splitlines()
                            for field in ("text", "content-desc"))), None)

    def tap(tree, label):
        node = locate(tree, label)
        if node is None:
            raise AssertionError(f"UI target absent: {label}")
        left, top, right, bottom = map(int, re.findall(r"\d+", node.get("bounds", "")))
        x, y = str((left + right) // 2), str((top + bottom) // 2)
        device("shell", "input", "swipe", x, y, x, y, "120")

    def launch():
        result = device("shell", "am", "start", "-W", "-n", f"{PACKAGE}/.MainActivity")
        check("activity launch status", "Status: ok" in result, result.strip())
        time.sleep(2)
        check("release process running", bool(device("shell", "pidof", PACKAGE).strip()))

    def scroll_to(label):
        for _ in range(8):
            tree = window("settings-scroll")
            if locate(tree, label) is not None:
                return tree
            bounds = list(map(int, re.findall(r"\d+", tree.find("node").get("bounds"))))
            width, height = bounds[2], bounds[3]
            device("shell", "input", "swipe", str(width // 2), str(height * 3 // 4),
                   str(width // 2), str(height // 4), "350")
        raise AssertionError(f"Could not scroll to {label}")

    try:
        actual_api = int(device("shell", "getprop", "ro.build.version.sdk").strip())
        actual_pages = int(device("shell", "getconf", "PAGE_SIZE").strip())
        report["environment"] = {
            "api": actual_api, "page_size": actual_pages,
            "model": device("shell", "getprop", "ro.product.model").strip(),
            "avd": device("emu", "avd", "name").strip(),
        }
        check("expected API and page size", actual_api == args.api and actual_pages == args.page_size,
              report["environment"])
        check("boot complete", device("shell", "getprop", "sys.boot_completed").strip() == "1")
        check("approved APK hash", hashlib.sha256(args.apk.read_bytes()).hexdigest().upper() == APK_HASH)
        signature = run(str(sdk / "build-tools/36.0.0/apksigner.bat"), "verify", "--verbose",
                        "--print-certs", str(args.apk.resolve()))
        (evidence / "apk-signature.txt").write_text(signature, encoding="utf-8")
        check("approved APK signer", CERT in signature.lower() and bool(re.search(
            r"Verified using v2 scheme.*: true", signature)))
        install = device("install", "-r", str(args.apk.resolve()))
        (evidence / "install.txt").write_text(install, encoding="utf-8")
        check("signed release installation", "Success" in install, install.strip())
        info = device("shell", "dumpsys", "package", PACKAGE)
        (evidence / "package.txt").write_text(info, encoding="utf-8")
        check("release identity/version", "versionCode=8 " in info and "versionName=0.8.0" in info
              and "targetSdk=36" in info and "DEBUGGABLE" not in info)
        device("shell", "am", "force-stop", PACKAGE)
        launch()
        tree = window("release-home", "PASS THE PHONE")
        check("Home content", locate(tree, "PASS THE PHONE") is not None)
        tap(tree, "ابدأ بسرعة  ·  The Crew")
        tree = window("release-question", "سلّمت الموبايل")
        tap(tree, "سلّمت الموبايل")
        tree = window("release-handoff", "الموبايل وصل؟")
        check("handoff UI", locate(tree, "الموبايل وصل؟") is not None)
        tap(tree, "اكشف السؤال")
        tree = window("release-reveal", "سلّمت الموبايل")
        check("revealed next question UI", locate(tree, "سلّمت الموبايل") is not None)
        tap(tree, "إنهاء اللعبة")
        tree = window("release-exit", "خروج")
        tap(tree, "خروج")
        tree = window("release-home-return", "PASS THE PHONE")
        tap(tree, "الإعدادات")
        tree = window("release-settings", "اهتزازات خفيفة")
        # Toggle haptics OFF through the release UI; preserve and verify it after
        # force-stop. There is no claim of physical perceptibility on an emulator.
        switches = [node for node in tree.iter("node") if node.get("checkable") == "true"]
        check("settings switches available", len(switches) >= 2)
        if switches[1].get("checked") == "true":
            tap(tree, "اهتزازات خفيفة")
        tree = scroll_to("Pass The Phone · 0.8.0 (8)")
        check("installed metadata visible", locate(tree, "Pass The Phone · 0.8.0 (8)") is not None)
        tap(tree, "سياسة الخصوصية")
        time.sleep(2)
        activities = device("shell", "dumpsys", "activity", "activities")
        (evidence / "privacy-activities.txt").write_text(activities, encoding="utf-8")
        resumed = "\n".join(line for line in activities.splitlines() if "mResumedActivity" in line
                            or "topResumedActivity" in line)
        check("external browser activity opened", bool(resumed) and PACKAGE not in resumed
              and any(name in resumed.lower() for name in ("chrome", "browser", "firefox")), resumed)
        window("external-browser")
        launch()
        # Allow the asynchronous settings write time to finish before testing a
        # normal force-stop/relaunch; this is not abrupt-write durability testing.
        device("shell", "am", "force-stop", PACKAGE)
        launch()
        tree = window("release-relaunch", "PASS THE PHONE")
        check("relaunch returns Home", locate(tree, "PASS THE PHONE") is not None)
        tap(tree, "الإعدادات")
        tree = window("release-settings-restored", "اهتزازات خفيفة")
        switches = [node for node in tree.iter("node") if node.get("checkable") == "true"]
        # First two switch nodes are handoff and haptics, as ordered in Settings.
        check("saved haptics OFF survives force-stop", len(switches) >= 2
              and switches[1].get("checked") == "false")
        logcat = device("logcat", "-d", "-t", "2000")
        (evidence / "logcat.txt").write_text(logcat, encoding="utf-8")
        check("no fatal exception/native abort observed", not re.search(
            r"FATAL EXCEPTION|Abort message:|Fatal signal (?:6|11)", logcat))
        report["status"] = "PASS"
    except Exception as error:
        report["status"] = "FAIL"
        report["error"] = str(error)
        print(f"FAIL: {error}", flush=True)
    finally:
        report["finished_utc"] = datetime.now(timezone.utc).isoformat()
        (evidence / "result.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
