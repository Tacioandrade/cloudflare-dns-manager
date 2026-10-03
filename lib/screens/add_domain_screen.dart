import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../data/api.dart';
import '../l10n/app_localizations.dart';
import '../widgets/name_servers_card.dart';

class AccountSelectionScreen extends StatefulWidget {
  const AccountSelectionScreen({
    super.key,
    this.accountsLoader,
  });

  final Future<AccountListResult> Function()? accountsLoader;

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  late Future<AccountListResult> _accountsFuture;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _accountsFuture = _loadAccounts();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<AccountListResult> _loadAccounts() {
    return widget.accountsLoader?.call() ?? ApiService.listAccounts();
  }

  void _retry() {
    setState(() => _accountsFuture = _loadAccounts());
  }

  Future<void> _selectAccount(Map<String, dynamic> account) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ConnectDomainScreen(account: account),
      ),
    );
    if (created == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          if (!_isSearching) setState(() => _isSearching = true);
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) _searchFocusNode.requestFocus();
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
                    key: const ValueKey('accountSearchField'),
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.l10n.text('searchAccount'),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  )
                : Text(context.l10n.text('selectAccount')),
            actions: [
              IconButton(
                key: const ValueKey('searchAccountButton'),
                tooltip: context.l10n.text('searchAccount'),
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchQuery = '';
                  });
                  if (_isSearching) {
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) _searchFocusNode.requestFocus();
                    });
                  }
                },
              ),
            ],
          ),
          body: FutureBuilder<AccountListResult>(
            future: _accountsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(
                  message: context.l10n.text(
                    'accountsLoadError',
                    values: {'error': '${snapshot.error}'},
                  ),
                  onRetry: _retry,
                );
              }
              return _buildAccounts(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAccounts(AccountListResult result) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final noticeBackground = isDark
        ? Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.18),
            theme.colorScheme.surface,
          )
        : theme.colorScheme.secondaryContainer;
    final noticeForeground = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSecondaryContainer;
    final query = _searchQuery.trim().toLowerCase();
    final accounts = result.accounts.where((account) {
      final map = account as Map;
      return map['name'].toString().toLowerCase().contains(query) ||
          map['id'].toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        if (result.usedZoneFallback)
          Container(
            key: const ValueKey('limitedAccountsNotice'),
            width: double.infinity,
            color: noticeBackground,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: noticeForeground),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.text('limitedAccounts'),
                    style: TextStyle(color: noticeForeground),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: accounts.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.text(
                      query.isEmpty ? 'noAccounts' : 'noAccountsSearch',
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = Map<String, dynamic>.from(
                      accounts[index] as Map,
                    );
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.account_circle_outlined),
                        title: Text(account['name']?.toString() ?? ''),
                        subtitle: Text(account['id']?.toString() ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectAccount(account),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class ConnectDomainScreen extends StatefulWidget {
  const ConnectDomainScreen({
    super.key,
    required this.account,
  });

  final Map<String, dynamic> account;

  @override
  State<ConnectDomainScreen> createState() => _ConnectDomainScreenState();
}

class _ConnectDomainScreenState extends State<ConnectDomainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  Map<String, dynamic>? _createdZone;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  String? _validateDomain(String? value) {
    final domain = (value ?? '').trim().toLowerCase();
    if (domain.isEmpty) return context.l10n.text('domainRequired');
    if (domain.length > 253 ||
        domain.startsWith('.') ||
        domain.endsWith('.') ||
        !domain.contains('.')) {
      return context.l10n.text('invalidDomain');
    }
    final labels = domain.split('.');
    final validLabel = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$');
    if (labels.any((label) => !validLabel.hasMatch(label))) {
      return context.l10n.text('invalidDomain');
    }
    return null;
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final zone = await ApiService.createZone(
        accountId: widget.account['id'].toString(),
        domain: _domainController.text.trim().toLowerCase(),
      );
      if (!mounted) return;
      setState(() => _createdZone = zone);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.text('connectDomain'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _createdZone == null ? _buildDomainForm() : _buildDnsStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildDomainForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.account['name']?.toString() ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.text('connectDomainDescription')),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('connectDomainField'),
            controller: _domainController,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: context.l10n.text('domainName'),
              hintText: 'example.com',
              border: const OutlineInputBorder(),
            ),
            validator: _validateDomain,
            onFieldSubmitted: (_) {
              if (!_isSubmitting) _connect();
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.text(
                'connectDomainError',
                values: {'error': _error!},
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const ValueKey('connectDomainContinue'),
            onPressed: _isSubmitting ? null : _connect,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward),
            label: Text(context.l10n.text('continueAction')),
          ),
        ],
      ),
    );
  }

  Widget _buildDnsStep() {
    final nameServers = ((_createdZone!['name_servers'] as List?) ?? const [])
        .map((value) => value.toString())
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.swap_horiz,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.text('changeNameServersTitle'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.text(
            'changeNameServersDescription',
            values: {'domain': _createdZone!['name'].toString()},
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        NameServersCard(nameServers: nameServers),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const ValueKey('finishDomainConnection'),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.arrow_forward),
          label: Text(context.l10n.text('finish')),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}
