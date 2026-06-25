//
//  RoutineCreationView.swift
//  BevelStretchTimer
//

import SwiftUI

struct RoutineCreationView: View {
    @State private var viewModel = RoutineCreationViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            TextField("New stretch session", text: $viewModel.routine.name)
                .font(.title.bold())
                .padding(.horizontal)
                .padding(.vertical, 12)

            Divider()

            List($viewModel.routine.steps) { $step in
                StepRowView(step: $step)
            }
            .listStyle(.plain)

            Divider()

            Button("Start session") { }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}

struct StepRowView: View {
    @Binding var step: StretchStep

    var body: some View {
        HStack {
            TextField("(e.g. Hip flexor)", text: $step.name)
            Spacer()
            Text(formattedDuration(step.duration))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    RoutineCreationView()
}
