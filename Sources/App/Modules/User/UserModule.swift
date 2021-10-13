//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Vapor
import Fluent

struct UserModule: Module {
    var router:RouteCollection? {
        UserRouter()
    }
    
    var migrations: [Migration] {
        [UserMigration_v1_0_0(),UserSeederL(),UserToken.Migration()]
    }
}
