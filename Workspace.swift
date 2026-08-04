
import ProjectDescription

let workspace = Workspace(
    name: "MarcorableMVVM",
    projects: [
        "Examples/*"
    ],
    additionalFiles: [
        .folderReference(path: "Packages/SharedKit"),
        .folderReference(path: "Packages/MarcorableMVVM"),
        .folderReference(path: "Packages/Common"),
        .glob(pattern: "Docs/COMPARISON.md"),
        .glob(pattern: "README.md"),
    ]
)
