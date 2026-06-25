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
            .navigationDestination(isPresented: $isSessionActive) {
                ActiveSessionView(routineName: viewModel.routine.name, steps: viewModel.routine.steps)
            }
        }
    }
    
    private func roundedMinutes(_ seconds: Int) -> String {
        let minutes = Int((Double(seconds) / 60).rounded())
        return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }
}

struct StepRowView: View {
    @Binding var step: StretchStep
    var onDelete: () -> Void

    @State private var showingPicker = false
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0

    var body: some View {
        HStack {
            TextField("(e.g. Hip flexor)", text: $step.name)
            Spacer()
            Button {
                selectedMinutes = step.duration / 60
                selectedSeconds = step.duration % 60
                showingPicker = true
            } label: {
                Text(formattedDuration(step.duration))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
        .sheet(isPresented: $showingPicker) {
            VStack(spacing: 0) {
                DurationPickerView(minutes: $selectedMinutes, seconds: $selectedSeconds)

                Button("Set") {
                    step.duration = selectedMinutes * 60 + selectedSeconds
                    showingPicker = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .presentationDetents([.height(280)])
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    RoutineCreationView()
}
