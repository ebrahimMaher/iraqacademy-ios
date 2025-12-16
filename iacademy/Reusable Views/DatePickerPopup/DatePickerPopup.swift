//
//  DatePickerPopup.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit
import FittedSheets

class DatePickerPopup: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!

    var currentVC: UIViewController!
    var currentDate : Date?
    var datePickerMode = UIDatePicker.Mode.date
    var dateCalendarType: Calendar.Identifier = .gregorian
    var minimumDate: Date?
    var maximumDate: Date?
    var pickerTitle: String?
    var sender: Any?
    var didPickDate: ((Date)->())?

    
    static func instance() -> DatePickerPopup{
        let vc = DatePickerPopup(nibName: "DatePickerPopup", bundle: nil)
        return vc
    }

    deinit {
        print("Date Picker deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneBtn.setTitle("تأكيد", for: .normal)
        titleLbl.text = pickerTitle
        datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        datePicker.locale = Locale(identifier: "ar_EG")
        datePicker.datePickerMode = datePickerMode
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone.current
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    func show(vc: UIViewController, sender: Any?, mode: UIDatePicker.Mode, minimum: Date?, maximum: Date? , currentDate: Date? = nil) {
        OperationQueue.main.addOperation {
            self.currentVC = vc
            self.currentVC.view.endEditing(true)
            self.presentDatePickerAsSheet(currentVC: self.currentVC)
            self.sender = sender
            self.datePickerMode = mode
            self.minimumDate = minimum
            self.maximumDate = maximum
            self.datePicker.calendar = .init(identifier: self.dateCalendarType)
            self.datePicker.date = currentDate ?? Date()
        }
    }
    
    private func presentDatePickerAsSheet(currentVC: UIViewController) {
        let vc = self
        let sheetVC = SheetViewController(controller: vc, sizes: [.fixed(500)])
        sheetVC.handleColor = .clear
        sheetVC.dismissOnBackgroundTap = true
        sheetVC.topCornersRadius = 20
        currentVC.present(sheetVC, animated: true)

    }

    @IBAction func confirmBtnTapped(_ sender: Any?) {
        self.didPickDate?(self.datePicker.date)
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    
}


