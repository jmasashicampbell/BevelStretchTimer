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

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($viewModel.routine.steps) { $step in
                            let number = (viewModel.routine.steps.firstIndex(where: { $0.id == step.id }) ?? 0) + 1
                            StepRowView(step: $step, number: number) {
                                viewModel.deleteStep(id: step.id)
                            }
                        }
                        
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
                            
                            // Preserves spacing to align with rows with delete button
                            Image(systemName: "xmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(.clear)
                        }
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                }

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
    var number: Int
    var onDelete: () -> Void

    @State private var showingPicker = false
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0

    var body: some View {
        HStack {
            HStack {
                Text("\(number).")
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .monospacedDigit()
                TextField("(e.g. Hip flexor)", text: $step.name)
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .padding(.vertical, 18)
                Spacer()
                
                Divider()
                Button {
                    selectedMinutes = step.duration / 60
                    selectedSeconds = step.duration % 60
                    showingPicker = true
                } label: {
                    Text(formattedDuration(step.duration))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(step.duration == 0 ? Color.gray : Color.black)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            )
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
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
