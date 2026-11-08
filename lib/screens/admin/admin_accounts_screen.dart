import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  final _search = TextEditingController();
  late final Stream<List<AppUser>> _stream = AdminService.usersStream();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Dialog controllers are disposed after the close animation finishes.
  void _disposeLater(List<TextEditingController> controllers) {
    Future.delayed(const Duration(milliseconds: 400), () {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  InputDecoration _dec(String label, {String? helper}) => InputDecoration(
        labelText: label,
        helperText: helper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  // ------------------------------------------------------- add / edit
  Future<void> _openForm([AppUser? user]) async {
    final isEdit = user != null;
    final username = TextEditingController(text: user?.username ?? '');
    final fullName = TextEditingController(text: user?.fullName ?? '');
    final contact = TextEditingController(text: user?.contact ?? '');
    final address = TextEditingController(text: user?.address ?? '');
    final password = TextEditingController();
    String? error;
    var saving = false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: Text(isEdit ? 'Edit account' : 'Add account'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: username,
                    enabled: !isEdit,
                    maxLength: Validators.usernameMax,
                    decoration: _dec(
                        isEdit ? 'Username (cannot be changed)' : 'Username'),
                  ),
                  TextField(
                    controller: fullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contact,
                    decoration: _dec('Email or Contact Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: address,
                    maxLines: 2,
                    maxLength: Validators.addressMax,
                    decoration: _dec('Delivery address'),
                  ),
                  if (!isEdit)
                    TextField(
                      controller: password,
                      obscureText: true,
                      maxLength: Validators.passwordMax,
                      decoration: _dec('Password',
                          helper:
                              '8-32 characters, with a letter and a number'),
                    ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  saving ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialog(() {
                        saving = true;
                        error = null;
                      });
                      final result = isEdit
                          ? await AdminService.updateUser(
                              user,
                              fullName: fullName.text,
                              contact: contact.text,
                              address: address.text,
                            )
                          : await AdminService.createUser(
                              username: username.text,
                              fullName: fullName.text,
                              contact: contact.text,
                              address: address.text,
                              password: password.text,
                            );
                      if (result != null) {
                        setDialog(() {
                          error = result;
                          saving = false;
                        });
                        return;
                      }
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );

    _disposeLater([username, fullName, contact, address, password]);
    if (ok == true && mounted) {
      _snack(isEdit ? 'Account updated' : 'Account created');
    }
  }

  // --------------------------------------------------- reset password
  Future<void> _resetPassword(AppUser u) async {
    final password = TextEditingController();
    String? error;
    var saving = false;
    var obscure = true;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: Text('Reset password for ${u.username}'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: password,
                  obscureText: obscure,
                  maxLength: Validators.passwordMax,
                  decoration: _dec('New password',
                          helper:
                              '8-32 characters, with a letter and a number')
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialog(() => obscure = !obscure),
                    ),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  saving ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setDialog(() {
                        saving = true;
                        error = null;
                      });
                      final result =
                          await AdminService.resetPassword(u, password.text);
                      if (result != null) {
                        setDialog(() {
                          error = result;
                          saving = false;
                        });
                        return;
                      }
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );

    _disposeLater([password]);
    if (ok == true && mounted) _snack('Password reset for ${u.username}');
  }

  // ------------------------------------------------------------ delete
  Future<void> _delete(AppUser u) async {
    var alsoListings = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: const Text('Delete account?'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"${u.username}" will no longer be able to log in and '
                    'their cart is removed. Their past orders are kept.'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: alsoListings,
                  onChanged: (v) =>
                      setDialog(() => alsoListings = v ?? false),
                  title: const Text('Also delete their products'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete')),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final error =
        await AdminService.deleteUser(u, deleteListings: alsoListings);
    if (!mounted) return;
    _snack(error ?? 'Account deleted');
  }

  // ------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final me = AuthService().currentUsername;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Accounts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add account'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by username, name, contact, or address',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final q = _query.trim().toLowerCase();
                final list = snapshot.data!
                    .where((u) =>
                        q.isEmpty ||
                        '${u.username} ${u.fullName} ${u.contact} ${u.address}'
                            .toLowerCase()
                            .contains(q))
                    .toList();

                if (list.isEmpty) {
                  return const Center(child: Text('No accounts found.'));
                }

                return LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: c.maxWidth),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: DataTable(
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 72,
                            columns: const [
                              DataColumn(label: Text('Username')),
                              DataColumn(label: Text('Full name')),
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Address')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: [
                              for (final u in list)
                                DataRow(cells: [
                                  DataCell(Row(children: [
                                    Text(u.username,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    if (u.isAdmin) ...[
                                      const SizedBox(width: 8),
                                      const Chip(
                                        label: Text('Admin'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ])),
                                  DataCell(Text(
                                      u.fullName.isEmpty ? '—' : u.fullName)),
                                  DataCell(Text(
                                      u.contact.isEmpty ? '—' : u.contact)),
                                  DataCell(ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 260),
                                    child: Text(
                                        u.address.isEmpty ? '—' : u.address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Edit',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openForm(u),
                                    ),
                                    IconButton(
                                      tooltip: 'Reset password',
                                      icon: const Icon(Icons.lock_reset),
                                      onPressed: () => _resetPassword(u),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: (u.isAdmin ||
                                              u.username == me)
                                          ? null
                                          : () => _delete(u),
                                    ),
                                  ])),
                                ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}