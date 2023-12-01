//
//  DefaultProductLocalRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RealmSwift
import RxSwift

final class DefaultProductLocalRepository: ProductLocalRepository {

    private var realm: Realm = try! Realm()
    private let realmTaskQueue: DispatchQueue
    
    init() {
        realmTaskQueue = DispatchQueue(label: "realm-serial-queue")
        do {
            try realmTaskQueue.sync {
                realm = try Realm(queue: realmTaskQueue)
            }
            if let fileURL = realm.configuration.fileURL {
                print("📁📁📁 \(String(describing: fileURL)) 📁📁📁")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveLikeProduct(product: Product) -> Single<Product> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            realmTaskQueue.async {
                let productTable = ProductTable(
                    productID: product.id,
                    title: product.title,
                    imageURL: product.imageURL,
                    mallName: product.mallName,
                    price: product.price,
                    isLike: true
                )
                do {
                    try self.realm.write {
                        self.realm.add(productTable)
                    }
                    single(.success(product))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: realmTaskQueue))
    }
    
    func deleteLikeProduct(productID: String) -> Single<String> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
                guard let object = self.realm.object(
                    ofType: ProductTable.self,
                    forPrimaryKey: productID
                ) else { return Disposables.create() }
                do {
                    try self.realm.write {
                        self.realm.delete(object)
                    }
                    single(.success(productID))
                } catch {
                    single(.failure(error))
                }
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: realmTaskQueue))
    }
    
    func fetchAllLikeProducts() -> Single<[Product]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let objects = self.realm
                .objects(ProductTable.self)
                .sorted(
                    byKeyPath: "enrolledDate",
                    ascending: false
                )
            single(.success(objects.map { $0.toDomain() }))
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: realmTaskQueue))
    }
    
    func fetchQueryLikeProducts(query: String) -> Single<[Product]> {
        return Single.create { single in
            let objets = self.realm
                .objects(ProductTable.self)
                .where { $0.title.contains(query) }
                .sorted(
                    byKeyPath: "enrolledDate",
                    ascending: false
                )
            single(.success(objets.map { $0.toDomain() }))
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: realmTaskQueue))
    }

    func isLikeProduct(productID: String) -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            if let _ = self.realm.object(
                ofType: ProductTable.self,
                forPrimaryKey: productID
            ) {
                single(.success(true))
            } else {
                single(.success(false))
            }
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: realmTaskQueue))
    }
}
