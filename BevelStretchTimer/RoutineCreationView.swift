//
//  RoutineCreationView.swift
//  BevelStretchTimer
//

import SwiftUI

struct RoutineCreationView: View {
    @State private var viewModel = RoutineCreationViewModel()
    @State private var isSessionActive = false

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                TextField("New stretch session", text: $viewModel.routine.name)
                    .font(.title.bold())
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                Divider()

                List {
                    ForEach($viewModel.routine.steps) { $step in
                        StepRowView(step: $step) {
                            viewModel.deleteStep(id: step.id)
                        }
                    }
                    Button {
                        viewModel.addStep()
                    } label: {
                        Label("Add step", systemImage: "plus")
                    }
                }
                .listStyle(.plain)

                Divider()

                Button("Start session") {
                    isSessionActive = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationDestination(isPresented: $isSessionActive) {
                ActiveSessionView(routineName: viewModel.routine.name, steps: viewModel.routine.steps)
            }
        }
    }
}

struct StepRowView: View {
    @Binding var step: StretchStep
    var onDelete: () -> Void

    var body: some View {
        HStack {
            TextField("(e.g. Hip flexor)", text: $step.name)
            Spacer()
            Text(formattedDuration(step.duration))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    RoutineCreationView()
}
