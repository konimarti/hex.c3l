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

fn void test_encoder() {
	char[64] buf;
	HexEncoder enc;
	ByteWriter w;
	foreach (t : tests) {
		enc.init(w.init_with_buffer(&buf));
		enc.write(t.dec)!;
		String want = ((String)t.enc).temp_ascii_to_lower();
		String got = w.str_view();
		assert(got == want, "got: %s, wanted: %s", got, want);
	}
}

fn void test_decode() {
	int n;
	foreach (t : tests) {
		char [64] buf;
		n = hex::decode(buf[:decoded_len(t.enc.len)], t.enc)!;
		assert(t.dec == buf[:n], "got: %s, wanted: %s", buf[:n], t.dec);
	}
}

fn void test_decode_string() {
	foreach (t : tests) {
		String input = ((String)t.enc).temp_ascii_to_lower();
		char[] got = hex::decode_string((String)t.enc, allocator::temp())!;
		assert((String)got == (String)t.dec, "got: %s, wanted: %s", got, t.dec);
	}
}

fn void test_decoder() {
	char[64] buf;
	usz! n;
	HexDecoder dec;
	foreach (t : tests) {
		String input = ((String)t.enc).temp_ascii_to_lower();
		bool unexpect_eof = input.len == 0;
		dec.init(ByteReader{}.init(input));
		n = dec.read(&buf);
		if (catch err = n) {
			if (err == hex::Errors.UNEXPECTED_EOF && unexpect_eof) {
				continue;
			}
			return err?;
		}
		assert(buf[:n] == t.dec, "got: %s, wanted: %s", buf[:n], t.dec);
	}
}


fn void test_dump_bytes() {
	char [40] input;
	foreach (i, &c : input) *c = (char)i + 30;
	ByteWriter w;
	w.new_init();
	w.ensure_capacity(hex::decoded_len(input.len))!!;
	hex::dump_bytes(&input, &w)!!;
	String expected =
	"00000000  1e 1f 20 21 22 23 24 25  26 27 28 29 2a 2b 2c 2d  |.. !\"#$%&'()*+,-|\n"
	"00000010  2e 2f 30 31 32 33 34 35  36 37 38 39 3a 3b 3c 3d  |./0123456789:;<=|\n"
	"00000020  3e 3f 40 41 42 43 44 45                           |>?@ABCDE|\n";
	String got = w.str_view();
	assert(got == expected, "got: %s, wanted: %s", got, expected);
	w.destroy()!!;
}

struct ErrTestCase {
	char[] in;
	anyfault err;
}

ErrTestCase[] err_tests = {
	{"", anyfault{}},
	{"0", hex::Errors.INVALID_LENGTH},
	{"zd4aa", hex::Errors.INVALID_BYTE},
	{"d4aaz", hex::Errors.INVALID_BYTE},
	{"30313", hex::Errors.INVALID_LENGTH},
	{"0g", hex::Errors.INVALID_BYTE},
	{"00gg", hex::Errors.INVALID_BYTE},
	{"0\x0101", hex::Errors.INVALID_BYTE},
	{"ffeed", hex::Errors.INVALID_LENGTH}
};

fn void test_decode_err() {
	char [64] buf;
	foreach (t : err_tests) {
		anyfault err = @catch(hex::decode(buf[..], t.in));
		assert(err == t.err, "wrong error: got: %s, but wanted: %s", err, t.err);
	}
}
