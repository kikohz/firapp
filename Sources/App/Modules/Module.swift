//
//  File.swift
//  处理路由和migrations 的协议
//
//  Created by Bllgo on 2021/9/16.
//

import Vapor
import Fluent

protocol Module {
    var router: RouteCollection? { get }
    var migrations: [Migration] { get }
    func configure(_ app: Application) throws
}

extension Module {
    var router: RouteCollection? { nil }
    var migrations: [Migration] { [] }
    
    func configure(_ app: Application ) throws {
        for migration in self.migrations {
            app.migrations.add(migration)
        }
        //注册路由
        if let router = self.router {
            try router.boot(routes: app.routes)
        }
    }
}
