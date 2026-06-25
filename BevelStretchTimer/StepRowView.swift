//
//  StepRowView.swift
//  BevelStretchTimer
//

import SwiftUI

struct StepRowView: View {
    @Binding var step: StretchStep
    var number: Int
    var onDelete: () -> Void

    @State private var showingPicker = false
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0

    var body: some View {
        HStack {
            stepCard
            deleteButton
        }
        .sheet(isPresented: $showingPicker) {
            durationPicker
        }
    }

    private var stepCard: some View {
        HStack {
            Text("\(number).")
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .monospacedDigit()
            TextField("(e.g. Hip flexor)", text: $step.name)
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .padding(.vertical, 18)
            Spacer()
            Divider()
            durationButton
        }
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        )
    }

    private var durationButton: some View {
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

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark")
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
        }
        .buttonStyle(.borderless)
    }

    private var durationPicker: some View {
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

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
