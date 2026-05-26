import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/note_provider.dart';
import '../../../data/providers/label_provider.dart';
import '../../../data/models/note_model.dart';
import '../../widgets/note_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../note/note_edit_screen.dart';
import '../label/label_screen.dart';
import '../auth/login_screen.dart';
import '../../../data/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedLabel;
  bool _isGridView = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().fetchNotes();
      context.read<LabelProvider>().fetchLabels();
    });
  }

  Future<void> _refresh() async {
    await context.read<NoteProvider>().fetchNotes(
      label: _selectedLabel,
      archived: _selectedIndex == 1,
      trashed: _selectedIndex == 2,
    );
  }

  void _openNote([NoteModel? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)),
    ).then((_) => _refresh());
  }

  void _openNoteOrShowOptions(NoteModel note) {
    if (_selectedIndex == 2) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final sheetBg = isDark ? const Color(0xFF2D2E30) : Colors.white;
      showModalBottomSheet(
        context: context,
        backgroundColor: sheetBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<NoteProvider>().restoreNote(note.id);
                await _refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete permanently',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await context.read<NoteProvider>().permanentDeleteNote(note.id);
                await _refresh();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    } else {
      _openNote(note);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String get _currentSectionTitle {
    if (_selectedIndex == 1) return 'Archive';
    if (_selectedIndex == 2) return 'Trash';
    if (_selectedLabel != null) {
      final labelProvider = context.read<LabelProvider>();
      final match = labelProvider.labels.where((l) => l.id == _selectedLabel);
      if (match.isNotEmpty) return match.first.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final labelProvider = context.watch<LabelProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _isSearching = false);
                  context.read<NoteProvider>().fetchNotes();
                },
              ),
              title: SearchBarWidget(
                onChanged: (query) {
                  context.read<NoteProvider>().fetchNotes(search: query);
                },
              ),
            )
          : AppBar(
              title: const Text('∆nfiniNotes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'labels',
                      child: Text('Edit labels'),
                    ),
                    PopupMenuItem(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            themeProvider.isDark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            themeProvider.isDark ? 'Light mode' : 'Dark mode',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                  onSelected: (value) {
                    if (value == 'labels') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LabelScreen()),
                      );
                    } else if (value == 'theme') {
                      context.read<ThemeProvider>().toggleTheme();
                    } else if (value == 'logout') {
                      _logout();
                    }
                  },
                ),
              ],
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1A73E8)),
              child: Text(
                '∆nfiniNotes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.lightbulb_outlined,
              label: 'Notes',
              selected: _selectedIndex == 0 && _selectedLabel == null,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  _selectedLabel = null;
                });
                context.read<NoteProvider>().fetchNotes();
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.archive_outlined,
              label: 'Archive',
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  _selectedLabel = null;
                });
                context.read<NoteProvider>().fetchNotes(archived: true);
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.delete_outlined,
              label: 'Trash',
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  _selectedLabel = null;
                });
                context.read<NoteProvider>().fetchNotes(trashed: true);
                Navigator.pop(context);
              },
            ),
            if (labelProvider.labels.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Labels',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              ...labelProvider.labels.map(
                (label) => _DrawerItem(
                  icon: Icons.label_outlined,
                  label: label.name,
                  selected: _selectedLabel == label.id,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                      _selectedLabel = label.id;
                    });
                    context.read<NoteProvider>().fetchNotes(label: label.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentSectionTitle.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
              child: Text(
                _currentSectionTitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: noteProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : noteProvider.notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedIndex == 2
                                ? Icons.delete_outlined
                                : Icons.lightbulb_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedIndex == 2
                                ? 'Trash is empty'
                                : _selectedIndex == 1
                                ? 'No archived notes'
                                : 'No notes yet',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildNotesList(noteProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton(
              onPressed: () => _openNote(),
              backgroundColor: const Color(0xFF1A73E8),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildNotesList(NoteProvider noteProvider) {
    final pinned = noteProvider.pinnedNotes;
    final others = noteProvider.unpinnedNotes;

    if (_isGridView) {
      return CustomScrollView(
        slivers: [
          if (pinned.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Pinned',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => NoteCard(
                    note: pinned[i],
                    onTap: () => _openNoteOrShowOptions(pinned[i]),
                  ),
                  childCount: pinned.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.85,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Others',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => NoteCard(
                  note: others[i],
                  onTap: () => _openNoteOrShowOptions(others[i]),
                ),
                childCount: others.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.85,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        if (pinned.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Pinned',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ...pinned.map(
            (n) => NoteCard(
              note: n,
              onTap: () => _openNoteOrShowOptions(n),
              isListView: true,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Others',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ],
        ...others.map(
          (n) => NoteCard(
            note: n,
            onTap: () => _openNoteOrShowOptions(n),
            isListView: true,
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      selectedTileColor: const Color(0xFF1A73E8).withValues(alpha: 0.15),
      selectedColor: const Color(0xFF1A73E8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      onTap: onTap,
    );
  }
}
