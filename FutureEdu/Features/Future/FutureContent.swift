//
//  FutureContent.swift
//  FutureEdu
//
//  Data for the Future tab: upcoming projects and docs.
//  Texts are localization keys in Resources/Localizable.xcstrings:
//    future.<id>.title / future.<id>.summary / future.<id>.f1…f3
//    docs.<id>.title   / docs.<id>.body
//

import UIKit

enum ReleaseStatus {
    case inProgress
    case planned
    case research

    var titleKey: String {
        switch self {
        case .inProgress: return "future.status.inProgress"
        case .planned: return "future.status.planned"
        case .research: return "future.status.research"
        }
    }

    var color: UIColor {
        switch self {
        case .inProgress: return .systemGreen
        case .planned: return .systemBlue
        case .research: return .systemOrange
        }
    }
}

struct FutureProject {
    let id: String
    let iconName: String
    let tint: UIColor
    let status: ReleaseStatus
    let version: String
    let featureCount: Int

    var title: String { L10n.tr("future.\(id).title") }
    var summary: String { L10n.tr("future.\(id).summary") }
    var features: [String] { (1...featureCount).map { L10n.tr("future.\(id).f\($0)") } }

    static let all: [FutureProject] = [
        FutureProject(id: "notes", iconName: "note.text", tint: .systemYellow,
                      status: .inProgress, version: "1.1", featureCount: 3),
        FutureProject(id: "focus", iconName: "timer", tint: .systemRed,
                      status: .planned, version: "1.2", featureCount: 3),
        FutureProject(id: "flashcards", iconName: "rectangle.on.rectangle.angled", tint: .systemPurple,
                      status: .planned, version: "1.3", featureCount: 3),
        FutureProject(id: "habits", iconName: "flame", tint: .systemOrange,
                      status: .research, version: "2.0", featureCount: 3)
    ]
}

struct DocEntry {
    let id: String
    let iconName: String
    let tint: UIColor

    var title: String { L10n.tr("docs.\(id).title") }
    var body: String { L10n.tr("docs.\(id).body") }

    static let all: [DocEntry] = [
        DocEntry(id: "architecture", iconName: "square.stack.3d.up", tint: .systemIndigo),
        DocEntry(id: "release", iconName: "shippingbox", tint: .systemTeal),
        DocEntry(id: "localization", iconName: "globe", tint: .systemGreen)
    ]
}
