//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/24.
//

import Vapor
import Fluent

struct AppModule: Module {
    var router:RouteCollection? {
        AppRouter()
    }
    
    var migrations: [Migration] {
        [AppInfo_v1_0_0()]
    }
}
