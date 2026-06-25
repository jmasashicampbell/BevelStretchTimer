//
//  DurationPickerView.swift
//  BevelStretchTimer
//

import SwiftUI
import UIKit

struct DurationPickerView: UIViewRepresentable {
    @Binding var minutes: Int
    @Binding var seconds: Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.selectRow(minutes, inComponent: 0, animated: false)
        uiView.selectRow(seconds, inComponent: 1, animated: false)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: DurationPickerView

        init(_ parent: DurationPickerView) { self.parent = parent }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 60 }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            component == 0 ? "\(row) min" : "\(row) sec"
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 { parent.minutes = row } else { parent.seconds = row }
        }
    }
}
