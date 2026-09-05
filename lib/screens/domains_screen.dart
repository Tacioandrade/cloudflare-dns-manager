import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../data/api.dart';
import '../data/local_storage.dart';
import 'dns_editor_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

class DomainsScreen extends StatefulWidget {
  const DomainsScreen({super.key});

  @override
  State<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends State<DomainsScreen> {
  static const double _footerHeight = 88;
  static const double _footerActionClearance = 88;

  List<dynamic> _zones = [];
  bool _isLoading = true;
  bool _tokenNotConfigured = false;
  String? _error;
  String _searchQuery = '';
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();
  int _loadId = 0;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final loadId = ++_loadId;
    setState(() {
      _isLoading = true;
      _tokenNotConfigured = false;
      _error = null;
      _zones = [];
    });

    final token = await LocalStorage.getToken();
    if (!mounted || loadId != _loadId) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _tokenNotConfigured = true;
      });
      return;
    }

    try {
      await for (final zone in ApiService.streamZones()) {
        if (!mounted || loadId != _loadId) return;
        setState(() {
          _zones.add(zone);
        });
      }
      if (!mounted || loadId != _loadId) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted || loadId != _loadId) return;
      setState(() {
        _error = context.l10n.text('domainsLoadError', values: {'error': '$e'});
        _isLoading = false;
      });
    }
  }

  Future<void> _openApiTokensPage() async {
    final opened = await launchUrl(
      Uri.parse('https://dash.cloudflare.com/profile/api-tokens'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.text('unableOpenLink'))),
      );
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _loadZones();
  }

  void _logout() async {
    await LocalStorage.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          if (!_isSearching) {
            setState(() {
              _isSearching = true;
            });
          }
          Future.delayed(const Duration(milliseconds: 50), () {
            _searchFocusNode.requestFocus();
          });
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          }
        },
      },
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.l10n.text('searchDomain'),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  )
                : Text(context.l10n.text('domains')),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: _loadZones,
            child: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _zones.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tokenNotConfigured) {
      return _buildTokenTutorial();
    }

    if (_error != null && _zones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null)
          Container(
            width: double.infinity,
            color: AppColors.error.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
            child: Text(
              context.l10n
                  .text('partialDomainsError', values: {'error': _error!}),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        Expanded(child: _buildZonesList()),
      ],
    );
  }

  Widget _buildTokenTutorial() {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final linkStyle = textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.primary,
    );

    Widget step(String number, Widget content) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text('$number.', style: textTheme.bodyLarge),
              ),
              Expanded(child: content),
            ],
          ),
        );

    Widget permission(String resource, String action) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7, right: 10),
                child: Icon(Icons.circle, size: 6),
              ),
              Expanded(
                child: Text(
                  '$resource => $action',
                  style: textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 112),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('tokenTutorialTitle'),
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  step(
                    '1',
                    Text(l10n.text('tokenTutorialLogin'),
                        style: textTheme.bodyLarge),
                  ),
                  step(
                    '2',
                    Text(l10n.text('tokenTutorialOpenSettings'),
                        style: textTheme.bodyLarge),
                  ),
                  step(
                    '3',
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(l10n.text('tokenTutorialPaste'),
                            style: textTheme.bodyLarge),
                        InkWell(
                          key: const ValueKey('cloudflareApiTokenLink'),
                          onTap: _openApiTokensPage,
                          child: Text('Cloudflare API Token', style: linkStyle),
                        ),
                        Text('.', style: textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  step(
                    '4',
                    Text(l10n.text('tokenTutorialTest'),
                        style: textTheme.bodyLarge),
                  ),
                  step(
                    '5',
                    Text(l10n.text('tokenTutorialSave'),
                        style: textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.text('tokenTutorialPermissionsIntro'),
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  permission(
                    l10n.text('tokenPermissionZone'),
                    '${l10n.text('tokenPermissionCachePurge')} => ${l10n.text('tokenPermissionClear')}',
                  ),
                  permission(
                    l10n.text('tokenPermissionZone'),
                    'DNS => ${l10n.text('tokenPermissionEdit')}',
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ElevatedButton.icon(
                      key: const ValueKey('tokenTutorialSettingsButton'),
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.text('configureToken')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZonesList() {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final footer = SizedBox(
      height: _footerHeight + safeBottom,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          _footerActionClearance,
          16 + safeBottom,
        ),
        child: Center(
          child: Text(
            context.l10n.text(
              'availableDomainsCount',
              values: {'count': '${_zones.length}'},
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );

    if (_zones.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadZones,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(child: Text(context.l10n.text('noDomains'))),
            ),
            footer,
          ],
        ),
      );
    }

    final filteredZones = _zones.where((zone) {
      return zone['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadZones,
      child: filteredZones.isEmpty
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child:
                      Center(child: Text(context.l10n.text('noDomainsSearch'))),
                ),
                footer,
              ],
            )
          : ListView.builder(
              itemCount: filteredZones.length + 1,
              itemBuilder: (context, index) {
                if (index == filteredZones.length) {
                  return footer;
                }

                final zone = filteredZones[index];
                final isActive = zone['status'] == 'active';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(zone['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(zone['status']),
                    trailing: Icon(
                      isActive ? Icons.check_circle : Icons.pending,
                      color: isActive ? AppColors.success : Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DnsEditorScreen(
                            zoneId: zone['id'],
                            zoneName: zone['name'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
