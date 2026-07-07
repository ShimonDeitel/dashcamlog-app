import XCTest
@testable import DashCamFootageLog

@MainActor
final class DashCamFootageLogTests: XCTestCase {
    var store: ClipEntryStore!

    override func setUp() {
        super.setUp()
        store = ClipEntryStore()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, ClipEntryStore.freeLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        let added = store.add(ClipEntry(name: "Test", detail: "d", date: Date()))
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<20 {
            _ = store.add(ClipEntry(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertEqual(store.items.count, ClipEntryStore.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<20 {
            _ = store.add(ClipEntry(name: "Item \(i)", detail: "d", date: Date()))
        }
        XCTAssertGreaterThan(store.items.count, ClipEntryStore.freeLimit)
    }

    func testDeleteRemovesItem() {
        let item = ClipEntry(name: "ToDelete", detail: "d", date: Date())
        _ = store.add(item)
        store.delete(id: item.id)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testUpdateChangesFields() {
        var item = ClipEntry(name: "Orig", detail: "d", date: Date())
        _ = store.add(item)
        item.name = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.name, "Updated")
    }

    func testCanAddMoreReflectsLimit() {
        while store.canAddMore {
            _ = store.add(ClipEntry(name: "X", detail: "d", date: Date()))
        }
        XCTAssertFalse(store.canAddMore)
    }
}
