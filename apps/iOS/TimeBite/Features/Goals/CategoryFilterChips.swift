import SwiftUI

struct CategoryFilterChips: View {
    @Binding var selectedFilter: CategoryType

    private let categories: [CategoryType] = [.all, .build, .growth, .health, .creative]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    TBPillButton(
                        title: category.title,
                        systemName: category.symbol,
                        isSelected: selectedFilter == category
                    ) {
                        selectedFilter = category
                    }
                }
            }
        }
    }
}

