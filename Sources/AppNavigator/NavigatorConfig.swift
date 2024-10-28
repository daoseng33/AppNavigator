public typealias URLHandlerFactory = (_ queryParameters: [String: String], _ context: Any?) -> Bool
public typealias APIURLHandlerFactory = (_ onSuccess: String, _ onFailure: String, _ queryParameters: [String: String], _ context: Any?) -> Bool

public protocol NavigatorConfig {
    var name: String { get }
    var handler: URLHandlerFactory { get }
}

public protocol APINavigatorConfig {
    var name: String { get }
    var handler: APIURLHandlerFactory { get }
}
