//
//  UserInfo+DTO.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/3/26.
//

public extension UserInfo {

    nonisolated
    struct DTO: Codable & WatchTransferrable & Equatable {

        public var restSeconds: Int

        public var hasLearnedTimeKeeper: Bool

        public var hasWatchCompletedInitialSync: Bool

        public var useAutomaticRepDetection: Bool
    }

    func getDTO() -> DTO {

        return DTO(
            restSeconds: restSeconds,
            hasLearnedTimeKeeper: hasLearnedTimeKeeper,
            hasWatchCompletedInitialSync: hasWatchCompletedInitialSync,
            useAutomaticRepDetection: useAutomaticRepDetection
        )
    }

    convenience init(fromDTO dto: DTO) {

        self.init(
            restSeconds: dto.restSeconds,
            hasLearnedTimeKeeper: dto.hasLearnedTimeKeeper,
            hasWatchCompletedInitialSync: dto.hasWatchCompletedInitialSync,
            useAutomaticRepDetection: dto.useAutomaticRepDetection
        )
    }
}
