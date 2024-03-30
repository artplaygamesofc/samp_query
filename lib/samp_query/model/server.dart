// Copyright 2021-2022 Marlon "Eiss" Lorram (eiss@artplay.games).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of samp_query;

/// An instance of server.
class Server {
	/// Ip of the server.
	late final String address;

	/// Port of the server.
	late final int port;

	Server(
		this.address,
		this.port,
	);
}
