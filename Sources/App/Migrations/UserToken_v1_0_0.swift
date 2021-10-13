//
//  File.swift
//  
//
//  Created by Bllgo on 2021/10/12.
//

import Foundation
import Fluent

extension UserToken {
    struct Migration: Fluent.Migration {
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(UserToken.schema).delete()
        }
        
        var name: String { "CreatUserToken" }
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(UserToken.schema)
                .id()
                .field("value",.string,.required)
                .field("user_id",.uuid,.required, .references(User.schema, "id"))
                .unique(on: "value")
                .create()
        }
    }
}
