import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Short-lived HTTP server on the LAN to download selected files from this device.
class LocalFileServer {
  LocalFileServer._(this._paths) {
    token = _randomToken();
  }

  /// Factory validates paths exist before starting.
  factory LocalFileServer.fromPaths(List<String> paths) {
    final existing = paths.where((e) => File(e).existsSync()).toList();
    return LocalFileServer._(existing);
  }

  static const _routePrefix = 'sfttv';

  final List<String> _paths;
  late final String token;

  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;

  int? get port => _server?.port;

  bool get isRunning => _server != null;

  int get fileCount => _paths.length;

  /// Full share URL including port (ends with `/`).
  String fullBaseUrl(String hostIp) {
    final pr = port;
    if (pr == null) return '';
    return 'http://$hostIp:$pr/$_routePrefix/$token/';
  }

  static String _randomToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return String.fromCharCodes(
      List.generate(16, (_) => chars.codeUnitAt(r.nextInt(chars.length))),
    );
  }

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
    _subscription = _server!.listen(
      _handleRequest,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'GET' && request.method != 'HEAD') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      await request.response.close();
      return;
    }

    final segs = request.uri.pathSegments;
    if (segs.isNotEmpty && segs.first == 'favicon.ico') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    if (segs.length < 3 || segs[0] != _routePrefix || segs[1] != token) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    // /sfttv/<token>/ or /sfttv/<token>/download/<i>
    if (segs.length == 2 || (segs.length == 3 && segs[2].isEmpty)) {
      await _sendIndex(request);
      return;
    }

    if (segs.length == 4 && segs[2] == 'download') {
      final i = int.tryParse(segs[3]);
      if (i == null || i < 0 || i >= _paths.length) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      await _sendFile(request, i);
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  Future<void> _sendIndex(HttpRequest request) async {
    final buf = StringBuffer()
      ..write('<!DOCTYPE html><html><head><meta charset="utf-8">')
      ..write(
        '<meta name="viewport" content="width=device-width,initial-scale=1">',
      )
      ..write('<title>Send files to TV</title>')
      ..write(
        '<style>body{font-family:system-ui,-apple-system,sans-serif;padding:16px;'
        'background:#12162d;color:#e8f4ff}a{color:#4fc3f7}li{margin:10px 0}</style>',
      )
      ..write(
        '</head><body><h1>Files on this iPhone</h1><p>Tap a link to download.</p><ul>',
      );

    for (var i = 0; i < _paths.length; i++) {
      final name = htmlEscape.convert(p.basename(_paths[i]));
      buf.write('<li><a href="download/$i">$name</a></li>');
    }

    buf.write('</ul></body></html>');
    final bytes = utf8.encode(buf.toString());
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    request.response.headers.contentLength = bytes.length;
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    if (request.method == 'GET') {
      request.response.add(bytes);
    }
    await request.response.close();
  }

  Future<void> _sendFile(HttpRequest request, int index) async {
    final path = _paths[index];
    final file = File(path);
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final length = await file.length();
    final name = p.basename(path);
    final mime = lookupMimeType(path) ?? 'application/octet-stream';

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.parse(mime);
    request.response.headers.contentLength = length;
    request.response.headers.set(
      'Content-Disposition',
      'attachment; filename="${_asciiFilename(name)}"',
    );
    request.response.headers.set('Access-Control-Allow-Origin', '*');

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    try {
      await request.response.addStream(file.openRead());
    } catch (_) {
      // Client may have disconnected mid-stream.
    }
    await request.response.close();
  }

  /// Safe-ish ASCII fallback for Content-Disposition filename=.
  String _asciiFilename(String name) {
    final b = StringBuffer();
    for (final c in name.runes) {
      if (c >= 32 && c < 127 && c != 34 && c != 92) {
        b.writeCharCode(c);
      } else {
        b.write('_');
      }
    }
    final s = b.toString();
    return s.isEmpty ? 'download.bin' : s;
  }
}
