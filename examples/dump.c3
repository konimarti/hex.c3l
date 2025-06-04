// $ c3c compile-run hex.c3 examples/dump.c3 < /usr/bin/echo
import encoding::hex;
import std::io;

fn void main() {
	hex::dump(io::stdin(), io::stdout())!!;
}
