//
//  LandingViewController.swift
//  AIOSXDemo
//

import Cocoa

class LandingViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    // NSTableViewDataSource implementation

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return Details.TableView.numberOfRows
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = Details.TableView.viewIdentifierForTableRow(row)
        guard let cellView = tableView.makeViewWithIdentifier(identifier, owner: self) as? NSTableCellView else {
            return nil
        }

        return cellView
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }

        let selectedRow = tableView.selectedRow
        let segueIdentifier = Details.segueIdentifierForTableRow(selectedRow)

        self.performSegueWithIdentifier(segueIdentifier, sender: self)
        tableView.deselectRow(selectedRow)
    }

    // Details

    private struct Details {

        struct TableView {
            static func viewIdentifierForTableRow(row: Int) -> String {
                return "TableCellView\(row)"
            }

            static let numberOfRows: Int = 2
        }

        static func segueIdentifierForTableRow(row: Int) -> String {
            return "Segue\(row)"
        }
    }
}

