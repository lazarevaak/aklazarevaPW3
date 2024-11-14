import UIKit

// MARK: - Расширение UIView для привязки к суперпредставлению
extension UIView {
    func pinToSuperview(edges: [NSLayoutConstraint.Attribute] = [.top, .bottom, .left, .right], constants: [NSLayoutConstraint.Attribute: CGFloat] = [:]) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        for edge in edges {
            let constant = constants[edge] ?? 0
            switch edge {
            case .top:
                topAnchor.constraint(equalTo: superview.topAnchor, constant: constant).isActive = true
            case .bottom:
                bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: constant).isActive = true
            case .left:
                leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: constant).isActive = true
            case .right:
                trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: constant).isActive = true
            case .centerX:
                centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: constant).isActive = true
            case .centerY:
                centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: constant).isActive = true
            default:
                break
            }
        }
    }
}

// MARK: - Основной контроллер: WishMakerViewController
final class WishMakerViewController: UIViewController {
    
    // MARK: - Константы
    private enum Constants {
        static let sliderMin: Double = 0
        static let sliderMaxRed: Double = 1
        static let sliderMaxRGB: Double = 255
        static let titleFontSize: CGFloat = 32
        static let descriptionFontSize: CGFloat = 16
        static let stackRadius: CGFloat = 20
        static let stackBottom: CGFloat = -40
        static let stackLeading: CGFloat = 20
        static let descriptionTopOffset: CGFloat = 20
        static let titleText = "WishMaker"
        static let descriptionText = "Make your wishes come true!"
        static let titleColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
        static let buttonText = "Добавить желание"
        static let buttonHeight: CGFloat = 50
        static let buttonBottom: CGFloat = -20
    }

    // MARK: - Свойства
    private let titleView = UILabel()
    private let descriptionView = UILabel()
    private let addWishButton: UIButton = UIButton(type: .system)
    
    private var redValue: CGFloat = 0
    private var greenValue: CGFloat = 0
    private var blueValue: CGFloat = 0
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Настройка UI
    private func configureUI() {
        view.backgroundColor = .systemPink
        configureTitle()
        configureDescription()
        configureAddWishButton()  
        configureSliders()
    }
    
    private func configureTitle() {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.text = Constants.titleText
        titleView.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        titleView.textColor = Constants.titleColor

        view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureDescription() {
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.text = Constants.descriptionText
        descriptionView.font = UIFont.systemFont(ofSize: Constants.descriptionFontSize)
        descriptionView.textColor = .white
        descriptionView.numberOfLines = 0
        descriptionView.textAlignment = .center

        view.addSubview(descriptionView)
        NSLayoutConstraint.activate([
            descriptionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Constants.descriptionTopOffset),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.stackLeading)
        ])
    }
    
    private func configureAddWishButton() {
        addWishButton.setTitle(Constants.buttonText, for: .normal)
        addWishButton.setTitleColor(.systemPink, for: .normal)
        addWishButton.backgroundColor = .white
        addWishButton.layer.cornerRadius = 10
        addWishButton.translatesAutoresizingMaskIntoConstraints = false

        addWishButton.addTarget(self, action: #selector(addWishButtonPressed), for: .touchUpInside)
        
        view.addSubview(addWishButton)
        
        NSLayoutConstraint.activate([
            addWishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addWishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.buttonBottom),
            addWishButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            addWishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.stackLeading),
            addWishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.stackLeading)
        ])
    }
    
    private func configureSliders() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layer.cornerRadius = Constants.stackRadius
        stack.clipsToBounds = true
        view.addSubview(stack)

        let sliderRed = CustomSlider(title: "Red", min: Constants.sliderMin, max: Constants.sliderMaxRed)
        let sliderBlue = CustomSlider(title: "Blue", min: Constants.sliderMin, max: Constants.sliderMaxRGB)
        let sliderGreen = CustomSlider(title: "Green", min: Constants.sliderMin, max: Constants.sliderMaxRGB)

        for slider in [sliderRed, sliderBlue, sliderGreen] {
            stack.addArrangedSubview(slider)
        }

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.stackLeading),
            stack.bottomAnchor.constraint(equalTo: addWishButton.topAnchor, constant: Constants.stackBottom)
        ])

        sliderRed.valueChanged = { [weak self] value in
            self?.redValue = CGFloat(value)
            self?.updateBackgroundColor()
        }
        
        sliderGreen.valueChanged = { [weak self] value in
            self?.greenValue = CGFloat(value) / 255.0
            self?.updateBackgroundColor()
        }
        
        sliderBlue.valueChanged = { [weak self] value in
            self?.blueValue = CGFloat(value) / 255.0
            self?.updateBackgroundColor()
        }
    }

    private func updateBackgroundColor() {
        view.backgroundColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    @objc private func addWishButtonPressed() {
        let wishStoringVC = WishStoringViewController()
        present(wishStoringVC, animated: true)
    }
}

// MARK: - Класс CustomSlider для настройки слайдеров
final class CustomSlider: UIView {
    var valueChanged: ((Double) -> Void)?
    private let slider = UISlider()
    private let titleView = UILabel()
    
    init(title: String, min: Double, max: Double) {
        super.init(frame: .zero)
        titleView.text = title
        slider.minimumValue = Float(min)
        slider.maximumValue = Float(max)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        for view in [slider, titleView] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            slider.centerXAnchor.constraint(equalTo: centerXAnchor),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func sliderValueChanged() {
        valueChanged?(Double(slider.value))
    }
}
