import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        struct Context:Encodable {
            let title:String
            let body:String
        }
        let context = Context(title: "myProject - Leaf", body: "Hello Leaf!")
        return req.view.render("index", context)
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: TodoController() as! RouteCollection)
}
