//
//  BikesSection.swift
//  BikeIndex
//
//  Created by Jack on 3/2/25.
//

import SwiftData
import SwiftUI

#warning("TODO: Rename to BikesGridSectionView")
struct BikesSection: View {
    typealias GroupMode = MainContentPage.ViewModel.GroupMode

    @Binding var path: NavigationPath
    var section: String
    private var bikes: [Bike]
    @AppStorage
    private var isExpanded: Bool

    init(path: Binding<NavigationPath>, section: String, bikes: [Bike]) {
        self._path = path
        self.bikes = bikes
        self.section = section
        /// Track expanded state _for each section_
        _isExpanded = AppStorage(
            wrappedValue: true, "BikesSection.isExpanded.\(section)")
    }

    var body: some View {
        Section(isExpanded: $isExpanded) {
            ForEach(Array(bikes.enumerated()), id: \.element) { (index, bike) in
                ContentBikeButtonView(
                    path: $path,
                    bikeIdentifier: bike.identifier
                )
                .accessibilityIdentifier("Bike \(index + 1)")
                .accessibilityValue(bike.bikeDescription ?? bike.manufacturerName)
            }
            .padding()
        } header: {
            Button {
                withAnimation(Animation.smooth(duration: 1.0, extraBounce: 2.0)) {
                    isExpanded.toggle()
                }
            } label: {
                ZStack {
                    Text(section)
                        .padding([.top, .bottom], 4)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                            .padding(.trailing)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .background(.ultraThinMaterial)
            }
            .accessibilityValue("\(isExpanded ? "Expanded" : "Collapsed")")
            .accessibilityIdentifier("Section toggle \(section)")
            .accessibilityHint(
                "\(isExpanded ? "Collapse" : "Expand") section for \(section)"
            )
            .buttonStyle(.plain)
            .padding([.top, .bottom], 2)
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    @Previewable @State var status: BikeStatus = .withOwner
    NavigationStack {
        ScrollView {
            ProportionalLazyVGrid {
                BikesSection(
                    path: $navigationPath,
                    section: status.displayName,
                    bikes: [])
            }
        }
    }
}
