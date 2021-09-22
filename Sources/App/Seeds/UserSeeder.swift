//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Fluent
import Foundation
import FluentMySQLDriver

struct UserSeederL: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //添加测试数据
        let user1 = ["phone":"13020077008", "passwd":"123456","nickname":"胖叔叔"]
        let user2 = ["phone":"13099887766", "passwd":"123456","nickname":"瘦子"]
        let user3 = ["phone":"13988997766", "passwd":"123456","nickname":"爷爷"]
//        let userModels = [
//            UserModel( phone: user1["phone"]!, passwd: user1["passwd"]!, nickname: user1["nickname"]!),
//            UserModel( phone: user2["phone"]!, passwd: user2["passwd"]!, nickname: user2["nickname"]!),
//            UserModel( phone: user3["phone"]!, passwd: user3["passwd"]!, nickname: user3["nickname"]!)
//        ]
//        userModels.create(on: req.db)
        return database.eventLoop.flatten([
            UserModel( phone: user1["phone"]!, passwd: user1["passwd"]!, nickname: user1["nickname"]!).save(on: database),
            UserModel( phone: user2["phone"]!, passwd: user2["passwd"]!, nickname: user2["nickname"]!).save(on: database),
            UserModel( phone: user3["phone"]!, passwd: user3["passwd"]!, nickname: user3["nickname"]!).save(on: database),
        ])
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserModel.schema).delete()
    }
}
