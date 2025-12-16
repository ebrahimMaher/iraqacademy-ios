//
//  PhoneCodesListVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class PhoneCodesListVC: UIViewController {
    
    
    @IBOutlet weak var itemsTV: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchView: UIView!
    
    private var countryList = CountryInfo.countries
    private var countryListSearch = CountryInfo.countries
    
    var didSelectCountry: ((CountryInfo) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.rowHeight = 50
        itemsTV.register(PhoneCodesListTVCell.nib, forCellReuseIdentifier: PhoneCodesListTVCell.identifier)
        
        searchTF.delegate = self
        searchTF.attributedPlaceholder = NSAttributedString(
            string: "ابحث بالاسم او رمز الهاتف",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        
    }
    
    private func searchCountry(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.countryListSearch = countryList
        } else {
            if query.containsNumber || query.contains("+") {
                self.countryListSearch = countryList.filter { $0.phoneCode.lowercased().contains(query.lowercased()) }
            } else {
                self.countryListSearch = countryList.filter { $0.arabicName.normalizedArabic.contains(query.normalizedArabic) }
            }
        }
        itemsTV.reloadData()
    }

    
    
    

}

extension PhoneCodesListVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryListSearch.isEmpty ? 1 : countryListSearch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhoneCodesListTVCell.identifier, for: indexPath) as! PhoneCodesListTVCell
        if countryListSearch.isEmpty {
            cell.configureCellForEmptyState()
        } else {
            cell.configureCell(countryListSearch[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !countryListSearch.isEmpty else { return }
        didSelectCountry?(countryListSearch[indexPath.row])
        self.dismiss(animated: true)
    }
    
}

extension PhoneCodesListVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.searchView.backgroundColor = .white
            self.searchView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.searchView.backgroundColor = .Gray_50
            self.searchView.layer.borderColor = UIColor.gray100.cgColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text,
           let textRange = Range(range, in: currentText) {
            
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)
            searchCountry(query: updatedText)
        }
        
        return true
    }
    
}


