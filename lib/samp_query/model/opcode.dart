// Copyright 2021-2022 Marlon "Eiss" Lorram (eiss@artplay.games).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of samp_query;

/// A class that provides a list of valid opcodes.
/// Represents a query method from the SA:MP.
class Opcode {
  final String _opcode;

  /// INFO is the 'i' packet type
  static const Opcode INFO = Opcode._('i');

  /// Construct a new Opcode for the given opcode.
  const Opcode._(String opcode) : _opcode = opcode;

  /// Returns the string value of the opcode.
  String get opcode => _opcode;
}
