//
//  BikesGridSectionView.swift
//  BikeIndex
//
//  Created by Jack on 3/2/25.
//

import SwiftData
import SwiftUI

struct BikesGridSectionView: View {
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
        /// Uh, oh.
        /// Swift tip: Avoid using dots in your UserDefaults keys. It will usually be fine, but you'll run into problems if you ever need to observe it using NSObject.addObserver.
        /// addObserver takes a keyPath, and this will trip up on a key like “myApp.myThing” because it will assume myThing is a nested property.
        /// There is a didChangeNotification on UserDefaults but only fires for changes that occur in the current process. If you need to observe for changes that occur out-of-process (in an app extension), you'll need to use NSObject.addObserver.
        /// Super niche, yeah. But something to keep in your back pocket.
        /// -- https://hachyderm.io/@mattcomi/114617046543758069
        _isExpanded = AppStorage(
            wrappedValue: true, "BikesGridSectionView.isExpanded.\(section)")
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
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 8)
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
                BikesGridSectionView(
                    path: $navigationPath,
                    section: status.displayName,
                    bikes: [])
            }
        }
    }
}
