# Hex encoding in C3

Hex encoding and decoding in C3.

### Setup

Add the path to the `hex.c3l` folder to `dependency-search-paths` and
`hex` to `dependencies` in your `project.json` file:

```json
{
    "dependency-search-paths": ["lib", "<path_to_hex.c3l_folder>"],
    "dependencies": ["hex"]
}
```

### Example

-   Dump hex code like `hexdump -C`

```cpp
// c3c compile-run examples/dump.c3
import std::io;
import encoding::hex;

fn void! main() {
	hex::dump("c3 is fun")!;
}

```
