//
//  Exercise+WatchTransferrable.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import Foundation

extension Exercise: WatchTransferrable {
    
    nonisolated
    struct DTO: Codable, WatchTransferrable {
        
        var id2: UUID
        
        var order: Int
        
        var kind: Catalog.Kind
        
        var equipment: Equipment
        
        var setsPlanned: Int
        
        var repsPlanned: Int
        
        var weightPlanned: Weight
        
        var setDetails: [SetDetail]
    }
    
    func getDTO() -> DTO {
        
        return DTO(
            id2: id2,
            order: order,
            kind: kind,
            equipment: equipment,
            setsPlanned: setsPlanned,
            repsPlanned: repsPlanned,
            weightPlanned: weightPlanned,
            setDetails: setDetails
        )
    }
    
    convenience init(fromDTO dto: DTO) {
        
        self.init(
            id2: dto.id2,
            order: dto.order,
            kind: dto.kind,
            equipment: dto.equipment,
            setsPlanned: dto.setsPlanned,
            repsPlanned: dto.repsPlanned,
            weightPlanned: dto.weightPlanned,
            setDetails: dto.setDetails
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

// NOTE: - This is works only in watchOS 27 due to a bug

//extension Exercise: WatchTransferrable {}
//
//extension Exercise {
//    
//    enum CodingKeys: String, CodingKey {
//        
//        case id2
//        case order
//        case kind
//        case equipment
//        case setsPlanned
//        case repsPlanned
//        case weightPlanned
//        case setDetails
//    }
//}
//
//extension Exercise: Decodable {
//    
//    public convenience init(from decoder: Decoder) throws {
//        
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        
//        let id2 = try values.decode(UUID.self, forKey: .id2)
//        let order = try values.decode(Int.self, forKey: .order)
//        let kind = try values.decode(Kind.self, forKey: .kind)
//        let equipment = try values.decode(Equipment.self, forKey: .equipment)
//        let setsPlanned = try values.decode(Int.self, forKey: .setsPlanned)
//        let repsPlanned = try values.decode(Int.self, forKey: .repsPlanned)
//        let weightPlanned = try values.decode(Weight.self, forKey: .weightPlanned)
//        let setDetails = try values.decode([SetDetail].self, forKey: .setDetails)
//        
//        self.init(
//            id2: id2,
//            order: order,
//            kind: kind,
//            equipment: equipment,
//            setsPlanned: setsPlanned,
//            repsPlanned: repsPlanned,
//            weightPlanned: weightPlanned,
//            setDetails: setDetails
//        )
//    }
//}
//
//extension Exercise: Encodable {
//    
//    public func encode(to encoder: Encoder) throws {
//        
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id2, forKey: .id2)
//        try container.encode(order, forKey: .order)
//        try container.encode(kind, forKey: .kind)
//        try container.encode(equipment, forKey: .equipment)
//        try container.encode(setsPlanned, forKey: .setsPlanned)
//        try container.encode(repsPlanned, forKey: .repsPlanned)
//        try container.encode(weightPlanned, forKey: .weightPlanned)
//        try container.encode(setDetails, forKey: .setDetails)
//    }
//}
