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
macro int encoded_len(int n) => n * 2;

/**
 * Hexadecimally encodes bytes in src into dst. Returns the number of bytes
 * written to dst.
 *
 * @require dst.len >= encoded_len(src.len)
 **/
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
