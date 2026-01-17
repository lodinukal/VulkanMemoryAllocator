set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

set quiet

build:
    zig build -p bindings
    ./bin/bindgen.exe ./bindgen.sjson