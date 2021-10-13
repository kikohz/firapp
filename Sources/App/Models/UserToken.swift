//
//  File.swift
//  
//
//  Created by Bllgo on 2021/10/12.
//

import Fluent
import Vapor

final class UserToken: Model, Content {
    static let schema = "user_tokens"
    
    @ID(key: .id)
    var id:UUID?
    
    @Field(key: "value")       //用来存储token
    var value:String
    
    @Parent(key: "user_id")      //用来关联用户
    var user:User
    
    init() {}
    
    init(id:UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

//验证token
extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    var isValid: Bool {
        true
    }
}
