
import SwiftUI

public struct AsyncImageLabelRow: View {
    let model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: 12) {
            AsyncImage(
                url: model.imageUrl,
                content: { image in
                    image.resizable()
                },
                placeholder: {
                    Color(.systemFill)
                }
            )
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            Text(model.name)
        }
    }
}


extension AsyncImageLabelRow {

    public struct Model: Hashable {
        public let name: String
        public let imageUrl: URL?

        public init(name: String, imageUrl: URL?) {
            self.name = name
            self.imageUrl = imageUrl
        }

    }

}
