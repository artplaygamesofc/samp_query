Implements the
[SA:MP query mechanism](https://wiki.sa-mp.com/wiki/Query_Mechanism) for getting
data about a running server.

## Usage

```dart
import 'package:samp_query/samp_query.dart';

void main() async {
  var query = SAMPQuery();

  /// Sends a query to get the server informations.
  var results = await query.send('ip.artplay.games', 7777);

  /// List the hostname.
  results.infos?.forEach((result) {
    print('Hostname: ${result.hostname}');
  });
}
```
