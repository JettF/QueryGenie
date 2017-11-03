//
//  Results+ResultsProtocol.swift
//
//  Created by Anthony Miller on 12/29/16.
//

import Foundation
import ObjectiveC

import RealmSwift

private var _sortDescriptorsKey = "QueryGenie.sortDescriptors"

protocol FakeRealmQueryable: Queryable {
    
    associatedtype Item: Object
    
    var realm: Realm? { get }
    
    func setValue(_ value: Any?, forKey key: String)
}

extension FakeRealmQueryable {
    
    public func count() -> Int {
        return Int(objects().count)
    }
    
    public func firstOrCreated(_ predicateClosure: (Object) -> NSComparisonPredicate) throws -> Object {
        //TODO: Fix error
        guard let elementAsObject = Self.Element.self as? Object else { throw RealmError.noRealm }
//        guard let elementAsObject = Self.Element as? Object else { throw RealmError.noRealm}
        let predicate = predicateClosure(Object())
        
        if let entity = self.filter(predicate).first() {
            return entity
            
        } else {
            guard let realm = realm else { throw RealmError.noRealm }
            
            let attributeName = predicate.leftExpression.keyPath
            let value: Any = predicate.rightExpression.constantValue!
            
            let entity = realm.create(Item.self, value: [attributeName: value], update: true)
            
            return entity
        }
    }
    
    private func setValue<T>(_ value: T, for attribute: Attribute<T>) {
        setValue(value, forKey: attribute.___name)
    }
    
    public func setValue<T>(_ value: T, for attributeClosure: (Self.Element.Type) -> Attribute<T>) {
        setValue(value, for: attributeClosure(Self.Element.self))
    }
    
    private func setValue<T>(_ value: T?, for attribute: NullableAttribute<T>) {
        setValue(value, forKey: attribute.___name)
    }
    
    public func setValue<T>(_ value: T?, for attributeClosure: (Self.Element.Type) -> NullableAttribute<T>) {
        setValue(value, for: attributeClosure(Self.Element.self))
    }
    
}

//extension Results: ResultsProtocol {
//
//    public func first() -> Element? {
//        return self.first
//    }
//
//    /*
//     *  MARK: - GenericQueryable
//     */
//
//    public final func objects() -> AnyCollection<Element> {
//        return AnyCollection(self)
//    }
//
//    public func sorted(by keyPath: String, ascending: Bool) -> Results<Element> {
//        let newSort = SortDescriptor(keyPath: keyPath, ascending: ascending)
//
//        var sortDescriptors: [SortDescriptor] = self.sortDescriptors ?? []
//        sortDescriptors.append(newSort)
//
//        let newResults = self.sorted(by: sortDescriptors)
//        newResults.sortDescriptors = sortDescriptors
//        return newResults
//    }
//
//    private var sortDescriptors: [SortDescriptor]? {
//        get {
//            return objc_getAssociatedObject(self, &_sortDescriptorsKey) as? [SortDescriptor]
//        }
//        set {
//            objc_setAssociatedObject(self, &_sortDescriptorsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
//        }
//    }
//
//}

