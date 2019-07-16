
import PerfectLib

try Dir("_site").create()

let file = File("_site/aaa.txt")
try file.open(.readWrite)

for i in 0..<1000 {
    try file.write(string: String(i) + "\n")
}

file.close()
