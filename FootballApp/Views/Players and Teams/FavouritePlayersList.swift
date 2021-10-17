//
//  FavouritePlayersList.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import SwiftUI

struct FavouritePlayersList: View {
    @ObservedObject var viewModel: PlayersAndTeamsViewModel

    var body: some View {
        List(viewModel.favouritePlayers, rowContent: playerCell)
            .listStyle(.insetGrouped)
            .overlay { emptyListLabel }
            .animation(.easeInOut, value: viewModel.favouritePlayers)
    }

    func playerCell(_ player: Player) -> some View {
        PlayersAndTeamsList.PlayerCell(player: player, isFavourite: true) {
            viewModel.didSwipePlayerCell(player, isFavourite: true)
        }
        .padding(.vertical)
    }

    @ViewBuilder
    var emptyListLabel: some View {
        if viewModel.shouldShowEmptyFavouritePlayersListLabel {
            Text(viewModel.emptyFavouritesListLabel)
        }
    }
}

struct FavouritePlayersList_Previews: PreviewProvider {
    static let viewModel: PlayersAndTeamsViewModel = .init()

    static var previews: some View {
        Group {
            preview
            preview
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }

    static var preview: some View {
        FavouritePlayersList(viewModel: viewModel)
    }
}
