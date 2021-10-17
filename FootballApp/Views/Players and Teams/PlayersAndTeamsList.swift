//
//  PlayersAndTeamsList.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import SwiftUI

struct PlayersAndTeamsList: View {
    @ObservedObject var viewModel: PlayersAndTeamsViewModel

    var body: some View {
        List {
            if !viewModel.isSearchInProgress {
                playersList
                teamsList
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut, value: viewModel.networkState)
        .refreshable {
            withAnimation {
                viewModel.didRefreshList()
            }
        }
        .disabled(viewModel.isSearchInProgress)
        .overlay { listOverlay }
        .searchable(
            text: $viewModel.searchText.animation(.easeInOut),
            prompt: viewModel.searchPlaceholder
        )
        .lineLimit(1)
    }

    var playersList: some View {
        section(
            title: viewModel.playersSectionTitle,
            items: viewModel.players,
            cell: playerCell
        ) {
            if viewModel.shouldShowMorePlayersButton {
                moreButton(
                    title: viewModel.morePlayersButtonTitle,
                    isLoading: viewModel.isMorePlayersButtonLoading,
                    action: viewModel.morePlayersButtonTapped
                )
            }
        }
    }

    @ViewBuilder
    func playerCell(_ player: Player) -> some View {
        let isFavourite = viewModel.isFavourite(player)
        PlayerCell(player: player, isFavourite: isFavourite) {
            viewModel.didSwipePlayerCell(player, isFavourite: isFavourite)
        }
        .id(player)
        .padding(.vertical)
    }

    var teamsList: some View {
        section(
            title: viewModel.teamsSectionTitle,
            items: viewModel.teams,
            cell: teamCell
        ) {
            if viewModel.shouldShowMoreTeamsButton {
                moreButton(
                    title: viewModel.moreTeamsButtonTitle,
                    isLoading: viewModel.isMoreTeamsButtonLoading,
                    action: viewModel.moreTeamsButtonTapped
                )
            }
        }
    }

    func teamCell(_ team: Team) -> some View {
        TeamCell(team: team, flag: viewModel.flags[team.nationality])
            .id(team)
            .padding(.vertical)
    }

    @ViewBuilder
    var listOverlay: some View {
        switch viewModel.listOverlay {
        case .spinner: spinner
        case .startSearchingLabel: startSearchingLabel
        case .noResultsFound:      noResultsFound
        case .none:                EmptyView()
        }
    }

    var startSearchingLabel: some View {
        Text(viewModel.startSearchingLabel)
            .transition(.opacity.animation(.easeInOut))
    }

    var noResultsFound: some View {
        Text(viewModel.noResultsFoundLabel)
            .transition(.opacity.animation(.easeInOut))
    }

    @ViewBuilder
    func section<
        Item: Identifiable,
        Cell: View,
        Footer: View
    >(
        title: String,
        items: [Item],
        @ViewBuilder cell: @escaping (Item) -> Cell,
        @ViewBuilder footer: @escaping () -> Footer
    ) -> some View {
        if !items.isEmpty {
            Section {
                ForEach(items, content: cell)
                footer()
            } header: {
                Text(title)
            }
        }
    }

    func moreButton(
        title: String,
        isLoading: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if isLoading {
                spinner
            } else {
                Text(title)
            }
        }
        .frame(maxWidth: .infinity)
        .disabled(isLoading)
    }

    var spinner: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .transition(.opacity.animation(.easeInOut))
    }
}

struct PlayersAndTeamsList_Previews: PreviewProvider {
    static let viewModel: PlayersAndTeamsViewModel = .init()

    static var previews: some View {
        PlayersAndTeamsList(viewModel: viewModel)
    }
}
