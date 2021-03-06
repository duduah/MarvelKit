//
//  TextObject.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 28.04.16.
//  Copyright © 2016 cargath. All rights reserved.
//

// MARK: - TextObject

public struct TextObject {

    /**
     * The canonical type of the text object (e.g. solicit text, preview text, etc.).
     */
    public let type: String?

    /**
     * The IETF language tag denoting the language the text object is written in.
     */
    public let language: String?

    /**
     * The text.
     */
    public let text: String?

}

// MARK: - TextObject + JSONObjectConvertible

extension TextObject: JSONObjectConvertible {

    public init?(JSONObject: JSONObject) {
        self.type = JSONObject["type"] as? String
        self.language = JSONObject["language"] as? String
        self.text = JSONObject["text"] as? String
    }

}
