import 'dart:convert';

class DnsRecordValidator {
  static bool isProxiableType(String type) {
    return {'A', 'AAAA', 'CNAME'}.contains(type.trim().toUpperCase());
  }

  static String? validateContent({
    required String type,
    required String content,
  }) {
    final normalizedType = type.trim().toUpperCase();
    final normalizedContent = content.trim();

    if (normalizedContent.isEmpty) {
      return 'O conteúdo do registro não pode ser vazio.';
    }

    switch (normalizedType) {
      case 'A':
        return _isValidIpv4(normalizedContent)
            ? null
            : 'Registro A exige um IPv4 válido.';
      case 'AAAA':
        return _isValidIpv6(normalizedContent)
            ? null
            : 'Registro AAAA exige um IPv6 válido.';
      case 'CNAME':
        return _isValidDomainName(normalizedContent)
            ? null
            : 'Registro CNAME exige um domínio válido.';
      case 'MX':
        return _isValidDomainName(normalizedContent)
            ? null
            : 'Registro MX exige um domínio válido.';
      case 'NS':
        return _isValidDomainName(normalizedContent)
            ? null
            : 'Registro NS exige um domínio válido.';
      case 'TXT':
        return null;
      default:
        return null;
    }
  }

  /// Validates a required uint16 field (0-65535) shared by MX priority and
  /// SRV priority/weight/port.
  static String? validateUint16Field({
    required String fieldLabel,
    required String value,
  }) {
    return _isValidUint16(value.trim())
        ? null
        : '$fieldLabel deve ser um número entre 0 e 65535.';
  }

  /// Validates a SRV service or protocol label (e.g. "_sip", "_tcp").
  /// The leading underscore is optional here; it is normalized before
  /// being sent to the API.
  static String? validateSrvLabel({
    required String fieldLabel,
    required String value,
  }) {
    return _isValidSrvLabel(value)
        ? null
        : '$fieldLabel inválido. Use letras, números e hífen (ex.: sip, tcp).';
  }

  /// Validates the SRV target, which must be a valid hostname.
  static String? validateSrvTarget(String value) {
    return _isValidDomainName(value.trim())
        ? null
        : 'Registro SRV exige um domínio de destino válido.';
  }

  static bool isDuplicate({
    required Iterable<dynamic> records,
    required String type,
    required String name,
    required String content,
  }) {
    final normalizedType = type.trim().toUpperCase();
    final normalizedName = _normalizeDnsName(name);
    final normalizedContent = _normalizeContent(normalizedType, content);

    return records.any((record) {
      if (record is! Map) return false;

      final recordType = '${record['type']}'.trim().toUpperCase();
      final recordName = _normalizeDnsName('${record['name']}');
      final recordContent =
          _normalizeContent(recordType, '${record['content']}');

      return recordType == normalizedType &&
          recordName == normalizedName &&
          recordContent == normalizedContent;
    });
  }

  static String _normalizeDnsName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.endsWith('.')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  static String _normalizeContent(String type, String value) {
    final normalized = value.trim();
    if ({'CNAME', 'MX', 'NS'}.contains(type)) {
      return _normalizeDnsName(normalized);
    }
    if (type == 'SRV') {
      final parts = normalized.split(RegExp(r'\s+'));
      // Cloudflare stores SRV content as "weight port target"; priority is
      // tracked separately in the top-level priority/data fields.
      if (parts.length == 3) {
        return '${parts[0]} ${parts[1]} ${_normalizeDnsName(parts[2])}';
      }
      return normalized.toLowerCase();
    }
    return normalized;
  }

  static bool _isValidIpv4(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      if (part.isEmpty) return false;
      if (part.length > 1 && part.startsWith('0')) return false;
      if (!RegExp(r'^\d+$').hasMatch(part)) return false;

      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return false;
    }

    return true;
  }

  static bool _isValidIpv6(String value) {
    try {
      Uri.parseIPv6Address(value);
      return true;
    } on FormatException {
      return false;
    }
  }

  static bool _isValidDomainName(String value) {
    var domain = value.trim().toLowerCase();
    if (domain.endsWith('.')) {
      domain = domain.substring(0, domain.length - 1);
    }

    if (domain.isEmpty ||
        utf8.encode(domain).length > 253 ||
        !domain.contains('.')) {
      return false;
    }

    if (_isValidIpv4(domain) || _isValidIpv6(domain)) {
      return false;
    }

    final labels = domain.split('.');
    for (final label in labels) {
      // DNS labels are not restricted to the hostname LDH character set.
      // Cloudflare accepts underscores and other DNS-valid octets.
      if (label.isEmpty || utf8.encode(label).length > 63) return false;
    }

    return true;
  }

  static bool _isValidSrvLabel(String value) {
    final normalized = value.trim();
    final label =
        normalized.startsWith('_') ? normalized.substring(1) : normalized;
    return label.isNotEmpty &&
        RegExp(r'^[a-zA-Z0-9-]{1,63}$').hasMatch(label);
  }

  static bool _isValidUint16(String value) {
    if (!RegExp(r'^\d+$').hasMatch(value)) return false;
    final number = int.tryParse(value);
    return number != null && number >= 0 && number <= 65535;
  }
}
