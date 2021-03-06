//
//  EventSummary.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 28.04.16.
//  Copyright © 2016 cargath. All rights reserved.
//

// MARK: - Summary implementation

public struct EventSummary: SummaryProtocol {

    /**
     * The path to the individual event resource.
     */
    public let resourceURI: String?

    /**
     * The name of the event.
     */
    public let name: String?

}

// MARK: - Summary + JSONObjectConvertible

extension EventSummary {

    public init?(JSONObject: JSONObject) {
        self.resourceURI = JSONObject["resourceURI"] as? String
        self.name = JSONObject["name"] as? String
    }

}

// MARK: - Typealias used in the Marvel API docs

public typealias EventList = List<EventSummary>
