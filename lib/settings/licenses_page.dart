import 'package:flexify/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.licensesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(l10n.flexifyMitNotice),
          const SizedBox(height: 16),
          Text(l10n.exerciseDbNotice),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              var version = '';
              try {
                version = (await PackageInfo.fromPlatform()).version;
              } catch (_) {}
              if (!context.mounted) return;
              showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: version,
                applicationLegalese: l10n.flexifyMitNotice,
              );
            },
            child: Text(l10n.openPackageLicenses),
          ),
        ],
      ),
    );
  }
}
