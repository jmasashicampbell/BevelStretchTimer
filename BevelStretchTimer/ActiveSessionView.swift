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
            ZStack {
                switch viewModel.phase {
                case .countdown(let count):
                    Text("\(count)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                case .step(_, let endDate):
                    stepDisplay {
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            Text(formattedTime(max(0, endDate.timeIntervalSince(context.date))))
                                .font(.system(size: 80, weight: .bold, design: .monospaced))
                                .monospacedDigit()
                        }
                    }
                case .paused(_, let remaining):
                    stepDisplay {
                        Text(formattedTime(remaining))
                            .font(.system(size: 80, weight: .bold, design: .monospaced))
                            .monospacedDigit()
                    }
                case .done:
                    VStack(spacing: 24) {
                        Text("Done!")
                            .font(.largeTitle.bold())
                        Button("End Session") {
                            viewModel.end()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.currentStep != nil {
                Button {
                    viewModel.togglePause()
                } label: {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .task { await viewModel.start() }
        .onDisappear { viewModel.end() }
    }

    @ViewBuilder
    private func stepDisplay<Timer: View>(@ViewBuilder timer: () -> Timer) -> some View {
        VStack(spacing: 16) {
            Text(viewModel.currentStep?.name ?? "")
                .font(.title2)
                .foregroundStyle(.secondary)
            timer()
        }
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
