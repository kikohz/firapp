//
//  File.swift
//  
//
//  Created by Bllgo on 2021/9/17.
//

import Vapor
struct TodoRouter :RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todoController = TodoController()
        let todos = routes.grouped("todos")
        todos.get(use: todoController.index)
        todos.post(use: todoController.create)
        todos.group(":todoID") { todo in
            todo.delete(use: todoController.delete)
        }
    }
}
