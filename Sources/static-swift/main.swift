
import CSV
import Foundation
import ZIPFoundation

let fm = FileManager.default

if fm.currentDirectoryPath.contains("DerivedData") {
    // For Xcode
    print("Xcode detected, chdir to SRC_ROOT")
    fm.changeCurrentDirectoryPath(URL(fileURLWithPath: "../..", relativeTo: URL(fileURLWithPath: #file)).path)
}
try? fm.removeItem(atPath: "_site")
try fm.createDirectory(atPath: "_site", withIntermediateDirectories: true)

URLSession.shared.downloadTask(with: URL(string: "https://simplemaps.com/static/data/world-cities/basic/simplemaps_worldcities_basicv1.5.zip")!) { (url, response, error) in
    guard let url = url else { return }
    try! fm.moveItem(atPath: url.path, toPath: "_site/cities.zip")
    try! FileManager.default.unzipItem(at: URL(fileURLWithPath: "_site/cities.zip"), to: URL(fileURLWithPath: "_site"))

    let stream = InputStream(fileAtPath: "_site/worldcities.csv")!
    let csv = try! CSVReader(stream: stream)
    let output = try! CSVWriter(stream: OutputStream(toFileAtPath: "_site/cities_time_zones.csv", append: false)!)
    for row in csv.dropFirst() {
        let name = row[0]
        let country = row[4]
        let location = CLLocationCoordinate2D(latitude: Double(row[2])!, longitude: Double(row[3])!)
        let timezone = TimezoneMapper.latLngToTimezone(location)!
        try! output.write(row: [name, country, timezone.identifier])
    }
    exit(0)
}.resume()


dispatchMain()
