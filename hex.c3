/*
 * Hex implements hexadecimal encoding and decoding.
 */
module encoding::hex;
import std::io;

// The hex encoding module is based on code from Go (src/encoding/hex/hex.go)
// by the Go Authors and governed by a BSD-style license, copied below:
// ----------------------------------------------------------------------
// Copyright (c) 2009 The Go Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//    * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//    * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ----------------------------------------------------------------------


const char[*] HEXTABLE @private = "0123456789abcdef";
const char[*] REVERSE_HEXTABLE @private = x""
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
macro int encoded_len(int n) => n * 2;

/**
 * Hexadecimally encodes bytes in src into dst. Returns the number of bytes
 * written to dst.
 *
 * @require dst.len >= encoded_len(src.len) "Destination array is not large enough"
 **/
fn int encode(char[] dst, char[] src) {
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
	INVALID_BYTE,
	DUMPER_CLOSED
}

/**
 * Returns the hexadeicmal encoding of src. Returned string is allocated with
 * the provided allocator (default: heap).
 *
 **/
 fn String encode_to_string(char[] src, Allocator allocator = allocator::heap()) {
	 char[] dst = allocator::alloc_array(allocator, char, encoded_len(src.len));
	 int n = encode(dst, src);
	 return (String)dst;
 }

/* Returns the length of a decoding of x source bytes. */
macro int decoded_len(int x) => x / 2;

/**
 * Decodes src into bytes. Returns the actual number of bytes written to dst.
 *
 * Expects that src only contains hexadecimal characters and that src has even
 * length.
 *
 * @require dst.len >= decoded_len(src.len) "Destination array is not large enough"
 **/
fn int! decode(char[] dst, char[] src) {
	int i, j;
	char p, q, a, b;
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

/**
 * Returns the bytes represented by the hexadecimal string s.
 *
 **/
 fn char[]! decode_string(String s, Allocator allocator = allocator::heap()) {
	 char[] dst = allocator::alloc_array(allocator, char, decoded_len(s.len));
	 decode(dst, s)!;
	 return dst;
 }


/*
 * Dumper implements the OutStream interface.
 */
struct Dumper (OutStream) {
	OutStream out;
	char[18] rightChars;
	char[14] buf;
	usz used; 
	usz n;
	bool closed;
}

/**
 * @require io::@is_outstream(out) "The output must implement OutStream"
 **/
fn Dumper dumper(OutStream out = io::stdout()) {
	return {.out = out};
}

fn void! Dumper.write_byte(&self, char c) @dynamic {
	char[*] data = { c };
	usz! n = self.write(&data);
	if (catch excuse = n) {
		return excuse?;
	}
}

fn usz! Dumper.write(&self, char[] data) @dynamic {
	if (self.closed) {
		return Errors.DUMPER_CLOSED?;
	}

	usz l, n;
	for (int i = 0; i < data.len; i++) {
		if (self.used == 0) {
			// at the beginnig of a line we print the current 
			// offset in hex.
			self.buf[0] = (char)(self.n >> 24);
			self.buf[1] = (char)(self.n >> 16);
			self.buf[2] = (char)(self.n >> 8);
			self.buf[3] = (char)self.n;
			encode(self.buf[4..], self.buf[..4]);
			self.buf[12] = ' ';
			self.buf[13] = ' ';
			io::fprint(self.out, self.buf[4..])!;
		}
		encode(&self.buf, data[i:1]);
		self.buf[2] = ' ';
		l = 3;
		if (self.used == 7) {
			self.buf[3] = ' ';
			l = 4;
		} else if (self.used == 15) {
			self.buf[3] = ' ';
			self.buf[4] = '|';
			l = 5;
		}
		io::fprint(self.out, self.buf[:l])!;
		n++;
		self.rightChars[self.used] = toChar(data[i]);
		self.used++;
		self.n++;
		if (self.used == 16) {
			self.rightChars[16] = '|';
			self.rightChars[17] = '\n';
			io::fprint(self.out, self.rightChars[0..])!;
			self.used = 0;
		}
	}
	return n;
}

macro char toChar(b) @private => (b < 32 || b > 126) ? '.' : b;

fn void! Dumper.flush(&self) @dynamic {
	if (self.closed) {
		return Errors.DUMPER_CLOSED?;
	}

	int l;
	if (self.used == 0) return;
	self.buf[0] = ' ';
	self.buf[1] = ' ';
	self.buf[2] = ' ';
	self.buf[3] = ' ';
	self.buf[4] = '|';

	usz nbytes = self.used;
	while (self.used < 16) {
		l = 3;
		if (self.used == 7) {
			l = 4;
		} else if (self.used == 15) {
			l = 5;
		}
		io::fprint(self.out, self.buf[:l])!;
		self.used++;
	}
	self.rightChars[nbytes] = '|';
	self.rightChars[nbytes+1] = '\n';
	io::fprint(self.out, self.rightChars[:nbytes+2])!;
}

fn void! Dumper.close(&self) @dynamic {
	if (self.closed) {
		return;
	}
	self.flush()!;
	self.closed = true;
}

/**
 * Dump bytes similar to how 'hexdump -Cv' output looks like.
 *
 * Output lines look like:
 * 00000010  2e 2f 30 31 32 33 34 35  36 37 38 39 3a 3b 3c 3d  |./0123456789:;<=|
 * ^ offset                          ^ extra space              ^ ASCII of line.
 *
 * @require io::@is_instream(in) "input must implement InStream"
 * @require io::@is_outstream(out) "output must implement OutStream"
 **/
fn void! dump(InStream in, OutStream out = io::stdout()) {
	char[16] buf;
	usz! n, w;

	Dumper d = dumper(out);
	for (;;) {
		n = in.read(&buf);
		if (catch excuse = n) {
			// io::printfn("excuse: %s", excuse);
			break;
		}
		w = d.write(buf[:n]);
		if (catch excuse = w) {
			// io::printfn("excuse: %s", excuse);
			break;
		}
		if (n<16) break;
	} 
	return d.close();
}

fn void! dump_bytes(char[] bytes, OutStream out = io::stdout()) {
	ByteReader r;
	return dump(r.init(bytes), out);
}
