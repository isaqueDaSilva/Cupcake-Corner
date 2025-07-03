struct AsyncCoverImageView: View {
    private let imageName: String?
    private let logger = AppLogger(category: "AsyncCoverImageView")
    
    @State private var isLoading = false
    @State private var imageData: Data? = nil
    
    var body: some View {
        Group {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                Image(
                    by: self.imageData,
                    with: .smallSize,
                    defaultIcon: .exclamationmarkTriangleFill
                )
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
            }
        }
        .frame(
            maxWidth: CGSize.smallSize.width,
            maxHeight: CGSize.smallSize.height
        )
        .onAppear {
            self.dowloadImage()
        }
    }
    
    init(imageName: String?) {
        self.imageName = imageName
    }
}

extension AsyncCoverImageView {
    private func dowloadImage() {
        guard let imageData else { return }
        
        self.isLoading = true
        
        Task.detached(priority: .background) {
            do {
//                let token = try TokenGetter.getValue()
//                
//                let request = _Network(
//                    method: .get,
//                    scheme: .https,
//                    path: "/cupcake/image/\(self.imageName)",
//                    fields: [
//                        .authorization : token,
//                        .contentType : _Network.HeaderValue.json.rawValue
//                    ],
//                    requestType: .get
//                )
//                
//                let (data, response) = try await request.getResponse(with: .shared)
//                
//                guard response.status == .ok else {
//                    throw AppError.badResponse
//                }
                
                try await Task.sleep(for: .seconds(4))
                
                await MainActor.run {
                    self.imageData = UIImage(resource: .appLogo).pngData()
                }
            } catch {
                self.logger.error(
                    "Could not possible to download Image with error: \(error.localizedDescription)"
                )
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}