//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Foundation
import Vapor
import Fluent

extension FieldKey {
    static var name:Self{"name"}
    static var desc:Self{"desc"}
    static var screenshot:Self{"screenshot"}
    static var filePath:Self{"filePath"}
}
final class AppInfo: Model, Content {
    static let schema = "appinfo"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: .name)
    var name:String
    
    @Field(key: .desc)
    var desc:String
    
    @Field(key: .screenshot)
    var screenshot:String
    
    @Field(key: .filePath)
    var filePath:String?
    
    init() {}
    
    init(id:UUID? = nil ,name:String, desc:String, screenshot:String, filePath:String = "") {
        self.id = id
        self.name = name
        self.desc = desc
        self.screenshot = screenshot
        self.filePath = filePath
    }
}

extension AppInfo {
    func create(_ input:AppInfpCreateObject) {
        name = input.name
        desc = input.desc
        screenshot = input.scteenshot
    }
}

//api
struct AppInfpCreateObject:Codable {
    let name:String
    let desc:String
    let scteenshot:String
}

//通过用户信息查找用户用到模型
struct AppFindObject:Content {
//    var id: String
    var appid: String?
}

struct AppFileObject:Codable {
    var filePath: String?
    var infoPlistPath:String?
}

extension AppInfpCreateObject: Content {}
