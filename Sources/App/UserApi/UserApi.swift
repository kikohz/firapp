//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/18.
//

import Foundation
import Vapor

struct UserCreateObject:Codable {
    let phone:String
    let passwd:String
    let nickname:String
}

struct UserGetObject:Codable {
//    let id:UUID?
    let phone:String
    let nickname:String?
}
//通过用户信息查找用户用到模型
struct UserFindObject:Content {
//    var id: String
    var phone: String?
}
