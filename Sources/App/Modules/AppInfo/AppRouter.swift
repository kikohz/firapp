//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Vapor
struct AppRouter:RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appinfo = AppInfoController()
        
        
        routes.post("publish", use: appinfo.publish(req:))
//        let v1Routes = routes.grouped("v1")
//        v1Routes.post(":publish", use: appinfo.publish(req:))
        
        
        
//        let userController = UserController()
//        routes.post("adduser", use: userController.create(req:))
//        //respods to GET /user/xxxx
//        routes.get("user",":userid", use: userController.get(req:))
//
//        //respods to GET /user/phone=xxx
//        routes.get("user", use: userController.userWithPhone(req:))
//
//        routes.on(.DELETE, "user", use: userController.delete(req:))
    }
}
