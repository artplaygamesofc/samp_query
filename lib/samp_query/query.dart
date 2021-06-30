// Copyright 2021-2022 Marlon "Eiss" Lorram (eiss@artplay.games).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of samp_query;

/// This class handles the SA:MP query mechanism.
class SAMPQuery {
  /// The offset in the packet
  int offset;

  late final RawDatagramSocket datagramSocket;

  /// The opcode of this request.
  Opcode? _opcode;

  /// The ip of server
  String? _address;

  /// A list of current server information.
  final List<Info>? infos;

  SAMPQuery({
    this.infos,
  }) : offset = 0;

  /// send writes a SA:MP format query with the specified opcode,
  /// returns the raw response bytes.
  Future<SAMPQuery> send(String address, int port,
      {Opcode opcode = Opcode.INFO}) async {
    _opcode = opcode;
    _address = '$address:$port';

    final addresses = await InternetAddress.lookup(address);

    if (addresses.isEmpty) {
      return Future.error('Could not resolve address for $address.');
    }

    final serverAddress = addresses.first;
    final clientAddress = InternetAddress.anyIPv4;

    /// Init datagram socket to anyIPv4
    /// and to port 0.
    datagramSocket = await RawDatagramSocket.bind(clientAddress, 0);

    final packet = <int>[];

    /// SAMP
    packet.add('S'.codeUnitAt(0));
    packet.add('A'.codeUnitAt(0));
    packet.add('M'.codeUnitAt(0));
    packet.add('P'.codeUnitAt(0));

    /// Write the ip 4 bytes to the server.
    final ip = address.split('.');

    if (ip.length != 4) {
      return Future.error('IP has an invalid length.');
    }

    for (final ipPart in ip) {
      packet.add(int.parse(ipPart));
    }

    /// Write the port into the buffer.
    packet.add(port & 15);
    packet.add(port >> 8 & 15);

    /// Write the opcode into the buffer.
    packet.add(_opcode!.opcode.codeUnitAt(0));

    /// Send buffer packet to the address [serverAddress]
    /// and port [port].
    datagramSocket.send(
      packet,
      serverAddress,
      port,
    );

    /// Receive packet from socket.
    Datagram? _packet;

    final receivePacket = (RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        _packet = datagramSocket.receive();
      }
      return _packet != null;
    };

    try {
      await datagramSocket
          .timeout(Duration(milliseconds: 2000))
          .firstWhere(receivePacket);
    } catch (e) {
      rethrow;
    } finally {
      datagramSocket.close();
    }

    /// Skip the first 11 bytes.
    offset += 11;

    /// Parse the informations.
    var infos = <Info>[];

    //infos.first.address = '$address:$port';

    var buf = ByteArray(_packet!.data);

    // Returns the server info.
    _parseInfo(
      buf,
      infos,
    );

    return SAMPQuery(
      infos: infos,
    );
  }

  /// This internal method constructs a correctly
  /// returns the core server info.
  void _parseInfo(ByteArray buffer, List<Info> infos) {
    /// Is the server using a password?
    final password = buffer.readUnsignedByte(offset);

    /// Players on the server.
    final players = buffer.readUnsignedShort(offset += 1);

    /// Player count the server allows.
    final maxPlayers = buffer.readUnsignedShort(offset += 2);

    /// Hostname lenght.
    final hostnameLen = buffer.readUnsignedShort(offset += 2);

    /// Hostname.
    final hostname = buffer.readString(
      offset += 4,
      offset += hostnameLen,
    );

    /// Gamemode lenght.
    final gamemodeLen = buffer.readUnsignedShort(offset);

    /// Gamemode.
    final gamemode = buffer.readString(
      offset += 4,
      offset += gamemodeLen,
    );

    /// Language lenght.
    final languageLen = buffer.readUnsignedShort(offset);

    /// Language.
    final language = buffer.readString(
      offset += 4,
      offset += languageLen,
    );

    infos.add(
      Info(
        _address,
        password,
        players,
        maxPlayers,
        hostname,
        gamemode,
        language,
      ),
    );
  }
}
