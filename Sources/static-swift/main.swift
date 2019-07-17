
import AwaitKit
import CSV
import Foundation
import PromiseKit
import PMKFoundation
import ZIPFoundation

let fm = FileManager.default

if fm.currentDirectoryPath.contains("DerivedData") {
    // For Xcode
    print("Xcode detected, chdir to SRC_ROOT")
    fm.changeCurrentDirectoryPath(URL(fileURLWithPath: "../..", relativeTo: URL(fileURLWithPath: #file)).path)
}

let site = URL(fileURLWithPath: "_site")
try? fm.removeItem(at: site)
try fm.createDirectory(at: site, withIntermediateDirectories: true)

let remoteURL = URL(string: "https://simplemaps.com/static/data/world-cities/basic/simplemaps_worldcities_basicv1.5.zip")!
let localURL = URL(fileURLWithPath: "_site/cities.zip")
try await(URLSession.shared.downloadTask(.promise, with: remoteURL, to: localURL))

try FileManager.default.unzipItem(at: localURL, to: site)

let stream = InputStream(fileAtPath: "_site/worldcities.csv")!
let csv = try CSVReader(stream: stream)
let output = try CSVWriter(stream: OutputStream(toFileAtPath: "_site/cities_time_zones.csv", append: false)!)

for row in csv.dropFirst() {
    let name = row[0]
    let country = row[4]
    let location = CLLocationCoordinate2D(latitude: Double(row[2])!, longitude: Double(row[3])!)
    let timezone = TimezoneMapper.latLngToTimezone(location)!
    try! output.write(row: [name, country, timezone.identifier])
}

