//
//  PlayersAndTeamsList+PlayerCell.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import SwiftUI

extension PlayersAndTeamsList {
    struct PlayerCell: View {
        let viewModel: PlayersAndTeamsViewModel.PlayerCellViewModel
        let configuration: Configuration

        init(
            player: Player,
            isFavourite: Bool = false,
            configuration: Configuration = .init()
        ) {
            self.viewModel = .init(player: player, isFavourite: isFavourite)
            self.configuration = configuration
        }

        var body: some View {
            VStack(alignment: .leading, spacing: configuration.verticalSpacing) {
                playerName
                playerInfo
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .safeAreaInset(edge: .trailing) {
                favouriteIcon
            }
        }

        var playerName: some View {
            Text(viewModel.name)
                .font(configuration.nameFont)
        }

        var playerInfo: some View {
            HStack {
                playerInfoText(title: viewModel.ageTitle, text: viewModel.age)
                playerInfoText(title: viewModel.clubTitle, text: viewModel.club)
            }
        }

        func playerInfoText(title: String, text: String) -> some View {
            VStack(alignment: .leading, spacing: configuration.playerInfoVerticalSpacing) {
                Text(title)
                    .foregroundColor(.gray)
                    .font(configuration.infoTitleFont)
                Text(text)
                    .font(configuration.infoTextFont)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        var favouriteIcon: some View {
            Image(systemName: configuration.favouriteIconName)
                .font(configuration.favouriteIconFont)
                .foregroundColor(viewModel.isFavourite ? .yellow : .clear)
        }
    }
}

extension PlayersAndTeamsList.PlayerCell {
    struct Configuration {
        var verticalSpacing: CGFloat = 12
        var playerInfoVerticalSpacing: CGFloat = 4

        var nameFont: Font = .title2
        var infoTitleFont: Font = .subheadline
        var infoTextFont: Font = .headline
        var favouriteIconFont: Font = .title2

        var favouriteIconName: String = "star.fill"
    }
}

struct PlayerCell_Previews: PreviewProvider {
    static let player: Player = .previewObject()

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
        VStack {
            PlayersAndTeamsList.PlayerCell(player: player)
            Divider()
            PlayersAndTeamsList.PlayerCell(player: player, isFavourite: true)
        }
    }
}
