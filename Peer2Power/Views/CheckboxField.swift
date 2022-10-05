// Based on https://medium.com/@mahmudahsan/how-to-create-checkbox-in-swiftui-ad08e285ab3d

import SwiftUI

struct CheckboxField<Label: View>: View {
    @Binding var checked: Bool

    let label: Label
    let size: CGFloat
    let color: Color

    init(
        label: Label,
        size: CGFloat = 10,
        color: Color = .black,
        checked: Binding<Bool>
    ) {
        self.label = label
        self.size = size
        self.color = color
        _checked = checked
    }

    var body: some View {
        HStack(alignment: .center) {
            Button(
                action: {
                    self.checked.toggle()
                },
                label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(
                            systemName: checked
                            ? "checkmark.square"
                            : "square"
                        )
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(color)
                        .frame(width: size, height: size)
                    }
                }
            )
            
            label
        }
    }
}

struct CheckboxField_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxField(
            label: Text("This is Checkbox")
                .font(Font.system(size: 14)),
            size: 14,
            color: .black,
            checked: .constant(false)
        )
    }
}
