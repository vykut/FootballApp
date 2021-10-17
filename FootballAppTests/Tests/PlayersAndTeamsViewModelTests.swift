//
//  PlayersAndTeamsViewModelTests.swift
//  FootballAppTests
//
//  Created by vsocaciu on 17.10.2021.
//

import XCTest
import Combine

@testable import FootballApp

class PlayersAndTeamsViewModelTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testPlayersAndTeamsViewModel_initialiser() throws {
        let mockRepository: MockRepository = .init()
        let viewModel: PlayersAndTeamsViewModel = .init(repository: mockRepository)

        XCTAssertNil(viewModel.playersAndTeams)
        XCTAssertEqual(viewModel.listOverlay, .startSearchingLabel)
        XCTAssertEqual(viewModel.networkState, nil)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.isNetworkAlertErrorShown, false)
    }

    func testPlayersAndTeamsViewModel_afterUserWroteInTheSearchField_shouldFetchPlayersAndTeams() throws {
        let mockRepository: MockRepository = .init()
        let mockPlayersAndTeams: PlayersAndTeams = .previewObject()
        mockRepository.playersAndTeamsResponse = .success(mockPlayersAndTeams)

        let viewModel: PlayersAndTeamsViewModel = .init(repository: mockRepository)

        let expectation = self.expectation(description: "playersAndTeams")

        viewModel.$playersAndTeams
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.searchText = "Beck"

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(viewModel.playersAndTeams, mockPlayersAndTeams)
        XCTAssertEqual(viewModel.networkState, nil)
        XCTAssertEqual(viewModel.listOverlay, nil)
    }

    func testPlayersAndTeamsViewModel_afterUserWroteInTheSearchField_shouldShowNetworkAlert() throws {
        let mockRepository: MockRepository = .init()
        mockRepository.playersAndTeamsResponse = .failure(.playersAndTeamsService(.network(.network(statusCode: 500))))

        let viewModel: PlayersAndTeamsViewModel = .init(repository: mockRepository)

        let expectation = self.expectation(description: "playersAndTeams")

        viewModel.$isNetworkAlertErrorShown
            .dropFirst()
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.searchText = "Beck"

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(viewModel.playersAndTeams, nil)
        XCTAssertEqual(viewModel.isNetworkAlertErrorShown, true)
    }

    func testPlayersAndTeamsViewModel_afterUserSwipedPlayerCell_shouldPersistUserToDisk_afterSwipeAgain_shouldRemovePlayerFromDisk() throws {
        let mockRepository: MockRepository = .init()
        let viewModel: PlayersAndTeamsViewModel = .init(repository: mockRepository)

        let player: Player = .previewObject()

        let expectation1 = expectation(description: "favourite-player")

        mockRepository.getAllFavouritePlayers()
            .dropFirst()
            .first()
            .sink { players in
                XCTAssertEqual(players, [player])
                expectation1.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.didSwipePlayerCell(player, isFavourite: false)

        wait(for: [expectation1], timeout: 3)

        let expectation2 = expectation(description: "unfavourite-player")

        mockRepository.getAllFavouritePlayers()
            .dropFirst()
            .first()
            .sink { players in
                XCTAssertEqual(players, [])
                expectation2.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.didSwipePlayerCell(player, isFavourite: true)

        wait(for: [expectation2], timeout: 3)
    }
}
