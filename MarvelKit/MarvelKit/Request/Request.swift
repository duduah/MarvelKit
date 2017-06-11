//
//  Request.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 16.05.16.
//  Copyright © 2016 cargath. All rights reserved.
//

public typealias DataResourceProtocol = DataProtocol & ResourceProtocol

open class Request<Resource: DataResourceProtocol> {

    var url: URL?

    // MARK: Internal initializers

    init(resource: Resource.Type, authentication: Authentication) {
        url = resource.absoluteURL()?.appendingParameters(authentication.params())
    }

    init(resource: Resource.Type, authentication: Authentication, id: Int) {
        url = resource.absoluteURL(id: id)?.appendingParameters(authentication.params())
    }

    init(resource: Resource.Type, authentication: Authentication, filter: ResourceFilter<Resource.ResourceFilterType>) {
        url = resource.absoluteURL(filter: filter)?.appendingParameters(authentication.params())
    }

    // MARK: Public builders

    public func withParameters(_ parameters: [Resource.ResourceParameterType]) -> Request<Resource> {
        url = url?.appendingParameters(parameters.urlParameters)
        return self
    }
    
}
