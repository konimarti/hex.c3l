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
		n = hex::encode(buf[:encoded_len(t.dec.len)], t.dec);
		String enc = ((String)t.enc).temp_ascii_to_lower();
		assert(enc == buf[:n], "got: %s, wanted: %s", buf[:n], enc);
	}
}

fn void test_encode_to_string() {
	foreach (t : tests) {
		String got = hex::encode_to_string(t.dec, allocator::temp());
		String want = ((String)t.enc).temp_ascii_to_lower();
		assert(got == want, "got: %s, wanted: %s", got, want);
	}
}

fn void test_decode() {
	int! n;
	foreach (t : tests) {
		char [64] buf;
		n = hex::decode(buf[:decoded_len(t.enc.len)], t.enc);
		if (catch excuse = n) {
			assert(false, "caught: %s", excuse);
		}
		assert(t.dec == buf[:n], "got: %s, wanted: %s", buf[:n], t.dec);
	}
}

fn void test_dump_bytes() {
	String input = "\t c3 is great! \n";
	ByteWriter w;
	w.new_init();
	w.ensure_capacity(hex::decoded_len(input.len))!!;
	hex::dump_bytes(input, &w)!!;
	String expected = "00000000  09 20 63 33 20 69 73 20  67 72 65 61 74 21 20 0a  |. c3 is great! .|\n";
	String got = w.str_view();
	assert(got == expected, "got: %s, wanted: %s", got, expected);
	w.destroy()!!;
}
