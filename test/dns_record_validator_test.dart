import 'package:cloudflare_dns/data/dns_record_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DnsRecordValidator', () {
    test('identifies proxiable record types', () {
      expect(DnsRecordValidator.isProxiableType('A'), isTrue);
      expect(DnsRecordValidator.isProxiableType('AAAA'), isTrue);
      expect(DnsRecordValidator.isProxiableType('CNAME'), isTrue);
      expect(DnsRecordValidator.isProxiableType('TXT'), isFalse);
      expect(DnsRecordValidator.isProxiableType('MX'), isFalse);
      expect(DnsRecordValidator.isProxiableType('NS'), isFalse);
      expect(DnsRecordValidator.isProxiableType('SRV'), isFalse);
    });

    test('validates A record content as IPv4', () {
      expect(
        DnsRecordValidator.validateContent(type: 'A', content: '192.168.0.1'),
        isNull,
      );
      expect(
        DnsRecordValidator.validateContent(type: 'A', content: '999.1.1.1'),
        isNotNull,
      );
      expect(
        DnsRecordValidator.validateContent(type: 'A', content: '2001:db8::1'),
        isNotNull,
      );
    });

    test('validates AAAA record content as IPv6', () {
      expect(
        DnsRecordValidator.validateContent(
            type: 'AAAA', content: '2001:db8::1'),
        isNull,
      );
      expect(
        DnsRecordValidator.validateContent(
            type: 'AAAA', content: '192.168.0.1'),
        isNotNull,
      );
    });

    test('validates CNAME, MX, and NS record content as DNS names', () {
      for (final type in ['CNAME', 'MX', 'NS']) {
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: 'target.example',
          ),
          isNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: 'target.example.',
          ),
          isNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: '_service._tcp.example',
          ),
          isNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: '-edge-.example',
          ),
          isNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: 'serviço.example',
          ),
          isNull,
        );
        expect(
          DnsRecordValidator.validateContent(type: type, content: 'localhost'),
          isNotNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: '192.168.0.1',
          ),
          isNotNull,
        );
        expect(
          DnsRecordValidator.validateContent(
            type: type,
            content: '2001:db8::1',
          ),
          isNotNull,
        );
      }
    });

    test('rejects invalid DNS name sizes and empty labels', () {
      expect(
        DnsRecordValidator.validateContent(
          type: 'CNAME',
          content: 'target..example',
        ),
        isNotNull,
      );
      expect(
        DnsRecordValidator.validateContent(
          type: 'CNAME',
          content: '${'a' * 64}.example',
        ),
        isNotNull,
      );
    });

    test('accepts non-empty TXT record content', () {
      expect(
        DnsRecordValidator.validateContent(
          type: 'TXT',
          content: 'v=spf1 include:example.com ~all',
        ),
        isNull,
      );
      expect(
        DnsRecordValidator.validateContent(type: 'TXT', content: '   '),
        isNotNull,
      );
    });

    test('wraps unquoted TXT content in double quotes', () {
      expect(
        DnsRecordValidator.normalizeTxtContent(
            'v=spf1 include:example.com ~all'),
        '"v=spf1 include:example.com ~all"',
      );
      expect(
        DnsRecordValidator.normalizeTxtContent('  unquoted value  '),
        '"unquoted value"',
      );
    });

    test('leaves already-quoted TXT content untouched', () {
      expect(
        DnsRecordValidator.normalizeTxtContent('"already quoted"'),
        '"already quoted"',
      );
      expect(
        DnsRecordValidator.normalizeTxtContent('"first" "second"'),
        '"first" "second"',
      );
    });

    test('validates MX and SRV uint16 fields (priority/weight/port)', () {
      expect(
        DnsRecordValidator.validateUint16Field(
          fieldLabel: 'Priority',
          value: '10',
        ),
        isNull,
      );
      expect(
        DnsRecordValidator.validateUint16Field(
          fieldLabel: 'Priority',
          value: '70000',
        ),
        isNotNull,
      );
      expect(
        DnsRecordValidator.validateUint16Field(
          fieldLabel: 'Port',
          value: '-1',
        ),
        isNotNull,
      );
      expect(
        DnsRecordValidator.validateUint16Field(
          fieldLabel: 'Weight',
          value: 'abc',
        ),
        isNotNull,
      );
    });

    test('validates SRV service/protocol labels', () {
      expect(
        DnsRecordValidator.validateSrvLabel(
          fieldLabel: 'Service',
          value: '_sip',
        ),
        isNull,
      );
      expect(
        DnsRecordValidator.validateSrvLabel(
          fieldLabel: 'Service',
          value: 'sip',
        ),
        isNull,
      );
      expect(
        DnsRecordValidator.validateSrvLabel(
          fieldLabel: 'Service',
          value: '',
        ),
        isNotNull,
      );
      expect(
        DnsRecordValidator.validateSrvLabel(
          fieldLabel: 'Protocol',
          value: '_tcp.example',
        ),
        isNotNull,
      );
    });

    test('validates SRV target as a DNS name', () {
      expect(
        DnsRecordValidator.validateSrvTarget('service.example'),
        isNull,
      );
      expect(
        DnsRecordValidator.validateSrvTarget('not a domain'),
        isNotNull,
      );
    });

    test('detects duplicate DNS records by type, name, and content', () {
      final records = [
        {
          'type': 'CNAME',
          'name': 'WWW.Example.com',
          'content': 'Target.Example.com.',
        },
        {
          'type': 'TXT',
          'name': 'example.com',
          'content': 'Verification=AbC',
        },
      ];

      expect(
        DnsRecordValidator.isDuplicate(
          records: records,
          type: 'cname',
          name: 'www.example.com.',
          content: 'target.example.com',
        ),
        isTrue,
      );
      expect(
        DnsRecordValidator.isDuplicate(
          records: records,
          type: 'CNAME',
          name: 'www.example.com',
          content: 'other.example.com',
        ),
        isFalse,
      );
      expect(
        DnsRecordValidator.isDuplicate(
          records: records,
          type: 'TXT',
          name: 'example.com',
          content: 'Verification=abc',
        ),
        isFalse,
      );
    });
  });
}
