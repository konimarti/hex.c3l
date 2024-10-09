# Hex encoding in C3

Hex encoding and decoding in C3. Port of Go's
[encoding/hex](https://pkg.go.dev/encoding/hex) package.

### Setup

Add the path to the `hex.c3l` folder to `dependency-search-paths` and
`hex` to `dependencies` in your `project.json` file:

```json
{
    "dependency-search-paths": ["lib", "<path_to_hex.c3l_folder>"],
    "dependencies": ["hex"]
}
```

### Examples

Hex code dump like `hexdump -Cv`

-   use `hex::dump_bytes` with a `char[]` argument:

    ```cpp
    // $ c3c compile-run hex.c3 examples/dump_bytes.c3
    //
    // Output:
    // 00000000  09 20 63 33 20 69 73 20  67 72 65 61 74 21 20 0a  |. c3 is great! .|
    //
    import encoding::hex;
    import std::io;

    fn void! main() {
        hex::dump_bytes("\t c3 is great! \n")!;
    }
    ```

-   use `hex::dump` with an `InStream` argument:

    ```cpp
    // $ c3c compile-run hex.c3 examples/dump.c3 < /usr/bin/echo # or any other binary
    import encoding::hex;
    import std::io;

    fn void! main() {
        hex::dump(io::stdin(), io::stdout())!;
    }
    ```
