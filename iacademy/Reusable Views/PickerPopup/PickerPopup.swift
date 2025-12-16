//
//  PickerPopup.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import FittedSheets


class PickerPopup: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!

    var currentVC: UIViewController!
    var dataArray: [String] = []
    var selectedIndex = -1
    var pickerTitle: String?
    var sender: Any?

    var didPickValue: ((Int)->())?

    
    static func instance() -> PickerPopup{
        let vc = PickerPopup(nibName: "PickerPopup", bundle: nil)
        return vc
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneBtn.setTitle("تأكيد", for: .normal)
        titleLbl.text = pickerTitle
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        picker.delegate = self
        picker.dataSource = self
        picker.reloadAllComponents()
        if selectedIndex >= 0 {
            picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (dataArray.count > 0) {
            selectedIndex = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = dataArray[row]
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func show(vc: UIViewController, sender: Any?, array: [String], index: Int) {
        OperationQueue.main.addOperation {
            self.currentVC = vc
            self.currentVC.view.endEditing(true)
            self.presentPickerAsSheet(currentVC: self.currentVC)
            self.sender = sender
            self.dataArray = array
            self.selectedIndex = index
            if (self.dataArray.count > 0) {
                if self.selectedIndex < 0 || self.selectedIndex >= self.dataArray.count {
                    self.selectedIndex = 0
                }
            }
        }
    }
    
    private func presentPickerAsSheet(currentVC: UIViewController) {
        let vc = self
        let sheetVC = SheetViewController(controller: vc, sizes: [.fixed(500)])
        sheetVC.handleColor = .clear
        sheetVC.dismissOnBackgroundTap = true
        sheetVC.topCornersRadius = 20
        currentVC.present(sheetVC, animated: true)

    }
    
    @IBAction func confirmBtnTapped(_ sender: Any?) {
        self.didPickValue?(self.selectedIndex)
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    
}

