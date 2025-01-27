//
//  Report.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//


import UIKit

struct Report {
    var type: ReportType
    var description: String
    var location: String
    var isAnonymous: Bool = true
    var images: [UIImage] = []
} 
