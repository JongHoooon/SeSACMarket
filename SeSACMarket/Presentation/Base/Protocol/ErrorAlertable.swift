//
//  ErrorAlertable.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/24.
//

import UIKit

protocol ErrorAlertable {
    func presnetErrorMessageAlert(error: Error)
}

extension ErrorAlertable where Self: CoordinatorProtocol {
    private func presentSimpleAlert(
        title: String? = nil,
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(
            title: "확인",
            style: .default,
            handler: { _ in
                handler?()
            }
        )
        alertController.addAction(alertAction)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.present(alertController, animated: true)
        }
    }
    
    func presnetErrorMessageAlert(error: Error) {
        if error is APIError {
            let error = error as! APIError
            presentSimpleAlert(message: error.errorMessage)
        } else {
            presentSimpleAlert(message: error.localizedDescription)
        }
    }
}

