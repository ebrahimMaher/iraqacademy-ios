//
//  HomeVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import CRRefresh

class HomeVC: UIViewController {

    @IBOutlet weak var headerWelcomeLabel: UILabel!
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var specialityView: UIView!
    @IBOutlet weak var specialityLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var joinCourseParentView: UIView!
    @IBOutlet weak var joinCourseView: UIView!
    @IBOutlet weak var courseCodeView: UIView!
    @IBOutlet weak var courseCodeTF: UITextField!
    @IBOutlet weak var joinCourseButton: UIButton!
    @IBOutlet weak var toolTipImageView: UIImageView!
    
    @IBOutlet weak var teachersStackView: UIStackView!
    @IBOutlet weak var teachersContentView: UIView!
    @IBOutlet weak var teachersCV: UICollectionView!
    
    @IBOutlet weak var bannersCVContentView: UIView!
    @IBOutlet weak var bannerCV: UICollectionView!
    
    @IBOutlet weak var bannerPageControlContentView: UIView!
    @IBOutlet weak var bannersPageControl: SnakePageControl!
    
    private let loadingView = LoadingView()
    private let viewModel = HomeViewModel()
    private var teachers = [HomeTeacherModel]()
    private var banners = [HomeBannerModel]()
    private var bannersTimer: Timer?
    private var bannerCurrentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        setupPullToRefresh()
        viewModel.fetchHomeData()
    }
    
    deinit {
        stopBannerTimer()
    }

    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveHomeData = { [weak self] homeModel in
            guard let self = self else { return }
            scrollView.cr.endHeaderRefresh()
            joinCourseParentView.isHidden = (homeModel.showJoin ?? false) ? false : true
            if let welcomeMessage = homeModel.welcomeMsg, !welcomeMessage.isEmpty {
                welcomeView.isHidden = false
                welcomeLabel.text = welcomeMessage
            } else {
                welcomeView.isHidden = true
                welcomeLabel.text = ""
            }
            if let teachers = homeModel.teachers, !teachers.isEmpty {
                self.teachers = teachers
                self.teachersCV.reloadData()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                    self.teachersContentView.isHidden = false
                    self.teachersStackView.layoutIfNeeded()
                }
            }
            
            if let banners = homeModel.banners, !banners.isEmpty {
                self.banners = banners
                self.bannersPageControl.numberOfPages = banners.count
                self.bannerCV.reloadData()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                    self.bannersCVContentView.isHidden = false
                    self.teachersStackView.layoutIfNeeded()
                }
                
                if banners.count > 1 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                        self.bannerPageControlContentView.isHidden = false
                        self.teachersStackView.layoutIfNeeded()
                    }
                }
            }

        }
        
        viewModel.didPurchaseCourseSuccessfully = { [weak self] purchasedCourse in
            guard let self = self else { return }
            if let purchasedCourseName = purchasedCourse.name {
                showSimpleAlert(title: "تهانينا!", message: "تم شراء دورة (\(purchasedCourseName)) بنجاح")
            }
        }
    }

    private func setupUI() {
        loadingView.setup(in: view)
        
        courseCodeTF.delegate = self
        courseCodeTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل رمز التسجيل هنا",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        
        joinCourseButton.backgroundColor = .Gray_100
        joinCourseButton.setTitleColor(.Gray_300, for: .normal)
        joinCourseButton.isUserInteractionEnabled = false

        
        let user = CacheClient.shared.userModel
        if let fullName = user?.name, let firstName = fullName.split(separator: " ").first {
            headerWelcomeLabel.text = "مرحباً بك,  \(firstName) 👋"
        }
        
        if let speciality = user?.speciality?.name {
            specialityView.isHidden = false
            specialityLabel.text = speciality
        } else {
            specialityView.isHidden = true
            specialityLabel.text = ""
        }
        
        teachersCV.delegate = self
        teachersCV.dataSource = self
        teachersCV.register(HomeTeachersCVCell.nib, forCellWithReuseIdentifier: HomeTeachersCVCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 80, height: 95)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        teachersCV.setCollectionViewLayout(layout, animated: true)
        teachersCV.semanticContentAttribute = .forceRightToLeft
        
        teachersContentView.isHidden = true
        welcomeView.isHidden = true
        welcomeLabel.text = ""
        joinCourseParentView.isHidden = true
        bannersCVContentView.isHidden = true
        bannerPageControlContentView.isHidden = true
        
        bannerCV.delegate = self
        bannerCV.dataSource = self
        bannerCV.isPagingEnabled = true
        bannerCV.register(HomeBannerCVCell.nib, forCellWithReuseIdentifier: HomeBannerCVCell.identifier)
        let bannerLayout = UICollectionViewFlowLayout()
        bannerLayout.itemSize = .init(width: UIScreen.main.bounds.width, height: 180)
        bannerLayout.scrollDirection = .horizontal
        bannerLayout.minimumLineSpacing = 0
        bannerLayout.minimumInteritemSpacing = 0
        bannerLayout.sectionInset = .zero
        bannerCV.setCollectionViewLayout(bannerLayout, animated: true)
        
        startBannerTimer()
        
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        showToolTipOverlay()
    }
    
    private func startBannerTimer() {
        bannersTimer?.invalidate()
        bannersTimer = Timer.scheduledTimer(timeInterval: 6.0,
                                            target: self,
                                            selector: #selector(moveToNextBanner),
                                            userInfo: nil,
                                            repeats: true)
    }
    
    private func stopBannerTimer() {
        bannersTimer?.invalidate()
        bannersTimer = nil
    }
    
    private func setupPullToRefresh() {
        scrollView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            guard let self = self else { return }
            viewModel.fetchHomeData()
        }
    }
    
    @objc private func moveToNextBanner() {
        guard !banners.isEmpty else { return }
        bannerCurrentIndex += 1
        if bannerCurrentIndex >= banners.count {
            bannerCurrentIndex = 0
        }
        let indexPath = IndexPath(item: bannerCurrentIndex, section: 0)
        bannerCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func showToolTipOverlay() {
        guard !CacheClient.shared.homeToolTipShownBefore else { return }
        guard let tabBarController = tabBarController else { return }
        guard !tabBarController.view.subviews.contains(where: { $0.tag == 999 }) else { return }
        let overlay = UIView(frame: tabBarController.view.bounds)
        overlay.backgroundColor = .black.withAlphaComponent(0.6)
        overlay.tag = 999
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTipOverlayTapped)))
        
        let holeFrame = joinCourseView.superview?.convert(joinCourseView.frame, to: tabBarController.view) ?? .zero
        let path = UIBezierPath(rect: overlay.bounds)
        let holePath = UIBezierPath(roundedRect: holeFrame, cornerRadius: 12)
        path.append(holePath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        overlay.layer.mask = maskLayer
        
        tabBarController.view.addSubview(overlay)
        toolTipImageView.isHidden = false
        CacheClient.shared.homeToolTipShownBefore = true
    }
    
    @objc func toolTipOverlayTapped() {
        tabBarController?.view.viewWithTag(999)?.removeFromSuperview()
        courseCodeTF.becomeFirstResponder()
        toolTipImageView.isHidden = true
    }
    
    @IBAction func joinCourseTapped(_ sender: UIButton) {
        let courseCode = courseCodeTF.text ?? ""
        viewModel.purchaseCode(code: courseCode)
    }
    
    @IBAction func chatWithUsTapped(_ sender: UIButton) {
        if let telegramURL = CacheClient.shared.appInfo?.telegramURL,
           let url = URL(string: telegramURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.courseCodeView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            self.courseCodeView.backgroundColor = .white
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.courseCodeView.layer.borderColor = UIColor.Gray_100.cgColor
            self.courseCodeView.backgroundColor = .Gray_25
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text,
           let textRange = Range(range, in: currentText) {
            
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)
            let isEmpty = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "").isEmpty
            UIView.animate(withDuration: 0.2) {
                self.joinCourseButton.backgroundColor = isEmpty ? .Gray_100 : .Blue_Brand_500
                self.joinCourseButton.setTitleColor(isEmpty ? .Gray_300 : .white, for: .normal)
                self.joinCourseButton.isUserInteractionEnabled = isEmpty ? false : true
            }
        }
        
        return true
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == teachersCV ? teachers.count : banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == teachersCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTeachersCVCell.identifier, for: indexPath) as! HomeTeachersCVCell
            cell.configure(teachers[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCVCell.identifier, for: indexPath) as! HomeBannerCVCell
            cell.configure(banners[indexPath.row])
            return cell

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == teachersCV{
            let teacher = teachers[indexPath.row]
            AppCoordinator.shared.navigate(to: .teacherCourses(teacherID: teacher.id, teacherName: teacher.name))
        } else {
            guard let url = URL(string: banners[indexPath.row].link ?? "") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.bannerCV {
            let offset = scrollView.contentOffset.x/UIScreen.main.bounds.width
            bannersPageControl.currentPage = offset
            bannerCurrentIndex = Int(offset)
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == bannerCV else { return }
        stopBannerTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == bannerCV else { return }
        startBannerTimer()
    }

}
