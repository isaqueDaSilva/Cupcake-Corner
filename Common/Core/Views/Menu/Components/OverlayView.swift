extension MenuView {
    struct OverlayView: View {
        let isLoading: Bool
        let isCupcakeListEmpty: Bool
        
        var body: some View {
            Group {
                switch isLoading {
                case true:
                    ProgressView()
                case false:
                    if isCupcakeListEmpty {
                        EmptyStateView(
                            title: "No Cupcake Load",
                            description: "There are no cupcakes to be displayed.",
                            icon: .magnifyingglass
                        )
                    }
                }
            }
        }
    }
}