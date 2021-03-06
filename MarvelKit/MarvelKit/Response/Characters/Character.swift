//
//  Character.swift
//  MarvelKit
//
//  Created by Carsten Könemann on 29.04.16.
//  Copyright © 2016 cargath. All rights reserved.
//

// MARK: - Data implementation

public struct Character: DataProtocol {

    /**
     * The unique ID of the character resource.
     */
    public let id: Int?

    /**
     * The name of the character.
     */
    public let name: String?

    /**
     * A short bio or description of the character.
     */
    public let description: String?

    /**
     * The date the resource was most recently modified.
     */
    public let modified: String?

    /**
     * The canonical URL identifier for this resource.
     */
    public let resourceURI: String?

    /**
     * A set of public web site URLs for the resource.
     */
    public let urls: [Url]

    /**
     * The representative image for this character.
     */
    public let thumbnail: Image?

    /**
     * A resource list containing comics which feature this character.
     */
    public let comics: ComicList?

    /**
     * A resource list of stories in which this character appears.
     */
    public let stories: StoryList?

    /**
     * A resource list of events in which this character appears.
     */
    public let events: EventList?

    /**
     * A resource list of series in which this character appears.
     */
    public let series: SeriesList?

}

// MARK: - Character + JSONObjectConvertible

extension Character {

    public init?(JSONObject: JSONObject) {
        self.id = JSONObject["id"] as? Int
        self.name = JSONObject["name"] as? String
        self.description = JSONObject["description"] as? String
        self.modified = JSONObject["modified"] as? String
        self.resourceURI = JSONObject["resourceURI"] as? String
        self.urls = Url.from(JSONArray: JSONObject["urls"] as? JSONArray)
        self.thumbnail = Image(JSONObject: JSONObject["thumbnail"] as? JSONObject)
        self.comics = ComicList(JSONObject: JSONObject["comics"] as? JSONObject)
        self.stories = StoryList(JSONObject: JSONObject["stories"] as? JSONObject)
        self.events = EventList(JSONObject: JSONObject["events"] as? JSONObject)
        self.series = SeriesList(JSONObject: JSONObject["series"] as? JSONObject)
    }

}

// MARK: - Typealiases used in the Marvel API docs

public typealias CharacterDataContainer = DataContainer<Character>

public typealias CharacterDataWrapper = DataWrapper<CharacterDataContainer>
