import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_storage.dart';

class AccountListResult {
  const AccountListResult({
    required this.accounts,
    required this.usedZoneFallback,
  });

  final List<dynamic> accounts;
  final bool usedZoneFallback;
}

class ApiService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:8081/client/v4'
      : 'https://api.cloudflare.com/client/v4';
  static String? _zoneCreationPermissionToken;
  static bool? _zoneCreationPermission;

  static Future<Map<String, String>> _headers() async {
    final token = await LocalStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Stream<dynamic> streamZones() async* {
    int page = 1;
    bool hasMore = true;
    final headers = await _headers();

    while (hasMore) {
      final response = await http.get(
        Uri.parse('$baseUrl/zones?per_page=50&page=$page'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success']) {
          for (final zone in json['result']) {
            yield zone;
          }
          final resultInfo = json['result_info'];
          if (resultInfo != null && resultInfo['total_pages'] != null) {
            final int totalPages = resultInfo['total_pages'];
            if (page >= totalPages) {
              hasMore = false;
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else {
          throw Exception("Failed to load zones: ${json['errors']}");
        }
      } else {
        throw Exception('Failed to load zones. HTTP ${response.statusCode}');
      }
    }
  }

  static Future<List<dynamic>> listZones() async {
    final zones = <dynamic>[];
    await for (final zone in streamZones()) {
      zones.add(zone);
    }
    return zones;
  }

  static Future<AccountListResult> listAccounts() async {
    Object? membershipsError;
    try {
      final accounts = await _listAccountsFromMemberships();
      if (accounts.isNotEmpty) {
        return AccountListResult(
          accounts: accounts,
          usedZoneFallback: false,
        );
      }
    } catch (error) {
      membershipsError = error;
    }

    final zones = await listZones();
    final accounts = _uniqueSortedAccounts(
      zones.map((zone) => (zone as Map)['account']),
    );
    if (accounts.isEmpty && membershipsError != null) {
      throw membershipsError;
    }
    return AccountListResult(
      accounts: accounts,
      usedZoneFallback: true,
    );
  }

  static Future<List<dynamic>> _listAccountsFromMemberships() async {
    final accountsById = <String, dynamic>{};
    var page = 1;
    var hasMore = true;
    final headers = await _headers();

    while (hasMore) {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/memberships?status=accepted&per_page=50&page=$page',
        ),
        headers: headers,
      );
      final json = _decodeResponse(response, 'carregar contas');
      final memberships = json['result'] as List<dynamic>;
      for (final membership in memberships) {
        final account = (membership as Map)['account'];
        if (account is Map && account['id'] != null) {
          accountsById[account['id'].toString()] = account;
        }
      }

      final resultInfo = json['result_info'];
      final totalCount = resultInfo is Map<String, dynamic>
          ? resultInfo['total_count'] as int?
          : null;
      hasMore = totalCount != null
          ? page * 50 < totalCount
          : memberships.length == 50;
      page++;
    }

    return _sortAccounts(accountsById.values.toList());
  }

  static List<dynamic> _uniqueSortedAccounts(Iterable<dynamic> values) {
    final accountsById = <String, dynamic>{};
    for (final account in values) {
      if (account is Map && account['id'] != null) {
        accountsById[account['id'].toString()] = account;
      }
    }
    return _sortAccounts(accountsById.values.toList());
  }

  static List<dynamic> _sortAccounts(List<dynamic> accounts) {
    accounts.sort(
      (a, b) => a['name'].toString().toLowerCase().compareTo(
            b['name'].toString().toLowerCase(),
          ),
    );
    return accounts;
  }

  static Future<Map<String, dynamic>> createZone({
    required String accountId,
    required String domain,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/zones'),
      headers: await _headers(),
      body: jsonEncode({
        'account': {'id': accountId},
        'name': domain,
        'type': 'full',
      }),
    );
    final json = _decodeResponse(response, 'conectar domínio');
    return Map<String, dynamic>.from(json['result'] as Map);
  }

  static Future<bool> canCreateZones(Map<String, dynamic> existingZone) async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) return false;
    if (_zoneCreationPermissionToken == token &&
        _zoneCreationPermission != null) {
      return _zoneCreationPermission!;
    }

    final account = existingZone['account'];
    final accountId = account is Map ? account['id']?.toString() : null;
    final domain = existingZone['name']?.toString();
    if (accountId == null ||
        accountId.isEmpty ||
        domain == null ||
        domain.isEmpty) {
      return false;
    }

    var allowed = false;
    try {
      // Reusing a zone already present in the account makes this capability
      // probe non-destructive: authorized tokens receive an "already exists"
      // validation error, while unauthorized tokens are rejected first.
      final response = await http.post(
        Uri.parse('$baseUrl/zones'),
        headers: await _headers(),
        body: jsonEncode({
          'account': {'id': accountId},
          'name': domain,
          'type': 'full',
        }),
      );
      final json = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final errors = _formatCloudflareErrors(json).toLowerCase();
      final permissionDenied = errors.contains(
            'com.cloudflare.api.account.zone.create',
          ) ||
          errors.contains('to create zones for the selected account');
      final reachedZoneValidation =
          response.statusCode == 400 || response.statusCode == 409;
      allowed = !permissionDenied && reachedZoneValidation;
    } catch (_) {
      allowed = false;
    }

    _zoneCreationPermissionToken = token;
    _zoneCreationPermission = allowed;
    return allowed;
  }

  static Future<Map<String, dynamic>> getZone(String zoneId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/zones/$zoneId'),
      headers: await _headers(),
    );
    final json = _decodeResponse(response, 'carregar domínio');
    return Map<String, dynamic>.from(json['result'] as Map);
  }

  static Future<Map<String, dynamic>> checkZoneActivation(String zoneId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/zones/$zoneId/activation_check'),
      headers: await _headers(),
    );
    _decodeResponse(response, 'verificar ativação do domínio');
    return getZone(zoneId);
  }

  static Future<List<dynamic>> listDnsRecords(String zoneId) async {
    List<dynamic> allRecords = [];
    int page = 1;
    bool hasMore = true;
    final allowedTypes = await LocalStorage.getDnsTypes();

    while (hasMore) {
      final response = await http.get(
        Uri.parse('$baseUrl/zones/$zoneId/dns_records?per_page=100&page=$page'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success']) {
          final List<dynamic> result = json['result'];
          allRecords
              .addAll(result.where((r) => allowedTypes.contains(r['type'])));
          final resultInfo = json['result_info'];
          if (resultInfo != null && resultInfo['total_pages'] != null) {
            final int totalPages = resultInfo['total_pages'];
            if (page >= totalPages) {
              hasMore = false;
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else {
          throw Exception("Failed to load DNS records: ${json['errors']}");
        }
      } else {
        throw Exception(
            'Failed to load DNS records. HTTP ${response.statusCode}');
      }
    }
    return allRecords;
  }

  static Future<void> createDnsRecord(
      String zoneId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/zones/$zoneId/dns_records'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (!json['success']) {
      throw Exception(
        'Falha ao criar registro: ${_formatCloudflareErrors(json)}',
      );
    }
  }

  static Future<void> updateDnsRecord(
      String zoneId, String recordId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/zones/$zoneId/dns_records/$recordId'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (!json['success']) {
      throw Exception(
        'Falha ao atualizar registro: ${_formatCloudflareErrors(json)}',
      );
    }
  }

  static Future<void> deleteDnsRecord(String zoneId, String recordId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/zones/$zoneId/dns_records/$recordId'),
      headers: await _headers(),
    );
    final json = jsonDecode(response.body);
    if (!json['success']) throw Exception('Failed to delete record');
  }

  static Future<void> purgeCache(String zoneId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/zones/$zoneId/purge_cache'),
      headers: await _headers(),
      body: jsonEncode({'purge_everything': true}),
    );
    final json = jsonDecode(response.body);
    if (!json['success']) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Token sem permissão para limpar cache. Adicione a permissão Cache Purge ao token da Cloudflare.',
        );
      }
      throw Exception('Failed to purge cache: ${json['errors']}');
    }
  }

  static String _formatCloudflareErrors(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.map((error) {
        if (error is Map<String, dynamic>) {
          final code = error['code'];
          final message = error['message'];
          if (code != null && message != null) {
            return '$message (código $code)';
          }
          if (message != null) return message.toString();
        }
        return error.toString();
      }).join('; ');
    }
    return 'erro desconhecido da API Cloudflare';
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
    String operation,
  ) {
    Map<String, dynamic> json;
    try {
      json = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception(
        'Falha ao $operation. HTTP ${response.statusCode}',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        json['success'] != true) {
      throw Exception(
        'Falha ao $operation: ${_formatCloudflareErrors(json)}',
      );
    }
    return json;
  }
}
