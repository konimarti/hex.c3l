import std::io;
import encoding::hex;

fn void! main() {
	hex::dump(io::stdout(), "c3 is fun")!;
}
