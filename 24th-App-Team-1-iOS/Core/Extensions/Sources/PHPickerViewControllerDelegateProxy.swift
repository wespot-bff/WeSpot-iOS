//
//  PHPickerViewControllerDelegateProxy.swift
//  Extensions
//
//  Created by 김도현 on 11/15/24.
//

import PhotosUI

import RxSwift
import RxCocoa

public final class PHPickerDelegateProxy: DelegateProxy<PHPickerViewController, PHPickerViewControllerDelegate>, DelegateProxyType, PHPickerViewControllerDelegate {
    
    private let didFinishPickingSubject = PublishSubject<[PHPickerResult]>()
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        didFinishPickingSubject.onNext(results)
    }
    
    public static func registerKnownImplementations() {
        self.register { (pickerViewController: PHPickerViewController) -> PHPickerDelegateProxy in
            PHPickerDelegateProxy(parentObject: pickerViewController, delegateProxy: self)
        }
    }
    
    public static func currentDelegate(for object: PHPickerViewController) -> PHPickerViewControllerDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: PHPickerViewControllerDelegate?, to object: PHPickerViewController) {
        object.delegate = delegate
    }
    
    public var didFinishPicking: Observable<[PHPickerResult]> {
        return didFinishPickingSubject.asObservable()
    }
}

extension PHPickerViewController: @retroactive HasDelegate {
    public typealias Delegate = PHPickerViewControllerDelegate
}

extension Reactive where Base: PHPickerViewController {
    
    public var delegate: PHPickerDelegateProxy {
        return PHPickerDelegateProxy.proxy(for: self.base)
    }
    
    public var didSelectImage: Observable<Data> {
         return delegate.didFinishPicking
             .flatMap { [weak base] results -> Observable<Data> in
                 guard let base = base else { return Observable.empty() }
                 
                 return Observable.create { observer in
                     base.dismiss(animated: true) {
                         if let firstResult = results.first {
                             firstResult.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                                 if let error = error {
                                     observer.onError(error)
                                 } else if let image = object as? UIImage, let imageData = image.jpegData(compressionQuality: 1.0) {
                                     observer.onNext(imageData)
                                     observer.onCompleted()
                                 }
                             }
                         } else {
                             observer.onCompleted()
                         }
                     }
                     return Disposables.create()
                 }
             }
     }
}
