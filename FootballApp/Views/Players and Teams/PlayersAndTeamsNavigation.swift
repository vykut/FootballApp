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
    }
}

struct PlayersAndTeamsNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PlayersAndTeamsNavigation()
    }
}
