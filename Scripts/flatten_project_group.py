#!/usr/bin/env python3
"""Tuist가 생성한 pbxproj에서 가상 'Project' 래퍼 그룹을 제거한다.

Tuist는 소스 폴더들을 'Project'라는 가상 그룹으로 감싸는데, 이를 끄는 옵션이 없다.
이 스크립트는 'Project' 그룹의 자식들을 부모(메인 그룹)로 올리고 그룹을 삭제해,
Xcode가 직접 만든 프로젝트와 같은 평평한 구조를 만든다.

사용법: python3 Scripts/flatten_project_group.py <project.pbxproj>...
"""

import re
import sys


def flatten(path: str) -> bool:
    with open(path, encoding="utf-8") as f:
        text = f.read()

    # 'Project' 가상 그룹 블록을 찾는다: ID /* Project */ = { isa = PBXGroup; children = (...); name = Project; ... };
    block = re.search(
        r"\t\t(?P<id>[0-9A-F]{24}) /\* Project \*/ = \{\n"
        r"\t\t\tisa = PBXGroup;\n"
        r"\t\t\tchildren = \(\n"
        r"(?P<children>(?:\t\t\t\t[^\n]*\n)*)"
        r"\t\t\t\);\n"
        r"\t\t\tname = Project;\n"
        r"(?:\t\t\t[^\n]*\n)*?"
        r"\t\t\};\n",
        text,
    )
    if not block:
        return False

    # 그룹 블록을 삭제하고, 부모 children 목록의 참조 자리에 자식들을 인라인한다.
    text = text.replace(block.group(0), "")
    reference = f"\t\t\t\t{block.group('id')} /* Project */,\n"
    if reference not in text:
        raise SystemExit(f"{path}: 'Project' 그룹 참조를 찾지 못했다")
    text = text.replace(reference, block.group("children"))

    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    return True


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for pbxproj in sys.argv[1:]:
        changed = flatten(pbxproj)
        print(f"{'flattened' if changed else 'no Project group'}: {pbxproj}")
