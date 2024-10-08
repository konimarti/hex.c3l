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

-   Hex code dump like `hexdump -C`

```cpp
import encoding::hex;

fn void! main() {
	hex::dump("\t c3 is great! \n")!;
}

// Output:
// $ c3c compile-run examples/dump.c3
// 00000000  09 20 63 33 20 69 73 20  67 72 65 61 74 21 20 0a  |. c3 is great! .|
```
