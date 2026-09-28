//
//  TodoStats.swift
//  FutureEdu
//

import Foundation

// A plain value struct used purely to carry data from the view model to a
// screen — the most common shape a struct takes in a Swift app.
struct TodoStats {
    let total: Int
    let active: Int
    let completed: Int
}
