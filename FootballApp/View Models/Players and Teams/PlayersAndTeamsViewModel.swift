//
//  PlayersAndTeamsViewModel.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation
import Combine

extension PlayersAndTeamsViewModel {
    /// for the sake of simplicity, the VM can only perform one network request at a single point in time
    enum NetworkState: Identifiable, Hashable {
        case fetchingPlayersAndTeams
        case fetchingPlayers
        case fetchingTeams

        var id: Self { self }
    }
}

extension PlayersAndTeamsViewModel {
    /// based on business logic, there can be multiple overlays that are shown over the list
    /// this enum provides a simple, yet powerful mapping of these states
    enum ListOverlay: Identifiable, Hashable {
        case spinner
        case startSearchingLabel
        case noResultsFound

        var id: Self { self }
    }
}

class PlayersAndTeamsViewModel: ObservableObject {
    @Published var playersAndTeams: PlayersAndTeams?

    /// computed properties that will map the optional arrays to either the arrays themselves or empty arrays in case these are nil
    var players: [Player] {
        playersAndTeams?.players ?? []
    }

    var teams: [Team] {
        playersAndTeams?.teams ?? []
    }

    /// for the sake of simplicity, allow only one network request at one point in time
    @Published var networkState: NetworkState?

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
            return .spinner
        }

        if searchText.isEmpty {
            return .startSearchingLabel
        }

        if players.isEmpty, teams.isEmpty {
            return .noResultsFound
        }

        return nil
    }

    /// though we store in the local database the full player objects, we only want to compare them based on ID
    /// even if the remote players will change something in their underlying data, which will make them out-of-sync with the players stored on disk, their identity will ALWAYS stay the same
    @Published private var favouritePlayersIDs: Set<Player.ID> = []

    /// this dictionary will hold the flag emoji for each country
    /// e.g "Scotland": "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
    @Published var flags: [String: String] = [:]

    /// here we manage whether the "More Players" buttons are shown for each section of the list
    @Published var shouldShowMorePlayersButton: Bool = false
    @Published var shouldShowMoreTeamsButton: Bool = false

    /// these variables are used for the favourite players list
    @Published var isFavouritePlayersListShown: Bool = false
    @Published var favouritePlayers: [Player] = []

    /// variable that manages the network error alert
    @Published var isNetworkAlertErrorShown: Bool = false

    /// these cancellables will let us manage our subscriptions.
    /// Prefer to use independent variables for managing subscriptions, instead of using Set<AnyCancellable>.
    /// this way, we have a granular control over the subscriptions
    private var searchTextCancellable: AnyCancellable?
    private var serviceCancellable: AnyCancellable?
    private var favouritesCancellable: AnyCancellable?
    private var flagsCancellable: AnyCancellable?

    /// the repository dependency. the VM will request the data from the repository layer
    /// the VM does not know nor care whether the data it requests from the repository comes from the remote server, from the local storage or from runtime
    private let repository: RepositoryProtocol

    /// inject the repository in the VM. this is especially useful for unit testing where we might want to mock the dependencies
    init(repository: RepositoryProtocol = Repository.shared) {
        self.repository = repository

        setUpSearchPublisher()
        setUpFavouritePlayersIDsPublisher()
        getFlags()
    }

    /// every time the user inputs text into the search field, this Combine pipeline will get triggered and perform the necessary actions
    private func setUpSearchPublisher() {
        searchTextCancellable = $searchText
            .dropFirst() // drop the empty string the variable is initialised with
            .debounce(for: Self.debounceRate, scheduler: DispatchQueue.main) // fetch the players and teams only if there have been at least 0.4 seconds between key presses
            .removeDuplicates() // do not repeat the request for the same searchText
            .sink { [weak self] text in
                self?.fetchPlayersAndTeams(text: text)
            }
    }

    /// this method will be called after each network request initiated by this VM
    /// in case an error is thrown by the network, we will display an alert to the user
    private func receivedNetworkCompletion(_ completion: Subscribers.Completion<RepositoryError>) {
        networkState = nil

        if case .failure(_) = completion {
            isNetworkAlertErrorShown = true
        }
    }

    func isFavourite(_ player: Player) -> Bool {
        favouritePlayersIDs.contains(player.id)
    }
}

// MARK: - Repository
/// all the repository related actions are written here
extension PlayersAndTeamsViewModel {
    private func fetchPlayersAndTeams(text: String) {
        /// if the search is empty (e.g the user pressed on "cancel" button)
        /// then we will remove all the players and/ or teams and show the empty list
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return playersAndTeams = nil
        }

        networkState = .fetchingPlayersAndTeams

        serviceCancellable = repository.getPlayersAndTeams(searchText: text)
            /// we don't know whether this pipeline will run on a separate thread in the repository
            /// so we make sure that the output is received on the main thread
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedNetworkCompletion(completion)
            } receiveValue: { [weak self] playersAndTeams in
                self?.received(playersAndTeams: playersAndTeams)
            }
    }

    private func received(playersAndTeams: PlayersAndTeams) {
        self.playersAndTeams = playersAndTeams

        /// hide the "More players" button if we know there won't be more patients to fetch
        /// this logic can be moved in the service layer and only pass a boolean down to the VM, through the repository (e.g `canFetchMorePlayers`)
        if playersAndTeams.players.isEmpty,
           playersAndTeams.players.count < 10 {
            shouldShowMorePlayersButton = false
        } else {
            shouldShowMorePlayersButton = true
        }

        if playersAndTeams.teams.isEmpty,
           playersAndTeams.teams.count < 10 {
            shouldShowMoreTeamsButton = false
        } else {
            shouldShowMoreTeamsButton = true
        }
    }

    private func fetchMorePlayers() {
        networkState = .fetchingPlayers

        serviceCancellable = repository.getPlayers(searchText: searchText, offset: players.count)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedNetworkCompletion(completion)
            } receiveValue: { [weak self] players in
                self?.receivedPlayers(players)
            }
    }

    private func receivedPlayers(_ players: [Player]) {
        self.playersAndTeams?.players.append(contentsOf: players)

        if players.count < 10 {
            shouldShowMorePlayersButton = false
        }
    }

    private func fetchMoreTeams() {
        networkState = .fetchingTeams

        serviceCancellable = repository.getTeams(searchText: searchText, offset: teams.count)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.receivedNetworkCompletion(completion)
            } receiveValue: { [weak self] teams in
                self?.receivedTeams(teams)
            }
    }

    private func receivedTeams(_ teams: [Team]) {
        self.playersAndTeams?.teams.append(contentsOf: teams)

        if teams.count < 10 {
            shouldShowMoreTeamsButton = false
        }
    }

    private func setUpFavouritePlayersIDsPublisher() {
        /// the purpose of this publisher is to retrieve the favourite players' IDs when they match the searchText
        /// these IDs will then be used to check which of the backend players have been marked as favourite by the user and display a "star" icon in the cells
        $searchText
            .debounce(for: Self.debounceRate, scheduler: DispatchQueue.main)
            .compactMap { [weak self] text in
                self?.repository.getFavouritePlayersIDs(lookup: text)
            }
            /// the previous operator return a publisher, so the `switchToLatest` operator ensures that we will drop the current subscription as soon as a new one is received
            .switchToLatest()
            .receive(on: RunLoop.main)
            .assign(to: &$favouritePlayersIDs)
    }

    private func getFavouritePlayers() {
        favouritesCancellable = repository.getAllFavouritePlayers()
            .sink { [weak self] players in
                self?.favouritePlayers = players
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

// MARK: - Favourite Players List
extension PlayersAndTeamsViewModel {
    var shouldShowEmptyFavouritePlayersListLabel: Bool {
        favouritePlayers.isEmpty
    }
}

// MARK: - UI Intents
extension PlayersAndTeamsViewModel {
    func morePlayersButtonTapped() {
        fetchMorePlayers()
    }

    func moreTeamsButtonTapped() {
        fetchMoreTeams()
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

    func favouritesButtonTapped() {
        isFavouritePlayersListShown = true

        getFavouritePlayers()
    }

    /// cancel the current subscription for favourite players
    func favouritePlayersListDismissed() {
        favouritesCancellable = nil
    }
}

extension PlayersAndTeamsViewModel {
    /// the time interval in which values will be dropped
    static private let debounceRate: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(400)
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

    var favouritePlayersListTitle: String {
        "Favourite Players"
    }

    var favouritePlayersListButton: String {
        "Favourites"
    }

    var emptyFavouritesListLabel: String {
        "No favourite players"
    }

    var networkErrorTitle: String {
        "Oops. The app has encountered an error processing your request.\nCheck your network connection and try again"
    }
}
