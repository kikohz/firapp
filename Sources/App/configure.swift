import Fluent
//import FluentMySQLDriver
import FluentPostgresDriver
import Vapor
import Leaf


extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

// configures your application
public func configure(_ app: Application) throws {
    #if os(Linux)
    app.directory.publicDirectory = "/var/www/firapp/file/"
    #endif
    // uncomment to serve files from /Public folder  启用中间件，为public文件夹中的文件提供服务
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    /// config max upload file size
    app.routes.defaultMaxBodySize = "10mb"
    app.views.use(.leaf)  //告诉程序使用leaf来做我们的视图
    app.leaf.cache.isEnabled = app.environment.isRelease
    //配置app 加密
    app.passwords.use(.bcrypt)
    app.logger.info("start configure")
    //数据库操作
    app.databases.use(try .postgres(url: Application.databaseUrl), as: .psql)
//    app.databases.use(.mysql(
//        hostname: Environment.get("DATABASE_HOST") ?? "127.0.0.1",
//        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 27119, //MySQLConfiguration.ianaPortNumber,
//        username: Environment.get("DATABASE_USERNAME") ?? "user",
////        password: Environment.get("DATABASE_PASSWORD") ?? "testmysql",
//        password: Environment.databasePasswd,
//        database: Environment.get("DATABASE_NAME") ?? "vapor"
//    ), as: .mysql)

    
    let modules: [Module] = [AppModule(),UserModule()]
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
