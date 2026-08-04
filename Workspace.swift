import ProjectDescription

let workspace = Workspace(
    name: "MarcorableMVVM",
    projects: [
        "Examples/*"
    ],
    additionalFiles: [
        // 로컬 패키지들을 워크스페이스 최상위에서 직접 열람/편집할 수 있게 참조한다.
        .folderReference(path: "Packages/SharedKit"),
        .folderReference(path: "Packages/MarcorableMVVM"),
        .folderReference(path: "Packages/Common"),
        .glob(pattern: "Docs/COMPARISON.md"),
        .glob(pattern: "README.md"),
    ]
)
