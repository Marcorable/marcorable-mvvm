
import SwiftUI

extension SearchScreen {

    struct Row: View {
        let model: Model

        var body: some View {
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

}

extension SearchScreen.Row {

    struct Model: Hashable {
        let name: String
        let imageUrl: URL?
    }

}
