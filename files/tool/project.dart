import 'dart:async';
import 'dart:io';

import 'config.dart';

Future<int> run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final signals = <StreamSubscription<ProcessSignal>>[
    for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm])
      signal.watch().listen((event) => process.kill(event)),
  ];
  try {
    return await process.exitCode;
  } finally {
    for (final signal in signals) {
      await signal.cancel();
    }
  }
}

Future<void> main(List<String> args) async {
  final command = args.isEmpty ? 'help' : args.first;
  const commands = [
    'configure',
    'dev',
    'run',
    'build',
    'build-android',
    'build-ios',
    'test',
    'check',
    'format',
    'start',
  ];
  if (!commands.contains(command)) {
    stdout.writeln(
      'Usage: dart run tool/project.dart ${commands.join('|')} [flutter arguments]',
    );
    exitCode = command == 'help' ? 0 : 64;
    return;
  }
  try {
    final config = ProjectConfig.load();
    configureProject(config);
    const defines = '--dart-define-from-file=build/config/public.json';
    // Without a terminal (fastDev, CI) compact test output is one long line.
    final reporter = [if (!stdout.hasTerminal) '--reporter=expanded'];
    final extra = args.skip(1).toList();
    final steps = switch (command) {
      'configure' => <(String, List<String>)>[],
      'dev' => [
        (
          'flutter',
          [
            'run',
            '--no-pub',
            '-d',
            'web-server',
            '--web-hostname=127.0.0.1',
            '--web-port=${config.port}',
            defines,
            ...extra,
          ],
        ),
      ],
      'run' => [
        ('flutter', ['run', '--no-pub', defines, ...extra]),
      ],
      'build' => [
        (
          'flutter',
          ['build', 'web', '--no-pub', '--release', defines, ...extra],
        ),
      ],
      'build-android' => [
        (
          'flutter',
          ['build', 'apk', '--no-pub', '--release', defines, ...extra],
        ),
      ],
      'build-ios' => [
        (
          'flutter',
          [
            'build',
            'ios',
            '--no-pub',
            '--release',
            '--no-codesign',
            defines,
            ...extra,
          ],
        ),
      ],
      'test' => [
        ('flutter', ['test', '--no-pub', defines, ...reporter, ...extra]),
      ],
      'format' => [
        ('dart', ['format', 'lib', 'test', 'tool']),
      ],
      'check' => [
        (
          'dart',
          [
            'format',
            '--output=none',
            '--set-exit-if-changed',
            'lib',
            'test',
            'tool',
          ],
        ),
        (
          'flutter',
          ['analyze', '--no-pub', '--fatal-infos', '--fatal-warnings'],
        ),
        ('flutter', ['test', '--no-pub', defines, ...reporter]),
      ],
      'start' => <(String, List<String>)>[],
      _ => throw StateError('Unsupported command.'),
    };
    if (command == 'start') {
      await serve(config.port);
      return;
    }
    for (final (executable, arguments) in steps) {
      final code = await run(executable, arguments);
      if (code != 0) {
        exitCode = code;
        return;
      }
    }
  } on Exception catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Future<void> serve(int port) async {
  final root = Directory('build/web');
  if (!root.existsSync()) throw StateError('Run build before start.');
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Serving build/web at http://127.0.0.1:$port');
  final signals = [
    for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm])
      signal.watch().listen((event) {
        unawaited(server.close(force: true));
      }),
  ];
  try {
    // Concurrent responses: one slow or aborted download cannot block others.
    await for (final request in server) {
      unawaited(respond(root, request).catchError((Object _) {}));
    }
  } finally {
    for (final signal in signals) {
      await signal.cancel();
    }
  }
}

Future<void> respond(Directory root, HttpRequest request) async {
  final segments = request.uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.any(
    (segment) =>
        segment == '..' || segment.contains('/') || segment.contains('\\'),
  )) {
    request.response.statusCode = HttpStatus.badRequest;
    await request.response.close();
    return;
  }
  final file = File(
    '${root.path}/${segments.isEmpty ? 'index.html' : segments.join('/')}',
  );
  if (!file.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
  } else {
    final extension = file.path.split('.').last;
    final contentTypes = {
      'html': 'text/html; charset=utf-8',
      'js': 'application/javascript',
      'mjs': 'application/javascript',
      'json': 'application/json',
      'wasm': 'application/wasm',
      'css': 'text/css',
      'png': 'image/png',
      'svg': 'image/svg+xml',
      'woff2': 'font/woff2',
    };
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      contentTypes[extension] ?? 'application/octet-stream',
    );
    request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    await request.response.addStream(file.openRead());
  }
  await request.response.close();
}
