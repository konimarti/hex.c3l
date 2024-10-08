/*
 * Hex implements hexadecimal encoding and decoding.
 * Based on the Go implementation src/encoding/hex/hex.go
 */

module encoding::hex;

const char[*] HEXTABLE = "0123456789abcdef";
const char[*] REVERSE_HEXTABLE = x""
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"00010203040506070809ffffffffffff"
x"ff0a0b0c0d0e0fffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ff0a0b0c0d0e0fffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff"
x"ffffffffffffffffffffffffffffffff";


/* Returns the length of an encoding of n source bytes. */
fn int encoded_len(int n) => n * 2;

/* Hexadecimally encodes bytes in src into dst. Returns the number of bytes
 * written to dst.
 */
fn int encode(char[] src, char[] dst) {
	int j = 0;
	foreach (v : src) {
		dst[j] = HEXTABLE[v >> 4];
		dst[j + 1] = HEXTABLE[v & 0x0f];
		j = j + 2;
	}
	return src.len * 2;
}

fault Errors {
	INVALID_LENGTH,
	INVALID_BYTE
}

/* Returns the length of a decoding of x source bytes. */
fn int decoded_len(int x) => x / 2;

/* Decodes src into bytes. Returns the actual number of bytes written to dst.
 *
 * Expects that src only contains hexadecimal characters and that src has even
 * length.
 *
 */
fn int! decode(char[] dst, char[] src) {
	int i;
	int j;
	char p;
	char q;
	char a;
	char b;
	for (j = 1; j < src.len; j += 2) {
		p = src[j-1];
		q = src[j];
		a = REVERSE_HEXTABLE[p];
		b = REVERSE_HEXTABLE[q];
		if (a > 0x0f) {
			return Errors.INVALID_BYTE?;
		}
		if (b > 0x0f) {
			return Errors.INVALID_BYTE?;
		}
		dst[i] = (a << 4) | b;
		i++;
	}
	if (src.len % 2 == 1) {
		if (REVERSE_HEXTABLE[src[j-1]] > 0x0f) {
			return Errors.INVALID_BYTE?;
		}
		return Errors.INVALID_LENGTH?;
	}
	return i;
}

module encoding::hex @test;

import std::io;

struct TestCase {
	char[] dec;
	char[] enc;
}

TestCase[] tests = {
	{"", ""},
	{{'g'}, "67"},
	{{0,1,2,3,4,5,6,7}, "0001020304050607"},
	{{8,9,10,11,12,13,14,15}, "08090a0b0c0d0e0f"},
	{{0xf0, 0xf1, 0xf2, 0xf3}, "f0f1f2f3"},
	{{0xe3, 0xa1}, "e3a1"},
	{{0xe3, 0xa1}, "E3A1"},
};

fn void test_encode() {
	int n;
	foreach (t : tests) {
		char [64] buf;
		n = hex::encode(t.dec, buf[:encoded_len(t.dec.len)]);
		// String enc = ((String)t.enc).temp_ascii_to_lower();
		String enc = ((String)t.enc).temp_ascii_to_lower();
		assert(enc == buf[:n], "got: %s, wanted: %s", buf[:n], enc);
	}
}

fn void test_decode() {
	int! n;
	foreach (t : tests) {
		char [64] buf;
		n = hex::decode(buf[:decoded_len(t.enc.len)], t.enc);
		if (catch excuse = n) {
			io::printfn("caught: %s", excuse);
			assert(false, "caught error");
		}
		assert(t.dec == buf[:n], "got: %s, wanted: %s", buf[:n], t.dec);
	}
}
