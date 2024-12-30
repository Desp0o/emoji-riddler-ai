import SwiftUI

struct SwiftUIListView: View {
  let item: GameModel
  @StateObject var vm: GameViewModel
  @State private var selectedAnswer: Answer? = nil
  @State private var isDisabled = false
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        ForEach(item.answers, id: \.self) { answer in
          Button {
            handleAnswerSelection(answer)
          } label: {
            Text(answer.answerTitle.capitalized)
              .foregroundStyle(selectedAnswer == answer ? .secondaryWhite : .mainGreen)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(selectedAnswer == answer ?
                          (answer.isCorrect ? .mainGreen : .red) : .secondaryWhite)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .padding(4)
              .background(selectedAnswer == answer ?
                          (answer.isCorrect ? .mainGreen : .red) : .mainGreen)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .animation(.easeInOut(duration: 0.3), value: selectedAnswer)
          }
        }
        .disabled(isDisabled)
      }
    }
    .scrollBounceBehavior(.basedOnSize)
    .background(.clear)
  }
  
  private func handleAnswerSelection(_ answer: Answer) {
    withAnimation(.easeInOut) {
      selectedAnswer = answer
      isDisabled = true
      
      if answer.isCorrect {
        vm.increasePoints()
      } else {
        vm.decreaseAttempts()
      }
    }
  }
}





