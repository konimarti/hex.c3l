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
