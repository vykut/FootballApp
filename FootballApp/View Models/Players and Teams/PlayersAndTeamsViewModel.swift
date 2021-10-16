//
//  PlayersAndTeamsViewModel.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation
import Combine

extension PlayersAndTeamsViewModel {
    enum NetworkState: Identifiable, Hashable {
        case fetchingPlayersAndTeams
        case fetchingPlayers
        case fetchingTeams

        var id: Self { self }
    }
}

extension PlayersAndTeamsViewModel {
    enum ListOverlay: Identifiable, Hashable {
        case fetchInProgress
        case startSearching
        case noResultsFound

        var id: Self { self }
    }
}

class PlayersAndTeamsViewModel: ObservableObject {
    @Published var playersAndTeams: PlayersAndTeams?

    var players: [Player] {
        playersAndTeams?.players ?? []
    }

    var teams: [Team] {
        playersAndTeams?.teams ?? []
    }

    @Published var networkState: NetworkState?
    @Published private var favouritePlayers: Set<Player.ID> = []

    var isSearchInProgress: Bool {
        networkState == .fetchingPlayersAndTeams
    }

    var isMorePlayersButtonLoading: Bool {
        networkState == .fetchingPlayers
    }

    var isMoreTeamsButtonLoading: Bool {
        networkState == .fetchingTeams
    }

    @Published var searchText: String = ""

    var listOverlay: ListOverlay? {
        if networkState == .fetchingPlayersAndTeams {
            return .fetchInProgress
        }

        if searchText.isEmpty {
            return .startSearching
        }

        if playersAndTeams?.isEmpty == true {
            return .noResultsFound
        }

        return nil
    }

    @Published var flags: [String: URL] = [:]

    private var searchTextCancellable: AnyCancellable?
    private var serviceCancellable: AnyCancellable?
    private var favouritesCancellable: AnyCancellable?
    private var flagsCancellable: AnyCancellable?

    private let repository: RepositoryProtocol

    init(repository: RepositoryProtocol = Repository.shared) {
        self.repository = repository

        setUpSearchPublisher()
        setUpFavouritePlayersPublisher()
        getFlags()
    }

    private func setUpSearchPublisher() {
        searchTextCancellable = $searchText
            .dropFirst() // drop the empty string the variable is initialised with
            .debounce(for: 0.7, scheduler: RunLoop.main) // fetch the players and teams only if there have been at least 0.7 seconds between key presses
            .removeDuplicates() // do not repeat the request for the same searchText
            .sink { [weak self] text in
                self?.fetchPlayersAndTeams(text: text)
            }
    }

    private func receivedCompletion(_ completion: Subscribers.Completion<RepositoryError>) {
        networkState = nil
    }

    func isFavourite(_ player: Player) -> Bool {
        favouritePlayers.contains(player.id)
    }
}

// MARK: - Repository
extension PlayersAndTeamsViewModel {
    private func fetchPlayersAndTeams(text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return playersAndTeams = nil
        }

        networkState = .fetchingPlayersAndTeams

        serviceCancellable = repository.getPlayersAndTeams(searchText: text)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedCompletion(completion)
            } receiveValue: { [weak self] playersAndTeams in
                self?.received(playersAndTeams: playersAndTeams)
            }
    }

    private func received(playersAndTeams: PlayersAndTeams) {
        self.playersAndTeams = playersAndTeams
    }

    private func fetchPlayers() {
        networkState = .fetchingPlayers

        serviceCancellable = repository.getPlayers(searchText: searchText, offset: players.count)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedCompletion(completion)
            } receiveValue: { [weak self] players in
                self?.receivedPlayers(players)
            }
    }

    private func receivedPlayers(_ players: [Player]) {
        self.playersAndTeams?.players.append(contentsOf: players)
    }

    private func fetchTeams() {
        networkState = .fetchingTeams

        serviceCancellable = repository.getTeams(searchText: searchText, offset: teams.count)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedCompletion(completion)
            } receiveValue: { [weak self] teams in
                self?.receivedTeams(teams)
            }
    }

    private func receivedTeams(_ teams: [Team]) {
        self.playersAndTeams?.teams.append(contentsOf: teams)
    }

    private func setUpFavouritePlayersPublisher() {
        favouritesCancellable = repository.getFavouritePlayersIDs()
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { [weak self] ids in
                self?.favouritePlayers = ids
            }
    }

    private func getFlags() {
        flagsCancellable = repository.getFlags()
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { [weak self] flags in
                self?.flags = flags
            }
    }
}

// MARK: - UI Intents
extension PlayersAndTeamsViewModel {
    func morePlayersButtonTapped() {
        fetchPlayers()
    }

    func moreTeamsButtonTapped() {
        fetchTeams()
    }

    func didRefreshList() {
        fetchPlayersAndTeams(text: searchText)
    }

    func didSwipePlayerCell(_ player: Player, isFavourite: Bool) {
        if isFavourite {
            repository.removePlayerFromFavourites(player)
        } else {
            repository.addPlayerToFavourites(player)
        }
    }
}

// MARK: - Static Strings
/// in this extension we hold all the static strings that the View will render.
/// Localisation should also take place here
extension PlayersAndTeamsViewModel {
    var navigationTitle: String {
        "Players and Teams"
    }

    var searchPlaceholder: String {
        "Search for players and teams"
    }

    var playersSectionTitle: String {
        "Players"
    }

    var teamsSectionTitle: String {
        "Teams"
    }

    var noResultsFoundLabel: String {
        "No results found"
    }

    var morePlayersButtonTitle: String {
        "More Players"
    }

    var moreTeamsButtonTitle: String {
        "More Teams"
    }

    var startSearchingLabel: String {
        "Start searching for Players and Teams"
    }
}
