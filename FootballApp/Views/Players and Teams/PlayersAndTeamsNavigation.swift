//
//  PlayersAndTeamsNavigation.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import SwiftUI

struct PlayersAndTeamsNavigation: View {
    @StateObject private var viewModel: PlayersAndTeamsViewModel = .init()

    var body: some View {
        NavigationView {
            playersAndTeamsList
        }
        .navigationViewStyle(.stack)
    }

    var playersAndTeamsList: some View {
        PlayersAndTeamsList(viewModel: viewModel)
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                favouritePlayersListButton
            }
            .alert(viewModel.networkErrorTitle, isPresented: $viewModel.isNetworkAlertErrorShown) {
                Button("OK") { }
            }
            .sheet(isPresented: $viewModel.isFavouritePlayersListShown) {
                withAnimation {
                    viewModel.favouritePlayersListDismissed()
                }
            } content: {
                favouritePlayersList
            }
    }

    var favouritePlayersListButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(viewModel.favouritePlayersListButton) {
                withAnimation {
                    viewModel.favouritesButtonTapped()
                }
            }
        }
    }

    var favouritePlayersList: some View {
        NavigationView {
            FavouritePlayersList(viewModel: viewModel)
                .navigationTitle(viewModel.favouritePlayersListTitle)
        }
    }
}

struct PlayersAndTeamsNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PlayersAndTeamsNavigation()
    }
}
