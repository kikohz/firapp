//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Fluent
import Vapor

struct UserController {
    
    //创建用户
//    func createUser(req: Request) throws ->EventLoopFuture<String> {
//        let user = try req.content.decode(UserModel.self)
////        return user.save(on: req.db).map {
////            let userResponse =
////            ResponseWrapper
////        }
//
//    }
    
//    private func getUserIdParam(_ req: Request) throws -> UUID {
//        guard let rawId = req.parameters.get(UserModel.idParamKey)
//    }
    
    // MARK - endpoints
    func create(req:Request) throws ->EventLoopFuture<UserGetObject> {
        let input = try req.content.decode(UserCreateObject.self)
        let user = UserModel()
        user.create(input)
        return user.create(on: req.db).map { user.mapGet() }
    }
    
    func get(req:Request) throws ->EventLoopFuture<UserGetObject> {
        UserModel.find(<#T##id: UUID?##UUID?#>, on: req.db)
    }
}
