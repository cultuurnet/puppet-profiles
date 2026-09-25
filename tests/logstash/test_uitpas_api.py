#!/usr/bin/env python3
"""Run with python3 tests/logstash/test_uitpas_api.py (requires Docker).

Uses synthetic logs only and runs Logstash without network access.
"""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / 'files/uitpas/api'
IMAGE = 'docker.elastic.co/logstash/logstash:8.14.0'


class UitpasLoggingTest(unittest.TestCase):
    def test_parsing_and_routing(self):
        events = []
        for environment in ['testing', 'acceptance', 'production']:
            for severity in ['FINEST', 'FINER', 'FINE', 'CONFIG', 'INFO', 'WARNING', 'SEVERE']:
                events.append({
                    'case': severity,
                    'fields': {'log_type': 'uitpas::api', 'environment': environment,
                               'servername': 'api.example.com'},
                    'message': (
                        '[2026-09-25T13:15:00.991+0200] [Payara 7.2025.1] '
                        f'[{severity}] [] [be.uitpas.Example] '
                        '[tid: _ThreadID=729 _ThreadName=http-thread-pool(26)] '
                        '[timeMillis: 1790334900991] [levelValue: 500] [[\n'
                        'Example event\njava.lang.IllegalStateException: example\n'
                        '\tat be.uitpas.Example.run(Example.java:42)\n]]'
                    ),
                })
        events.append({'case': 'malformed', 'message': 'Unrecognized record',
                       'fields': {'log_type': 'uitpas::api', 'environment': 'testing',
                                  'servername': 'api.example.com'}})
        events.append({'case': 'unrelated', 'message': 'Another application',
                       'fields': {'log_type': 'unrelated'}})
        with tempfile.TemporaryDirectory(prefix='uitpas-logstash-') as directory:
            path = Path(directory)
            # Render the same wrapper as profiles::logstash::filter_fragment.
            rendered = subprocess.run([
                'ruby', '-rerb', '-e',
                '@log_type = "uitpas::api"; @filter = File.read(ARGV[0]); '
                'print ERB.new(File.read(ARGV[1]), trim_mode: "-").result(binding)',
                str(CONFIG / 'logstash_filter.conf'),
                str(ROOT / 'templates/logstash/filter_fragment.erb'),
            ], capture_output=True, text=True, check=True)
            filters = 'filter {\n' + rendered.stdout + '\n}\n' 
            path.joinpath('test.conf').write_text(
                'input { stdin { codec => json_lines { ecs_compatibility => disabled } } }\n' +
                filters + '\nfilter { ruby { code => \'event.set("test_metadata", event.get("@metadata"))\' } }\n'
                'output { stdout { codec => json_lines } }\n')
            command = ['docker', 'run', '--rm', '-i', '--network', 'none',
                       '--hostname', 'logstash-test', '--add-host', 'logstash-test:127.0.0.1',
                       '-e', 'XPACK_MONITORING_ENABLED=false', '-e', 'LS_JAVA_OPTS=-Xms256m -Xmx256m',
                       '-v', f'{path}:/validation:ro', IMAGE]
            result = subprocess.run(command + ['-f', '/validation/test.conf',
                '--pipeline.workers', '1', '--log.level', 'error'],
                input=''.join(json.dumps(event) + '\n' for event in events),
                capture_output=True, text=True, timeout=120)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            actual = [json.loads(line) for line in result.stdout.splitlines() if line.startswith('{')]
        self.assertEqual(len(actual), len(events))
        for event in actual:
            if event['case'] == 'unrelated':
                self.assertEqual(event['message'], 'Another application')
                self.assertNotIn('log_type', event.get('test_metadata', {}))
                continue
            self.assertEqual(event['test_metadata']['log_type'], 'uitpas::api')
            self.assertEqual(event['test_metadata']['environment'], event['fields']['environment'])
            if event['case'] == 'malformed':
                self.assertEqual(event['message'], 'Unrecognized record')
                self.assertIn('_uitpas_parse_failure', event['tags'])
            else:
                self.assertEqual(event['severity'], event['case'])
                self.assertEqual(event['logger'], 'be.uitpas.Example')
                self.assertEqual(event['@timestamp'], '2026-09-25T11:15:00.991Z')
                self.assertIn('Example.java:42', event['log_message'])
                self.assertNotIn('message', event)
                self.assertNotIn('_uitpas_parse_failure', event.get('tags', []))


if __name__ == '__main__':
    unittest.main()
