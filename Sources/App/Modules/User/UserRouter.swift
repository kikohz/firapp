//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Vapor
struct UserRouter:RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userController = UserController()
        routes.post("adduser", use: userController.create(req:))
        //respods to GET /user/xxxx
        routes.get("user",":userid", use: userController.get(req:))
        
        //respods to GET /user/phone=xxx
        routes.get("user", use: userController.userWithPhone(req:))
        
        routes.on(.DELETE, "user", use: userController.delete(req:))
    }
}
