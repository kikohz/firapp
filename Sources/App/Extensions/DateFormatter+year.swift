//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/16.
//

import Foundation

extension DateFormatter {
    static var year: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "y"
        return formatter
    }()
}
