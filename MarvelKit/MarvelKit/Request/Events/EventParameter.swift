//
//  EventParameter.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 15.05.16.
//  Copyright © 2016 cargath. All rights reserved.
//

public enum EventParameter {

    public enum Order: String {

        // name
        case NameAscending = "name"
        case NameDescending = "-name"

        // start date
        case StartDateAscending = "startDate"
        case StartDateDescending = "-startDate"

        // modified since
        case ModifiedAscending = "modified"
        case ModifiedDescending = "-modified"
        
    }

    /**
     * Return only events which match the specified name.
     */
    case name(String)

    /**
     * Return events with names that begin with the specified string (e.g. Sp).
     */
    case nameStartsWith(String)

    /**
     * Return only events which have been modified since the specified date.
     */
    case modifiedSince(Date)

    /**
     * Return only events which feature work by the specified creators.
     */
    case creators([Int])

    /**
     * Return only events which feature the specified characters.
     */
    case characters([Int])

    /**
     * Return only events which are part of the specified series.
     */
    case series([Int])

    /**
     * Return only events which take place in the specified comics.
     */
    case comics([Int])

    /**
     * Return only events which take place in the specified stories.
     */
    case stories([Int])

    /**
     * Order the result set by a field or fields.
     * Multiple values are given priority in the order in which they are passed.
     */
    case orderBy([Order])

    /**
     * Limit the result set to the specified number of resources.
     */
    case limit(Int)

    /**
     * Skip the specified number of resources in the result set.
     */
    case offset(Int)

}

extension EventParameter: ResourceParameterProtocol {

    public var key: String {
        switch self {
            case .name:
                return "name"
            case .nameStartsWith:
                return "nameStartsWith"
            case .modifiedSince:
                return "modifiedSince"
            case .creators:
                return "creators"
            case .characters:
                return "characters"
            case .series:
                return "series"
            case .comics:
                return "comics"
            case .stories:
                return "stories"
            case .orderBy:
                return "orderBy"
            case .limit:
                return "limit"
            case .offset:
                return "offset"
        }
    }

    public var value: String {
        switch self {
            case let .name(value):
                return value
            case let .nameStartsWith(value):
                return value
            case let .modifiedSince(value):
                return value.string
            case let .creators(value):
                return value.csv
            case let .characters(value):
                return value.csv
            case let .series(value):
                return value.csv
            case let .comics(value):
                return value.csv
            case let .stories(value):
                return value.csv
            case let .orderBy(value):
                return value.flatMap({ $0.rawValue }).csv
            case let .limit(value):
                return "\(value)"
            case let .offset(value):
                return "\(value)"
        }
    }
    
}
