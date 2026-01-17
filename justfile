set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

set quiet

build:
    ./bin/bindgen.exe ./bindgen.sjson
    zig build -p bindings