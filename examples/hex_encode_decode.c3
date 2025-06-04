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
