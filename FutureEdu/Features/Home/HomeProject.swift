//
//  HomeProject.swift
//  FutureEdu
//
//  Projects that are released and available on the Home tab.
//  To add a new project: append an entry to `HomeProject.all`.
//

import UIKit

struct HomeProject {
    let id: String
    let iconName: String
    let tint: UIColor
    /// Short live status shown under the title (e.g. "Active: 3").
    let subtitle: () -> String
    let makeViewController: () -> UIViewController

    var title: String { L10n.tr("home.project.\(id).title") }

    static var all: [HomeProject] {
        [
            HomeProject(
                id: "todo",
                iconName: "checklist",
                tint: .systemBlue,
                subtitle: {
                    let remaining = TodoRepositoryImpl().getTodos().filter { !$0.isCompleted }.count
                    return L10n.tr("home.project.todo.subtitle", remaining)
                },
                makeViewController: { TodoViewController() }
            )
        ]
    }
}
