//
//  PlayersAndTeamsList+TeamCell.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import SwiftUI

extension PlayersAndTeamsList {
    struct TeamCell: View {
        let viewModel: PlayersAndTeamsViewModel.TeamCellViewModel
        let configuration: Configuration

        init(team: Team, flagURL: URL? = nil, configuration: Configuration = .init()) {
            self.viewModel = .init(team: team, flagURL: flagURL)
            self.configuration = configuration
        }

        var body: some View {
            VStack(alignment: .leading, spacing: configuration.verticalSpacing) {
                name
                city
                stadium
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .safeAreaInset(edge: .trailing) {
                flag
            }
        }

        var name: some View {
            Text(viewModel.name)
                .font(configuration.nameFont)
        }

        var city: some View {
            teamInfo(
                title: "City",
                text: viewModel.city
            )
        }

        var stadium: some View {
            teamInfo(
                title: "Stadium",
                text: viewModel.stadium
            )
        }

        func teamInfo(title: String, text: String) -> some View {
            HStack {
                Text("\(title): ")
                    .foregroundColor(.gray)
                    .font(configuration.infoTitleFont)
                Text(text)
                    .font(configuration.infoTextFont)
            }
        }

        var flag: some View {
            AsyncImage(url: viewModel.flagURL) { phase in
                if let image = phase.image {
                    image
                } else if phase.error != nil {
                    Color.clear
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(width: configuration.flagSize, height: configuration.flagSize)
        }
    }
}

extension PlayersAndTeamsList.TeamCell {
    struct Configuration {
        var verticalSpacing: CGFloat = 12
        var flagSize: CGFloat = 24

        var nameFont: Font = .title2
        var infoTitleFont: Font = .subheadline
        var infoTextFont: Font = .headline
    }
}

struct TeamCell_Previews: PreviewProvider {
    static let team: Team = .previewObject()

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
        PlayersAndTeamsList.TeamCell(team: team)
    }
}
