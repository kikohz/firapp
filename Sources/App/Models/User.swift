//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/16.
//

import Foundation
import Vapor
import Fluent
//import CommonCrypto

extension FieldKey {
    static var phone:Self{"phone"}
}

final class User: Model, Content {
    static let schema = "userinfo"      //对应数据库表名
    
    @ID(key: .id)           //表中主键 id
    
    var id: UUID?
    
    @Field(key: .phone)
    var phone:String
    
    @Field(key: "passwd")
    var passwd:String
    
    @Field(key: "nickname")
    var nickname:String?
    
    init() {}
    
    init(id:UUID? = nil, phone: String, passwd:String, nickname:String? = nil) {
        self.id = id
        self.phone = phone
        self.passwd = passwd
        self.nickname = nickname
    }
}

//api 解析用到的结构
extension User {
    //创建用户
    struct Create:Content {
        var phone:String
        var passwd:String
        var nickname:String?
    }
    //获取用户信息
    struct Get:Content {
        var phone:String
        var nickname:String?
    }
    //查找用户
    struct Find:Content {
        var phone:String?
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("phone", as: String.self, is: !.empty /*&& .count(11...)*/ )
//        validations.add("nickname", as: String.self, is: !.empty)
        validations.add("passwd", as: String.self, is: .count(8...))
    }
}

extension User {
    func create(_ input: User.Create ,_ req:Request) throws{
        phone = input.phone
//        let digest = Insecure.MD5.hash(data: input.passwd.data(using: .utf8) ?? Data())
//        passwd = digest.map {
//            String(format: "%02hhx", $0)
//        }.joined()
        let digest = try req.password.hash(input.passwd)
        passwd = digest
        nickname = input.nickname
    }
    func mapGet() ->User.Get {
        .init( phone: phone, nickname: nickname)
    }
    
    func generateToken() throws ->UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User:ModelAuthenticatable {
    static let usernameKey = \User.$phone
    static let passwordHashKey = \User.$passwd

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwd)
    }
}
