
import ProjectDescription

let workspace = Workspace(
    name: "Example",
    projects: [
        "Apps/*"
    ],
    additionalFiles: [
        .folderReference(path: "../Sources"),
        .folderReference(path: "Packages/SharedKit"),
        .folderReference(path: "Packages/Common"),
        .glob(pattern: "Docs/COMPARISON.md"),
        .glob(pattern: "../README.md"),
    ]
)
