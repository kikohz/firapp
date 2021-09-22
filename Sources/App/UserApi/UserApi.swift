//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/18.
//

import Foundation

struct UserCreateObject:Codable {
    let phone:String
    let passwd:String
}

struct UserGetObject:Codable {
    let id:UUID
    let phone:String
    let nickname:String?
}
