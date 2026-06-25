//
//  ActiveSessionView.swift
//  BevelStretchTimer
//

import SwiftUI



struct ActiveSessionView: View {
    @State private var viewModel: ActiveSessionViewModel
    @Environment(\.dismiss) private var dismiss
    let routineName: String
    
    private let blackGradient = LinearGradient(gradient: Gradient(colors: [Color(white: 0.306), .black]),
                                               startPoint: .top,
                                               endPoint: .bottom)
    

    init(routineName: String, steps: [StretchStep]) {
        self.routineName = routineName
        _viewModel = State(wrappedValue: ActiveSessionViewModel(steps: steps))
    }

    var body: some View {
        VStack {
            if case .countdown(let endDate) = viewModel.phase {
                countdownView(endDate: endDate)
            } else {
                Spacer()
                centerStack
                Spacer()
                if viewModel.currentStep != nil {
                    upNextLabel
                    playbackControls
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                titleView
            }
        }
        .task { await viewModel.start() }
        .onDisappear { viewModel.end() }
    }
    
    private func countdownView(endDate: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let count = max(1, Int(ceil(endDate.timeIntervalSince(context.date))))
            Rectangle()
                .frame(width: 80, height: 80)
                .foregroundStyle(blackGradient)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.3), radius: 14, y: 3)
                .overlay {
                    Text("\(count)")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white)
                }
        }
    }
    
    private var centerStack: some View {
        VStack {
            switch viewModel.phase {
                
            case .step(_, let endDate, _):
                stepText
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let remaining = max(0, endDate.timeIntervalSince(context.date))
                    timerView(remaining: remaining)
                }
                resetButton

            case .paused(_, let remaining, _):
                stepText
                timerView(remaining: remaining)
                resetButton

            case .done(_):
                Button("End Session") {
                    viewModel.end()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            default:
                EmptyView()
            }
        }
    }
    
    private var stepText: some View {
        Text(viewModel.currentStep?.name ?? "")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
    
    private func timerView(remaining: TimeInterval) -> some View {
        Text(formattedTime(remaining))
            .font(.system(size: 80, weight: .bold, design: .monospaced))
            .monospacedDigit()
    }
    
    private var resetButton: some View {
        Button("Reset") {
            viewModel.resetStep()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    private var upNextLabel: some View {
        HStack(spacing: 0) {
            Text("Up next: ")
                .foregroundStyle(.secondary)
            Text(viewModel.nextStep?.name ?? "Done")
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 24) {
            Button {
                viewModel.skipBackward()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSkipBackward)

            Button {
                viewModel.togglePause()
            } label: {
                let imageName = if case .paused = viewModel.phase { "play.fill" } else { "pause.fill" }
                Image(systemName: imageName)
                    .font(.title)
            }
            .buttonStyle(.borderedProminent)

            Button {
                viewModel.skipForward()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSkipForward)
        }
        .padding()
    }
    
    @ViewBuilder
    private var titleView: some View {
        switch viewModel.phase {
        case .countdown(_):
            EmptyView()
        default:
            VStack(spacing: 0) {
                Text(routineName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                totalTimerView
            }
        }
    }

    @ViewBuilder
    private var totalTimerView: some View {
        switch viewModel.phase {
        case .step(_, _, let sessionStartDate), .done(let sessionStartDate):
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(formattedTotalTime(context.date.timeIntervalSince(sessionStartDate)))
                    .font(.system(.body, design: .monospaced).weight(.semibold))
                    .monospacedDigit()
            }
        case .paused(_, _, let totalElapsed):
            Text(formattedTotalTime(totalElapsed))
                .font(.system(.title3, design: .monospaced).weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        default:
            EmptyView()
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let secondsInt = Int(ceil(seconds))
        let hours = secondsInt / 3600
        let minutes = (secondsInt % 3600) / 60
        let remainderSeconds = secondsInt % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainderSeconds)
    }

    private func formattedTotalTime(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        if s >= 3600 {
            return String(format: "%02d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
        } else {
            return String(format: "%02d:%02d", s / 60, s % 60)
        }
    }
}

#Preview {
    ActiveSessionView(routineName: "Morning Routine", steps: [
        StretchStep(name: "Hip flexor", duration: 15),
        StretchStep(name: "Hamstring", duration: 15),
    ])
}
