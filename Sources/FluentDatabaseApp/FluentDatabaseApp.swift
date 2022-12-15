import Vapor
import Fluent
import FluentPostgresDriver

public class FluentReproducer {
    let vaporApp: Vapor.Application

    /// Create an OAuth server Application
    public init() throws {
        var logger = Logger(label: "Fluent Reproducer")
        logger.logLevel = .debug
        logger.info("Starting Reproducer Server...")
        let env = try Environment.detect()
        let vaporApp = Vapor.Application(env)
        vaporApp.logger = logger
        
        let dbHost = Environment.get("DB_HOST")!
        let dbUser = Environment.get("DB_USER")!
        let dbPass = Environment.get("DB_PASSWORD") ?? ""
        let dbName = Environment.get("DB_NAME")!
        
        vaporApp.databases.use(.postgres(hostname: dbHost, port: 5432, username: dbUser, password: dbPass, database: dbName), as: .psql)
        

        self.vaporApp = vaporApp
        
        // just makes sure to hit the database and return a response once finished
        self.vaporApp.get("query") { req -> EventLoopFuture<Response> in
            return Site.query(on: req.db).all().flatMap { sites in
                return req.eventLoop.makeSucceededFuture(Response(status: .ok, version: .http1_1, headers: .init(), body: .init(string: sites.map { $0.name}.joined(separator: " "))))
            }
        }
    }

    /// Boot the OAuth Server
    public func start() throws {
        try vaporApp.run()
    }
}

final class Site: Model {
    static let schema = "Site"
    
    @ID(custom: "ID")
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() {}
}
