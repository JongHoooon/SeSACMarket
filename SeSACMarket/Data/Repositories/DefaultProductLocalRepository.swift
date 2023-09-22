//
//  DefaultProductLocalRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RealmSwift

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

    func saveLikeProduct(product: Product) async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            realmTaskQueue.async {
                let productTable = ProductTable(
                    productID: product.productID,
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
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func deleteLikeProduct(productID: Int) async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            realmTaskQueue.async {
                guard let object = self.realm.object(
                    ofType: ProductTable.self,
                    forPrimaryKey: productID
                ) else { return }
                do {
                    try self.realm.write {
                        self.realm.delete(object)
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchAllLikeProducts() async -> [Product] {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }
            realmTaskQueue.async {
                let objects = self.realm
                    .objects(ProductTable.self)
                    .sorted(
                        byKeyPath: "enrolledDate",
                        ascending: false
                    )
                continuation.resume(returning: objects.map { $0.toDomain() })
            }
        }
    }

    func fetchQueryLikeProducts(query: String) async -> [Product] {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }
            realmTaskQueue.async {
                let objets = self.realm
                    .objects(ProductTable.self)
                    .where { $0.title.contains(query) }
                    .sorted(
                        byKeyPath: "enrolledDate",
                        ascending: false
                    )
                continuation.resume(returning: objets.map { $0.toDomain() })
            }
        }
    }

    func isLikeProduct(productID: Int) async -> Bool {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else { return }
            realmTaskQueue.async {
                if let _ = self.realm.object(
                    ofType: ProductTable.self,
                    forPrimaryKey: productID
                ) {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
