//
//  ActiveSessionView.swift
//  BevelStretchTimer
//

import SwiftUI

struct ActiveSessionView: View {
    @State private var viewModel: ActiveSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(steps: [StretchStep]) {
        _viewModel = State(wrappedValue: ActiveSessionViewModel(steps: steps))
    }

    var body: some View {
        VStack {
            if case .countdown(let count) = viewModel.phase {
                countdownView(count: count)
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
        .task { await viewModel.start() }
        .onDisappear { viewModel.end() }
    }
    
    private func countdownView(count: Int) -> some View {
        Text("\(count)")
            .font(.system(size: 120, weight: .bold, design: .rounded))
    }
    
    private var centerStack: some View {
        VStack {
            switch viewModel.phase {
                
            case .step(_, let endDate):
                stepText
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let remaining = max(0, endDate.timeIntervalSince(context.date))
                    timerView(remaining: remaining)
                }
                resetButton
                
            case .paused(_, let remaining):
                stepText
                timerView(remaining: remaining)
                resetButton
                
            case .done:
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
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
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

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let s = Int(ceil(seconds))
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

#Preview {
    ActiveSessionView(steps: [
        StretchStep(name: "Hip flexor", duration: 15),
        StretchStep(name: "Hamstring", duration: 15),
    ])
}
