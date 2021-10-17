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
        .overlay {
            listOverlay
        }
        .searchable(
            text: $viewModel.searchText.animation(.easeInOut),
            prompt: viewModel.searchPlaceholder
        )
    }

    var playersList: some View {
        section(
            title: viewModel.playersSectionTitle,
            items: viewModel.players
        ) { player in
            let isFavourite = viewModel.isFavourite(player)
            PlayerCell(player: player, isFavourite: isFavourite)
                .id(player)
                .padding(.vertical)
                .swipeActions {
                    Button {
                        withAnimation {
                            viewModel.didSwipePlayerCell(player, isFavourite: isFavourite)
                        }
                    } label: {
                        Image(systemName: "star.fill")
                            .font(.title2)
                    }
                    .tint(isFavourite ? .red : .yellow)
                }
        } footer: {
            if viewModel.shouldShowMorePlayersButton {
                moreButton(
                    title: viewModel.morePlayersButtonTitle,
                    isLoading: viewModel.isMorePlayersButtonLoading,
                    action: viewModel.morePlayersButtonTapped
                )
            }
        }
    }

    var teamsList: some View {
        section(
            title: viewModel.teamsSectionTitle,
            items: viewModel.teams
        ) { team in
            TeamCell(team: team, flag: viewModel.flags[team.nationality])
                .id(team)
                .padding(.vertical)
        } footer: {
            if viewModel.shouldShowMoreTeamsButton {
                moreButton(
                    title: viewModel.moreTeamsButtonTitle,
                    isLoading: viewModel.isMoreTeamsButtonLoading,
                    action: viewModel.moreTeamsButtonTapped
                )
            }
        }
    }

    @ViewBuilder
    var listOverlay: some View {
        switch viewModel.listOverlay {
        case .fetchInProgress: spinner
        case .startSearching:  startSearchingLabel
        case .noResultsFound:  noResultsFound
        case .none:            EmptyView()
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
            } header: {
                Text(title)
            } footer: {
                footer()
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
