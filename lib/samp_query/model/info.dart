// Copyright 2021 Marlon Lorram [marlonlorram96@gmail.com].
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of samp_query;

/// An instance of server query results.
class Info {
  /// Ip of the server
  String address;

  /// Does the server uses a password?
  int password;

  /// Current amount of players online on the server.
  int players;

  /// Maximum amount of players that can join the server.
  int maxPlayers;

  /// Hostname of the server.
  String hostname;

  /// Gamemode of the server.
  String gamemode;

  /// Language of the server.
  String language;

  Info(
    this.address,
    this.password,
    this.players,
    this.maxPlayers,
    this.hostname,
    this.gamemode,
    this.language,
  );
}
