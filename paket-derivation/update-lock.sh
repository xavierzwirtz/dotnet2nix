#!/usr/bin/env nix-shell
#! nix-shell shell.nix -i bash

set -eu -o pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

nix build -f "$DIR/lock.nix"
derivation=$(nix eval -f "$DIR/lock.nix" --raw "")

(
    MYTMPDIR=$(mktemp -d)
    trap "rm -rf $MYTMPDIR" EXIT

    cp --no-preserve all -r "$derivation/." "$MYTMPDIR"
    cd "$MYTMPDIR"
    rm -rf ".paket/paket.exe"
    rm -rf ".paket/paket.bootstrapper.exe"
    dotnet restore
    #dotnet list package --include-transitive
    dotnet2nix > "$DIR/dotnet.lock.nix"
)

echo "dotnet.lock.nix updated"