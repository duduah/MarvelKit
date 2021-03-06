//
//  ComicSummary.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 28.04.16.
//  Copyright © 2016 cargath. All rights reserved.
//

// MARK: - Summary implementation

public struct ComicSummary: SummaryProtocol {

    /**
     * The path to the individual comic resource.
     */
    public let resourceURI: String?

    /**
     * The canonical name of the comic.
     */
    public let name: String?
    
}

// MARK: - Summary + JSONObjectConvertible

extension ComicSummary: JSONObjectConvertible {

    public init?(JSONObject: JSONObject) {
        self.resourceURI = JSONObject["resourceURI"] as? String
        self.name = JSONObject["name"] as? String
    }

}

// MARK: - Typealias used in the Marvel API docs

public typealias ComicList = List<ComicSummary>
