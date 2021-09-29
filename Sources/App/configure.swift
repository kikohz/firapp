import Fluent
import FluentMySQLDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder  启用中间件，未public文件夹中的文件提供服务
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    /// config max upload file size
    app.routes.defaultMaxBodySize = "10mb"
    app.views.use(.leaf)  //告诉程序使用leaf来做我们的视图
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.logger.info("start configure")
    //数据库操作
    app.databases.use(.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "127.0.0.1",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 27119, //MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "user",
        password: Environment.get("DATABASE_PASSWORD") ?? "testmysql",
        database: Environment.get("DATABASE_NAME") ?? "vapor"
    ), as: .mysql)

    
    let modules: [Module] = [AppModule()]
    for module in modules {
        try module.configure(app)
    }
    
    print(app.directory.workingDirectory)
    print(app.directory.publicDirectory)
    print(app.directory.resourcesDirectory)
    print(app.directory.viewsDirectory)
    
    //自定义端口号
//    app.http.server.configuration.hostname = "127.0.0.1"
//    app.http.server.configuration.port = 8081
}
