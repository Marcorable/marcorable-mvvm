#!/usr/bin/env python3
"""Tuist가 생성한 pbxproj에서 표시용 가상 그룹들을 정리한다.

Tuist는 프로젝트 네비게이터에 다음 가상 그룹을 만들며, 이를 끄는 옵션이 없다:
- 'Project': 소스 폴더들을 감싸는 래퍼 → 자식들을 메인 그룹으로 올리고 제거
- 'Packages': 로컬 패키지의 표시용 폴더 참조 → 제거 (실제 의존은 packageReferences가 담당)
- 'Products': 빌드 산출물 표시용 → 제거 (타깃의 productReference가 별도로 참조)

사용법: python3 Scripts/flatten_project_group.py <project.pbxproj>...
"""

import re
import sys


def find_group_block(text, name):
    """이름이 name인 PBXGroup 블록을 찾아 (전체 블록, id, children 줄들)을 반환."""
    match = re.search(
        r"\t\t(?P<id>[0-9A-F]{24}) /\* " + re.escape(name) + r" \*/ = \{\n"
        r"\t\t\tisa = PBXGroup;\n"
        r"\t\t\tchildren = \(\n"
        r"(?P<children>(?:\t\t\t\t[^\n]*\n)*)"
        r"\t\t\t\);\n"
        r"\t\t\tname = " + re.escape(name) + r";\n"
        r"(?:\t\t\t[^\n]*\n)*?"
        r"\t\t\};\n",
        text,
    )
    return match


def remove_reference(text, group_id, name):
    """부모 children 목록에서 그룹 참조 한 줄을 제거."""
    return text.replace(f"\t\t\t\t{group_id} /* {name} */,\n", "")


def flatten_project_group(text):
    """'Project' 래퍼 그룹의 자식들을 부모로 올리고 그룹을 제거."""
    block = find_group_block(text, "Project")
    if not block:
        return text, False
    text = text.replace(block.group(0), "")
    reference = f"\t\t\t\t{block.group('id')} /* Project */,\n"
    if reference not in text:
        raise SystemExit("'Project' 그룹 참조를 찾지 못했다")
    return text.replace(reference, block.group("children")), True


def remove_display_group(text, name, drop_child_file_refs):
    """표시용 그룹(Packages/Products)을 제거한다."""
    block = find_group_block(text, name)
    if not block:
        return text, False
    text = text.replace(block.group(0), "")
    text = remove_reference(text, block.group("id"), name)

    if name == "Products":
        text = re.sub(r"\t\t\tproductRefGroup = [0-9A-F]{24} /\* Products \*/;\n", "", text)

    if drop_child_file_refs:
        # 그룹 자식이던 표시용 PBXFileReference(폴더 참조)도 함께 제거
        for child_id in re.findall(r"([0-9A-F]{24}) /\*", block.group("children")):
            text = re.sub(
                r"\t\t" + child_id + r" /\* [^\n]* \*/ = \{isa = PBXFileReference;[^\n]*\};\n",
                "",
                text,
            )
    return text, True


def process(path):
    with open(path, encoding="utf-8") as f:
        original = f.read()

    text = original
    text, _ = flatten_project_group(text)
    text, _ = remove_display_group(text, "Packages", drop_child_file_refs=True)
    text, _ = remove_display_group(text, "Products", drop_child_file_refs=False)

    if text != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        return True
    return False


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for pbxproj in sys.argv[1:]:
        changed = process(pbxproj)
        print(f"{'cleaned' if changed else 'no changes'}: {pbxproj}")
