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
macro int encoded_len(int n) => n * 2;

/**
 * Hexadecimally encodes bytes in src into dst. Returns the number of bytes
 * written to dst.
 *
 * require dst.len >= encoded_len(src.len)
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
	INVALID_BYTE
}

/* Returns the length of a decoding of x source bytes. */
macro int decoded_len(int x) => x / 2;

/**
 * Decodes src into bytes. Returns the actual number of bytes written to dst.
 *
 * Expects that src only contains hexadecimal characters and that src has even
 * length.
 *
 * @require dst.len >= decoded_len(src.len)
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

macro char toChar(b) => (b < 32 || b > 126) ? '.' : b;

/**
 * Dump bytes. Mimic 'hexdump -C'.
 *
 * @require io::@is_outstream(out) "The output must implement OutStream"
 **/
fn void! dump(char[] data, OutStream out = io::stdout()) {
	int used, l;
	char[18] rightChars;
	char[14] buf;
	char n;
	for (int i = 0; i < data.len; i++) {
		if (used == 0) {
			buf[0] = n >> 24;
			buf[1] = n >> 16;
			buf[2] = n >> 8;
			buf[3] = n;
			encode(buf[4..], buf[..4]);
			buf[12] = ' ';
			buf[13] = ' ';
			io::fprintf(out, "%s", buf[4..])!;
		}
		encode(&buf, data[i:i+1]);
		buf[2] = ' ';
		l = 3;
		if (used == 7) {
			buf[3] = ' ';
			l = 4;
		} else if (used == 15) {
			buf[3] = ' ';
			buf[4] = '|';
			l = 5;
		}
		io::fprintf(out, "%s", buf[..l])!;
		n++;
		rightChars[used] = toChar(data[i]);
		used++;
		n++;
		if (used == 16) {
			rightChars[16] = '|';
			rightChars[17] = '\n';
			io::fprintf(out, "%s", rightChars)!;
			used = 0;
		}
	}
}
