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
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                Divider()
                    .padding(.horizontal, 30)
                    .padding(.top, 15)

                stepsScrollView
                statusLabel
                startButton
            }
            .navigationDestination(isPresented: $isSessionActive) {
                ActiveSessionView(routineName: viewModel.routine.name, steps: viewModel.routine.steps)
            }
        }
    }

    private var stepsScrollView: some View {
        let vm = Bindable(viewModel)
        return ScrollView {
            VStack(spacing: 12) {
                ForEach(vm.routine.steps) { $step in
                    let number = (viewModel.routine.steps.firstIndex(where: { $0.id == step.id }) ?? 0) + 1
                    StepRowView(step: $step, number: number) {
                        viewModel.deleteStep(id: step.id)
                    }
                }
                addStepButton
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
        }
    }

    private var addStepButton: some View {
        HStack {
            Button {
                viewModel.addStep()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                    )
            }
            .buttonStyle(.plain)
            Image(systemName: "xmark")
                .fontWeight(.semibold)
                .foregroundStyle(.clear)
        }
    }

    private var statusLabel: some View {
        Group {
            if viewModel.didAttemptStart, let error = viewModel.validationError {
                Text(error)
                    .foregroundStyle(.red)
            } else {
                HStack(spacing: 0) {
                    Text("Estimated time: ")
                        .foregroundStyle(.secondary)
                    Text(roundedMinutes(viewModel.totalDuration))
                }
            }
        }
        .font(.subheadline)
        .padding(.top, 8)
    }

    private var startButton: some View {
        Button("Start session") {
            if viewModel.validationError == nil {
                isSessionActive = true
            } else {
                viewModel.didAttemptStart = true
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(viewModel.validationError == nil ? .black : .gray)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func roundedMinutes(_ seconds: Int) -> String {
        let minutes = Int((Double(seconds) / 60).rounded())
        return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }
}

#Preview {
    RoutineCreationView()
}
