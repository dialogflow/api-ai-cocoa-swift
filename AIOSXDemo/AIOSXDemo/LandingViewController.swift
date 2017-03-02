//
//  LandingViewController.swift
//  AIOSXDemo
//

import Cocoa

class LandingViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    // NSTableViewDataSource implementation

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Details.TableView.numberOfRows
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = Details.TableView.viewIdentifierForTableRow(row)
        guard let cellView = tableView.make(withIdentifier: identifier, owner: self) as? NSTableCellView else {
            return nil
        }

        return cellView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }

        let selectedRow = tableView.selectedRow
        let segueIdentifier = Details.segueIdentifierForTableRow(selectedRow)

        self.performSegue(withIdentifier: segueIdentifier, sender: self)
        tableView.deselectRow(selectedRow)
    }

    // Details

    fileprivate struct Details {

        struct TableView {
            static func viewIdentifierForTableRow(_ row: Int) -> String {
                return "TableCellView\(row)"
            }

            static let numberOfRows: Int = 2
        }

        static func segueIdentifierForTableRow(_ row: Int) -> String {
            return "Segue\(row)"
        }
    }
}

