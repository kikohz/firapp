//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Vapor
import Fluent

struct TodoModule: Module {
    var router:RouteCollection? {
        TodoRouter()
    }
    
    var migrations: [Migration] {
        [CreateTodo()]
    }
}
