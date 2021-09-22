//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/16.
//

import Foundation
import Vapor
import Fluent

extension FieldKey {
    static var phone:Self{"phone"}
}

final class UserModel: Model, Content {
    static let schema = "userinfo"      //对应数据库表名
    
    @ID(key: .id)           //表中主键 id
    
    var id: UUID?
    
    @Field(key: .phone)
    var phone:String
    
    @Field(key: "passwd")
    var passwd:String
    
    @Field(key: "nickname")
    var nickname:String
    
    init() {}
    
    init(id:UUID? = nil, phone: String, passwd:String, nickname:String = "") {
        self.id = id
        self.phone = phone
        self.passwd = passwd
        self.nickname = nickname
    }
}

//扩展api用到model
extension UserCreateObject: Content{}
extension UserGetObject:Content{}

extension UserModel {
    func create(_ input: UserCreateObject) {
        phone = input.phone
        passwd = input.passwd
    }
    func mapGet() ->UserGetObject {
        .init( id: id!, phone: phone, nickname: nickname)
    }
}
