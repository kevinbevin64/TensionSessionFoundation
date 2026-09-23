//
//  Workout+WatchTransferrable.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import Foundation

extension Workout: WatchTransferrable {
    
    nonisolated
    struct DTO: Codable & WatchTransferrable {
        
        var id2: UUID
        
        var order: Int
        
        var name: String
        
        var state: State
        
        var startInstant: Date?
        
        var unsortedExercises: [Exercise.DTO]
    }
    
    func getDTO() -> DTO {
        
        return DTO(
            id2: id2,
            order: order,
            name: name,
            state: state,
            startInstant: startInstant,
            unsortedExercises: unsortedExercises.map { $0.getDTO() }
        )
    }
    
    convenience init(fromDTO dto: DTO) {
        
        self.init(
            id2: dto.id2,
            order: dto.order,
            name: dto.name,
            state: dto.state,
            startInstant: dto.startInstant,
            exercises: dto.unsortedExercises.map { Exercise(fromDTO: $0) }
        )
    }
    
    func dictionaryForm() throws -> [String: Any] {
        
        return try getDTO().dictionaryForm()
    }
    
    convenience init(fromDictionary dictionary: [String: Any]) throws {
        
        let dto = try DTO(fromDictionary: dictionary)
        self.init(fromDTO: dto)
    }
}

//extension Workout: WatchTransferrable {}
//
//extension Workout {
//    
//    enum CodingKeys: String, CodingKey {
//        case id2
//        case order
//        case name
//        case state
//        case startInstant
//        case unsortedExercises
//    }
//}
//
//extension Workout: Decodable {
//    
//    public convenience init(from decoder: Decoder) throws {
//        
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        
//        let id2 = try values.decode(UUID.self, forKey: .id2)
//        let order = try values.decode(Int.self, forKey: .order)
//        let name = try values.decode(String.self, forKey: .name)
//        let state = try values.decode(State.self, forKey: .state)
//        let startInstant = try values.decodeIfPresent(Date.self, forKey: .startInstant)
//        let unsortedExercises = try values.decode([Exercise].self, forKey: .unsortedExercises)
//        
//        self.init(
//            id2: id2,
//            order: order,
//            name: name,
//            state: state,
//            startInstant: startInstant,
//            exercises: unsortedExercises
//        )
//    }
//}
//
//extension Workout: Encodable {
//    
//    public func encode(to encoder: Encoder) throws {
//        
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        
//        try container.encode(id2, forKey: .id2)
//        try container.encode(order, forKey: .order)
//        try container.encode(name, forKey: .name)
//        try container.encode(state, forKey: .state)
//        try container.encodeIfPresent(startInstant, forKey: .startInstant)
//        try container.encode(unsortedExercises, forKey: .unsortedExercises)
//    }
//}
