// Copyright 2021 Marlon Lorram [marlonlorram96@gmail.com].
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of samp_query;

/// Handles SA:MP server queries.
///
/// This class is designed to communicate with SA:MP (San Andreas Multiplayer) servers
/// to retrieve information.
class SAMPQuery {
  /// Sends a query to the specified SA:MP server and returns server information.
  ///
  /// It attempts to send the query up to [maxRetries] times in case of failures.
  /// Returns [Info] containing the server's details or null if the query fails.
  Future<Info?> send(Server server, {int maxRetries = 5}) async {
    final _address = InternetAddress.tryParse(server.address);
    if (_address == null) {
      return null;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      RawDatagramSocket? socket;
      StreamSubscription<RawSocketEvent>? subscription;

      try {
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        final packet = _buildPacket(server);
        socket.send(packet, _address, server.port);

        final completer = Completer<Info>();
        subscription = _handleSocketEvents(socket, completer, server);

        return await completer.future.timeout(
          const Duration(seconds: 1),
        );
      } catch (_) {
        if (attempt == maxRetries - 1) {
          return null;
        }
      } finally {
        await subscription?.cancel();
        socket?.close();
      }
    }

    return null;
  }

  /// Handles the socket events to process the server's response.
  ///
  /// Listens for the read events from the socket and processes the incoming datagram
  /// to extract the server information.
  StreamSubscription<RawSocketEvent> _handleSocketEvents(
    RawDatagramSocket socket,
    Completer<Info> completer,
    Server server,
  ) {
    return socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();

        if (datagram != null && datagram.address.address == server.address) {
          final serverInfo =
              _getInfo(datagram, '${server.address}/${server.port}');

          completer.complete(serverInfo);
          socket.close();
        }
      }
    }, onError: (e) {
      socket.close();
      completer.completeError(e);
    }, onDone: () {
      socket.close();
    });
  }

  /// Builds a packet for sending a query to the SA:MP server.
  ///
  /// Constructs a byte array according to the SA:MP server query protocol.
  List<int> _buildPacket(Server server) {
    final packet = <int>[];

    /// Add the characters 'S', 'A', 'M' and 'P' to the packet.
    packet.addAll('SAMP'.codeUnits);

    /// Split the IP address into parts.
    final ipParts = server.address.split('.');
    if (ipParts.length != 4) {
      return packet;
    }

    /// Add each part of the IP address to the packet.
    for (var ipPart in ipParts) {
      packet.add(int.parse(ipPart));
    }

    packet.add(server.port & 0xFF);
    packet.add(server.port >> 8 & 0xFF);
    packet.add('i'.codeUnitAt(0));

    return packet;
  }

  /// Processes the received datagram and extracts the server information.
  ///
  /// Parses the datagram according to the SA:MP query response format to obtain
  /// and return detailed server information.
  Info _getInfo(Datagram responsePacket, String address) {
    var data = responsePacket.data;

    // Skip the first 11 bytes.
    var offset = 11;

    // Check if the data is long enough before trying to read it.
    if (data.length < offset + 5) {
      throw Exception('Response packet is shorter than expected.');
    }

    // Parse the informations.
    final password = data[offset];
    final players = data[offset + 1] | (data[offset + 2] << 8);
    final maxPlayers = data[offset + 3] | (data[offset + 4] << 8);

    offset += 5;

    // Read the hostname.
    final hostnameLen = data[offset] | (data[offset + 1] << 8);
    offset += 4;
    final hostname = String.fromCharCodes(data, offset, offset + hostnameLen);
    offset += hostnameLen;

    // Read the gamemode.
    final gamemodeLen = data[offset] | (data[offset + 1] << 8);
    offset += 4;
    final gamemode = String.fromCharCodes(data, offset, offset + gamemodeLen);
    offset += gamemodeLen;

    // Read the language.
    final languageLen = data[offset] | (data[offset + 1] << 8);
    offset += 4;
    final language = String.fromCharCodes(data, offset, offset + languageLen);

    return Info(
      address,
      password,
      players,
      maxPlayers,
      hostname,
      gamemode,
      language,
    );
  }
}
