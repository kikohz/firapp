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
    static var platform:Self{"platform"}
    static var icon:Self{"icon"}
    static var bundleId:Self{"bundleId"}
    static var bid:Self{"bid"}
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
    
    @Field(key: .platform)
    var platform:String
    
    @Field(key: .icon)
    var icon:String
    
    @Field(key: .bundleId)
    var bundleId:String
    
    @Field(key: .bid)
    var bid:String
    
    init() {}
    
    init(
        id:UUID? = nil ,
        name:String,
        desc:String,
        screenshot:String,
        filePath:String = "",
        platform:String,
        icon:String,
        bundleId:String = "",
        bid:String = "") {
            self.id = id
            self.name = name
            self.desc = desc
            self.screenshot = screenshot
            self.filePath = filePath
            self.bundleId = bundleId
            self.bid = bid
    }
}

extension AppInfo {
    func create(_ input:AppInfpCreateObject) {
        name = input.name
        desc = input.desc
        screenshot = input.scteenshot
        platform = input.platform
        icon = "https://objectstorage.ap-seoul-1.oraclecloud.com/n/cno3iavztv8w/b/mybox/o/appicon.png"     //预留字段，后续接续安装包获取到
        bundleId = input.bundleId
        bid = bundleId.toBase64()
    }
}

//api
struct AppInfpCreateObject:Codable {
    let name:String
    let desc:String
    let scteenshot:String
    let platform:String
    let bundleId:String
}

//通过用户信息查找用户用到模型
struct AppFindObject:Content {
//    var id: String
    var appid: String?
}
//通过bid查找应用信息
//struct AppFindBid:Content {
//    var bid: String?
//}

struct AppFileObject:Codable {
    var filePath: String?
    var infoPlistPath:String?
}

extension AppInfpCreateObject: Content {}
