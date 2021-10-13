//
//  File.swift
//  
//
//  Created by Bllgo on 2021/10/11.
//

import Vapor
extension Environment {
    static let databasePasswd = Self.get("DATABASE_PASSWORD")!.base64Decoded() ?? ""
}
