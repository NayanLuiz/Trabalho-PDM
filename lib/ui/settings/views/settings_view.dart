import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showConfigurePinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Configurar PIN Local'),
          content: TextField(
            controller: pinCtrl,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Novo PIN (4 a 6 dígitos)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final pin = pinCtrl.text.trim();
                if (pin.length >= 4) {
                  context.read<SettingsViewModel>().configurePin(pin);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Salvar PIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final userId = authVm.currentUser?.uid ?? 'local_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações & Segurança', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Aparência', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Tema Automático (Sistema)'),
                  value: ThemeMode.system,
                  groupValue: settingsVm.themeMode,
                  onChanged: (mode) => settingsVm.setThemeMode(mode!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Tema Claro'),
                  value: ThemeMode.light,
                  groupValue: settingsVm.themeMode,
                  onChanged: (mode) => settingsVm.setThemeMode(mode!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Tema Escuro (Dark Mode)'),
                  value: ThemeMode.dark,
                  groupValue: settingsVm.themeMode,
                  onChanged: (mode) => settingsVm.setThemeMode(mode!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Segurança e Acesso', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Bloqueio por Biometria'),
                  subtitle: const Text('Exigir digital/face ao abrir o app'),
                  value: settingsVm.biometricsEnabled,
                  onChanged: (val) => settingsVm.setBiometricsEnabled(val),
                ),
                ListTile(
                  leading: const Icon(Icons.pin),
                  title: const Text('Configurar PIN Numérico'),
                  subtitle: Text(settingsVm.hasPin ? 'PIN já cadastrado' : 'Nenhum PIN ativo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showConfigurePinDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_clock),
                  title: const Text('Bloquear Agora'),
                  onTap: () => authVm.lockApp(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Sincronização na Nuvem', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Sincronizar com Firestore'),
              subtitle: Text(settingsVm.isSyncing ? 'Sincronizando...' : 'Offline-first ativo'),
              trailing: settingsVm.isSyncing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync),
              onTap: settingsVm.isSyncing ? null : () => settingsVm.triggerCloudSync(userId),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFFFE4E6),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFE11D48)),
              title: const Text('Encerrar Sessão', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
              onTap: () => authVm.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

