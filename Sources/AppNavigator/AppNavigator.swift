import URLNavigator
import URLMatcher
import UIKit

public enum URLCategory: String {
    case api
    case component
    case page
    case behavior
}

public struct AppNavigator {
    // MARK: - Properties
    
    private let navigator = Navigator()
    private let scheme: String
    
    // MARK: - Setup
    public init(scheme: String) {
        self.scheme = scheme
    }
    
    public func setup(pageConfigs: [NavigatorConfig] = [],
                      componentConfigs: [NavigatorConfig] = [],
                      apiConfigs: [APINavigatorConfig] = [],
                      behaviorConfigs: [NavigatorConfig] = []) {
        
        let path = "\(scheme)://<category>/<name>"
        
        let pageConfigDict: [String: URLHandlerFactory] = {
            var dict: [String: URLHandlerFactory] = [:]
            
            pageConfigs.forEach { config in
                dict[config.name] = config.handler
            }
            
            return dict
        }()
        
        let apiConfigDict: [String: APIURLHandlerFactory] = {
            var dict: [String: APIURLHandlerFactory] = [:]
            apiConfigs.forEach { config in
                dict[config.name] = config.handler
            }
            
            return dict
        }()
        
        let componentConfigDict: [String: URLHandlerFactory] = {
            var dict: [String: URLHandlerFactory] = [:]
            componentConfigs.forEach { config in
                dict[config.name] = config.handler
            }
            
            return dict
        }()
        
        let behaviorConfigDict: [String: URLHandlerFactory] = {
            var dict: [String: URLHandlerFactory] = [:]
            behaviorConfigs.forEach { config in
                dict[config.name] = config.handler
            }
            
            return dict
        }()
        
        navigator.handle(path) { url, values, context in
            guard let categoryString = values["category"] as? String,
                  let category = URLCategory(rawValue: categoryString),
                  let nameString = values["name"] as? String else {
                      return false
                  }
            
            let queryParameters = url.queryParameters
            
            switch category {
            case .page:
                if let config = pageConfigDict[nameString] {
                    return config(url.queryParameters, context)
                }
                
            case .api:
                if let config = apiConfigDict[nameString],
                   let onSuccess = queryParameters["onSuccess"]?.fromBase64URL(),
                   let onFailure = queryParameters["onFailure"]?.fromBase64URL() {
                    return config(onSuccess, onFailure, queryParameters, context)
                }
                
            case .component:
                if let config = componentConfigDict[nameString] {
                    return config(url.queryParameters, context)
                }
                
            case .behavior:
                if let config = behaviorConfigDict[nameString] {
                    return config(url.queryParameters, context)
                }
            }
            
            return false
        }
    }
    
    public func setupOpenAppStore(appId: String) {
        let path = "itms-apps://apple.com/app/\(appId)"
        
        navigator.handle(path) { url, _, _ in
            guard let url = url.urlValue else {
                return false
            }
            
            UIApplication.shared.open(url)
            
            return true
        }
    }
    
    // MARK: - Open URL
    @discardableResult
    public func open(with url: URLConvertible, context: Any? = nil) -> Bool {
        return navigator.open(url, context: context)
    }
    
    @discardableResult
    public func open(with category: URLCategory, name: String, queryItems: [URLQueryItem]? = nil, context: Any? = nil) -> Bool {
        var deepLink = "\(scheme)://\(category.rawValue)/\(name)"
        
        if let queryItems = queryItems {
            var urlComponent = URLComponents()
            urlComponent.queryItems = queryItems
            
            deepLink += urlComponent.string!
        }
        
        return open(with: deepLink, context: context)
    }
}
