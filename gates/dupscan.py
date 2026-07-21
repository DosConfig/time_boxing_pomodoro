#!/usr/bin/env python3
import argparse
import hashlib
import os
import re
import sys

DART_KEYWORDS = set("""abstract else import super as enum in switch assert export
interface sync async extends is this await extension late throw base factory
library true break false mixin try case final new typedef catch finally null var
class for on void const func operator when continue if part while covariant
implements yield default required do dynamic return get set external""".split())
COMMENT_RE = re.compile(r"//[^\n]*|/\*.*?\*/", re.S)
STRING_RE = re.compile(r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"", re.S)
WORD_RE = re.compile(r"[A-Za-z_$][A-Za-z0-9_$]*")
SIG_RE = re.compile(r"([A-Za-z_$][A-Za-z0-9_$]*)\s*\([^;{}]*\)\s*(?:async\*?|sync\*?)?\s*\{")

def normalize(body):
    body = COMMENT_RE.sub(" ", body)
    body = STRING_RE.sub("''", body)
    body = WORD_RE.sub(lambda match: match.group(0) if match.group(0) in DART_KEYWORDS else "ID", body)
    return re.sub(r"\s+", "", body)

def extract_functions(source):
    output = []
    for match in SIG_RE.finditer(source):
        name = match.group(1)
        if name in DART_KEYWORDS:
            continue
        start = source.index("{", match.start())
        depth = 0
        end = start
        while end < len(source):
            if source[end] == "{":
                depth += 1
            elif source[end] == "}":
                depth -= 1
                if depth == 0:
                    break
            end += 1
        normalized = normalize(source[start + 1:end])
        tokens = normalized.count("ID") + len(re.findall(r"[{}();]", normalized))
        output.append((name, normalized, tokens))
    return output

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="*", default=["lib"])
    parser.add_argument("--min-tokens", type=int, default=25)
    args = parser.parse_args()
    allow_path = "gates/dupscan-allow.txt"
    allow = set()
    if os.path.exists(allow_path):
        with open(allow_path, encoding="utf-8") as file:
            allow = {line.strip() for line in file if line.strip() and not line.startswith("#")}
    groups = {}
    for root in args.paths:
        for directory, _, files in os.walk(root):
            for filename in files:
                if not filename.endswith(".dart") or filename.endswith((".g.dart", ".freezed.dart")):
                    continue
                path = os.path.join(directory, filename)
                try:
                    with open(path, encoding="utf-8") as file:
                        source = file.read()
                except (OSError, UnicodeError):
                    continue
                for name, normalized, tokens in extract_functions(source):
                    if tokens < args.min_tokens:
                        continue
                    digest = hashlib.sha1(normalized.encode()).hexdigest()[:12]
                    if digest not in allow:
                        groups.setdefault(digest, []).append((path, name))
    duplicates = {key: values for key, values in groups.items() if len(set(values)) > 1}
    if not duplicates:
        print("dupscan: 유사 구현 없음")
        return 0
    print("dupscan: 구조가 동일한 유사 구현이 발견되었습니다.")
    for digest, locations in duplicates.items():
        print(f"\n[{digest}] 같은 로직 구조 {len(locations)}곳:")
        for path, name in locations:
            print(f"  {path} :: {name}()")
    print("\n하나로 합치거나, 의도적 중복이면 해시를 gates/dupscan-allow.txt에 등록할 것.")
    return 1

if __name__ == "__main__":
    sys.exit(main())
