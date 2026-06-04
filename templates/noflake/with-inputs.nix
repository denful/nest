# Loads `with-inputs` from the npins pin, then wires npins sources as inputs.
# `(import ./npins)` evaluates sources.json → attrset of pinned store paths.
# `.with-inputs` is one of those pins (denful/with-inputs library).
# `.from.npins ./.` tells it: read THIS directory's npins/sources.json for inputs.
(import (import ./npins).with-inputs).from.npins ./.
