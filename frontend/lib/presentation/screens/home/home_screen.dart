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
import '../profile/profile_screen.dart';
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Color(0xFF1A73E8)),
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
                await context
                    .read<NoteProvider>()
                    .permanentDeleteNote(note.id);
                await _refresh();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    } else {
      _openNote(note);
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    if (mounted) {
      navigator.pushAndRemoveUntil(
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
      final match =
          labelProvider.labels.where((l) => l.id == _selectedLabel);
      if (match.isNotEmpty) return match.first.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final labelProvider = context.watch<LabelProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              elevation: 0,
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
              elevation: 0,
              title: const Text(
                '∆nfiniNotes',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.3,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                IconButton(
                  icon: Icon(_isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded),
                  onPressed: () =>
                      setState(() => _isGridView = !_isGridView),
                ),
                PopupMenuButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'labels',
                      child: Row(
                        children: [
                          Icon(Icons.label_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit labels'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            themeProvider.isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(themeProvider.isDark
                              ? 'Light mode'
                              : 'Dark mode'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Logout',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'labels') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LabelScreen()),
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '∆nfiniNotes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your thoughts, organized',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.lightbulb_outlined,
                    label: 'Notes',
                    selected:
                        _selectedIndex == 0 && _selectedLabel == null,
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
                      context
                          .read<NoteProvider>()
                          .fetchNotes(archived: true);
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
                      context
                          .read<NoteProvider>()
                          .fetchNotes(trashed: true);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outlined,
                    label: 'Profile',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  if (labelProvider.labels.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: Text(
                        'LABELS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    ...labelProvider.labels.map((label) => _DrawerItem(
                          icon: Icons.label_outlined,
                          label: label.name,
                          selected: _selectedLabel == label.id,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                              _selectedLabel = label.id;
                            });
                            context
                                .read<NoteProvider>()
                                .fetchNotes(label: label.id);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentSectionTitle.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 15,
                    color: Color(0xFF1A73E8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentSectionTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF1A73E8),
              child: noteProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A73E8),
                      ),
                    )
                  : noteProvider.notes.isEmpty
                      ? _EmptyState(selectedIndex: _selectedIndex)
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
              elevation: 4,
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 28),
            ),
    );
  }

  Widget _buildNotesList(NoteProvider noteProvider) {
    final pinned = noteProvider.pinnedNotes;
    final others = noteProvider.unpinnedNotes;
    final isTrashed = _selectedIndex == 2;

    if (_isGridView) {
      return CustomScrollView(
        slivers: [
          if (pinned.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _SectionLabel(label: 'Pinned'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => NoteCard(
                    note: pinned[i],
                    onTap: () => _openNoteOrShowOptions(pinned[i]),
                    onRefresh: _refresh,
                    isTrashed: isTrashed,
                  ),
                  childCount: pinned.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                child: _SectionLabel(label: 'Others'),
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
                  onRefresh: _refresh,
                  isTrashed: isTrashed,
                ),
                childCount: others.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.85,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pinned.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SectionLabel(label: 'Pinned'),
          ),
          ...pinned.map((n) => NoteCard(
                note: n,
                onTap: () => _openNoteOrShowOptions(n),
                isListView: true,
                onRefresh: _refresh,
                isTrashed: isTrashed,
              )),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SectionLabel(label: 'Others'),
          ),
        ],
        ...others.map((n) => NoteCard(
              note: n,
              onTap: () => _openNoteOrShowOptions(n),
              isListView: true,
              onRefresh: _refresh,
              isTrashed: isTrashed,
            )),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int selectedIndex;
  const _EmptyState({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = selectedIndex == 2
        ? Icons.delete_outlined
        : selectedIndex == 1
            ? Icons.archive_outlined
            : Icons.note_alt_outlined;
    final title = selectedIndex == 2
        ? 'Trash is empty'
        : selectedIndex == 1
            ? 'No archived notes'
            : 'No notes yet';
    final subtitle = selectedIndex == 2
        ? 'Deleted notes appear here'
        : selectedIndex == 1
            ? 'Archived notes appear here'
            : 'Tap + to create your first note';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF1A73E8).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF1A73E8) : null,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? const Color(0xFF1A73E8) : null,
          ),
        ),
        selected: selected,
        selectedTileColor:
            const Color(0xFF1A73E8).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}