// Copyright 2021-2022 Marlon "Eiss" Lorram (eiss@artplay.games).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of samp_query;

/// The ByteArray class provides methods and properties
/// for optimizing reading binary data.
class ByteArray {
  ByteData data;
  Uint8List buffer;

  ByteArray(this.buffer) : data = ByteData.view(buffer.buffer);

  /// Read a null-terminated string.
  String readString(int offset, int endOffset) {
    return String.fromCharCodes(buffer.sublist(offset, endOffset));
  }

  /// Read a 8-bit word from the input.
  int readUnsignedByte(int offset) {
    return data.getUint8(offset);
  }

  /// Read a 16-bit word from the input.
  int readUnsignedShort(int offset, [Endian endian = Endian.little]) {
    return data.getUint16(offset, endian);
  }
}
