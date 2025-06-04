import SwiftUI

struct MemorizingGameView: View {
    @State private var currentImageToGuess: String = ""
    @State private var answerOptions: [String] = [] // Stores the actual image names for options
    @State private var revealedOptions: [String] = [] // What is currently displayed on the cards
    @State private var userChoice: String?
    @State private var isCorrect: Bool?
    @State private var showingFeedback: Bool = false
    @State private var gameImages: [String] = (2...25).map { String($0) } // Array of image names "2" to "25"
    @State private var buttonsDisabled: Bool = true // Control button interaction during memorization
    @State private var showingCountdown: Bool = false
    @State private var countdownValue: Int = 3
    @State private var showingStartGamePopup: Bool = true // Control visibility of "Start Game" popup

    var body: some View {
        ZStack {
            VStack {
                Text("Memorize the Image")
                    .font(.title)
                    .bold()

                Image(currentImageToGuess)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .padding(.bottom, 20)

                Text("Choose the Right Image")
                    .font(.title)
                    .bold()


                HStack {
                    ForEach(0..<answerOptions.count, id: \.self) { index in
                        Button {
                            if !buttonsDisabled && revealedOptions[index] == "1" {
                                userChoice = answerOptions[index] // Record the actual value
                                checkAnswer()
                                showingFeedback = true
                                revealedOptions[index] = answerOptions[index]
                                buttonsDisabled = true
                            }
                        } label: {
                            Image(revealedOptions[index]) // Show '1' or the revealed option
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 240)
                                .border(Color.gray)
                        }
                        .padding(.horizontal,4)
                        // Disable buttons during memorization phase or after a choice
                        .disabled(buttonsDisabled || revealedOptions[index] != "1")
                    }
                }

                Spacer()
            }
            .onAppear {
                // nextQuestion() // Don't start immediately, wait for "Start Game" button
            }
            .alert(isPresented: $showingFeedback) {
                Alert(
                    title: Text(isCorrect == true ? "Correct!" : "Wrong!"),
                    message: Text(isCorrect == true ? "You chose \(imageNameMap[userChoice ?? ""] ?? "unknown")." : "That's not \(imageNameMap[currentImageToGuess] ?? "unknown")."),
                    dismissButton: .default(Text("OK")) {
                        nextQuestion() // Proceed to next question after dismissing feedback
                    }
                )
            }

            // Custom Countdown Popup
            if showingCountdown {
                CountdownPopupView(countdownValue: countdownValue)
            }

            // Custom "Start Game" Popup
            if showingStartGamePopup {
                StartGamePopupView {
                    showingStartGamePopup = false
                    nextQuestion() // Start the game when button is tapped
                }
            }
        }
    }

    func nextQuestion() {
        guard !gameImages.isEmpty else {
            print("Game Over!")
            return
        }

        buttonsDisabled = true // Disable buttons at the start of a new question
        showingCountdown = true // Show the countdown immediately

        // 1. Select the image to guess
        currentImageToGuess = gameImages.randomElement() ?? "2"

        // 2. Create unique answer options
        answerOptions = createAnswerOptions(correctAnswer: currentImageToGuess)

        // 3. Initially show the actual answer options for memorization
        revealedOptions = answerOptions // THIS IS THE KEY CHANGE: Show actual options first!

        userChoice = nil
        isCorrect = nil
        showingFeedback = false

        // 4. Start the timer to count down and then flip cards to "1" after 3 seconds
        countdownValue = 3
        Task {
            // Countdown loop
            for i in (0...3).reversed() {
                await MainActor.run {
                    countdownValue = i
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            }
            // After countdown, hide popup and flip cards
            await MainActor.run {
                showingCountdown = false // Hide the countdown after 3 seconds
                withAnimation {
                    revealedOptions = Array(repeating: "1", count: answerOptions.count) // NOW flip to "1"
                    buttonsDisabled = false // Enable buttons after memorization
                }
            }
        }
    }

    func createAnswerOptions(correctAnswer: String) -> [String] {
        var options: [String] = [correctAnswer]
        var availableIncorrectImages = gameImages.filter { $0 != correctAnswer }

        while options.count < 2 && !availableIncorrectImages.isEmpty {
            if let randomIncorrect = availableIncorrectImages.randomElement() {
                options.append(randomIncorrect)
                availableIncorrectImages.removeAll { $0 == randomIncorrect }
            }
        }
        return options.shuffled()
    }

    func checkAnswer() {
        if userChoice == currentImageToGuess {
            isCorrect = true
        } else {
            isCorrect = false
        }
    }
}

struct CountdownPopupView: View {
    let countdownValue: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            Text("\(countdownValue)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct StartGamePopupView: View {
    let startGameAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            VStack {
                Text("Ready to Memorize?")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.bottom)
                Button("Start Game") {
                    startGameAction()
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    MemorizingGameView()
}
