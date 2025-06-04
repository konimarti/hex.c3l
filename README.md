# Hex encoding in C3

Hex encoding and decoding in C3. Port of Go's
[encoding/hex](https://pkg.go.dev/encoding/hex) package.

### Install

Add the path to the `hex.c3l` folder to `dependency-search-paths` and
`hex` to `dependencies` in your `project.json` file:

```json
{
    "dependency-search-paths": ["lib", "<path_to_hex.c3l_folder>"],
    "dependencies": ["hex"]
}
```

### Examples

Hex encoding and decoding:
```cpp
// $ c3c compile-run hex.c3 examples/hex_encode_decode.c3

import encoding::hex;
import std::io;

fn void main() {
	int n; 
	char[10] enc;
	char[5] dec;

	char[*] input = {99,51,99,9,33};

	n = hex::encode(enc[..], input[..]);
	assert(n == input.len*2, "input not fully encoded");

	n = hex::decode(dec[..], enc[..])!!;
	assert(n == input.len, "input not fully decoded");

	assert(dec == input);

	io::printfn("input  : %s", (String)&input);
	io::printfn("encoded: %s", (String)&enc);
	io::printfn("decoded: %s", (String)&dec);
}

// Output:
// input  : c3c    !
// encoded: 6333630921
// decoded: c3c    !
```

Hex code dump like `hexdump -Cv`

-   use `hex::dump_bytes` with `char[]`:

    ```cpp
    // $ c3c compile-run hex.c3 examples/dump_bytes.c3

    import encoding::hex;
    import std::io;

    fn void main() {
        hex::dump_bytes("\t c3 is great! \n")!!;
    }
    
    // Output:
    // 00000000  09 20 63 33 20 69 73 20  67 72 65 61 74 21 20 0a  |. c3 is great! .|
    ```

-   use `hex::dump` with `InStream`:

    ```cpp
    // $ c3c compile-run hex.c3 examples/dump.c3 < /usr/bin/echo # or any other binary

    import encoding::hex;
    import std::io;

    fn void main() {
        hex::dump(io::stdin(), io::stdout())!!;
    }
    ```
