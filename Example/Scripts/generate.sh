#!/bin/sh
# tuist generate + 'Project' 래퍼 그룹 평탄화까지 한 번에 수행한다.
# 프로젝트 구조를 바꿨을 때는 tuist generate 대신 이 스크립트를 사용할 것.
set -e
cd "$(dirname "$0")/.."

tuist generate --no-open "$@"
python3 Scripts/flatten_project_group.py Apps/*/*.xcodeproj/project.pbxproj
