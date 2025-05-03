//
//  BikesSection.swift
//  BikeIndex
//
//  Created by Jack on 3/2/25.
//

import SwiftData
import SwiftUI

struct BikesSection: View {
    @Binding var path: NavigationPath
    private(set) var section: SectionValue
    @Query private var bikes: [Bike]
    @AppStorage
    private var isExpanded: Bool

    init(path: Binding<NavigationPath>, section: SectionValue) {
        self._path = path
        self.section = section
        _bikes = Query(filter: section.filterPredicate)
        /// Track expanded state _for each section_
        _isExpanded = AppStorage(
            wrappedValue: true, "BikesSection.isExpanded.\(section.displayName)")
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
                    Text(section.displayName)
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
            .accessibilityIdentifier("Section toggle \(section.displayName)")
            .accessibilityHint(
                "\(isExpanded ? "Collapse" : "Expand") section for \(section.displayName)"
            )
            .buttonStyle(.plain)
            .padding([.top, .bottom], 2)
        }
    }
}

extension BikesSection {
    enum SectionValue {
        case byStatus(BikeStatus)
        case byManufacturer(String)

        var filterPredicate: Predicate<Bike> {
            switch self {
            case .byStatus(let status):
                return #Predicate<Bike> { model in
                    model.statusString == status.rawValue
                }
            case .byManufacturer(let manufacturer):
                return #Predicate<Bike> { model in
                    model.manufacturerName == manufacturer
                }
            }
        }

        var displayName: String {
            switch self {
            case .byStatus(let bikeStatus):
                bikeStatus.rawValue.capitalized
            case .byManufacturer(let manufacturer):
                manufacturer
            }
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
                    section: .byStatus(status))
            }
        }
    }
}
