# SAMP Query Dart Package

Implements the
[SA:MP query mechanism](https://wiki.sa-mp.com/wiki/Query_Mechanism) for getting
data about a running server.

## Installation

Add `samp_query` to your `pubspec.yaml` file:

```yaml
dependencies:
  samp_query:
    git:
      url: https://github.com/artplaygamesofc/samp_query.git
      ref: main
```

# Usage

## Querying a Single Server

To query a single SA:MP server, you can use the SAMPQuery class. Here is a simple example:

```dart
import 'package:samp_query/samp_query.dart';

void main() async {
  var query = SAMPQuery();

  final server = Server('ip.artplay.games', 7777);

  // Replace 'ip.artplay.games' with the IP of the server you want to query
  var results = await query.send(server);

  if(results != null) {
    // Prints the hostname of the server
    print('Hostname: ${results.hostname}');
  }
}
```

## Querying Multiple Servers

To efficiently query multiple servers, you can use Dart's asynchronous features to send out queries in parallel. Here's how you can do it:

```dart
import 'package:samp_query/samp_query.dart';

void main() async {
  var query = SAMPQuery();

  final servers = [
    Server('ip.artplay.games', 7777),
    Server('ip.artplay.games', 7778),
  ];

  // Creates a list of futures for querying multiple servers
  var tasks = servers.map((server) => queryServer(query, server)).toList();

  // Waits for all the queries to complete
  await Future.wait(tasks);
}

// Helper function to query a server and print its hostname
Future<void> queryServer(SAMPQuery query, Server server) async {
  try {
    var results = await query.send(server);

    if (results != null) {
      print('Hostname: ${results.hostname} for server ${server.address}:${server.port}');
    } else {
      print('Failed to get information for server: ${server.address}:${server.port}');
    }
  } catch (e) {
    print('Error querying server ${server.address}:${server.port}: $e');
  }
}
```

# Handling Errors

The code examples above include basic error handling to deal with network issues or unresponsive servers. It is recommended to expand upon this error handling based on your specific needs.
