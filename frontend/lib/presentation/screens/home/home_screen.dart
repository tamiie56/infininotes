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

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final labelProvider = context.watch<LabelProvider>();

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
                    const PopupMenuItem(value: 'labels', child: Text('Edit labels')),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                  onSelected: (value) {
                    if (value == 'labels') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelScreen()));
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
              child: Text('∆nfiniNotes', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outlined),
              title: const Text('Notes'),
              selected: _selectedIndex == 0 && _selectedLabel == null,
              onTap: () {
                setState(() { _selectedIndex = 0; _selectedLabel = null; });
                context.read<NoteProvider>().fetchNotes();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() { _selectedIndex = 1; _selectedLabel = null; });
                context.read<NoteProvider>().fetchNotes(archived: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outlined),
              title: const Text('Trash'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() { _selectedIndex = 2; _selectedLabel = null; });
                context.read<NoteProvider>().fetchNotes(trashed: true);
                Navigator.pop(context);
              },
            ),
            if (labelProvider.labels.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Labels', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              ...labelProvider.labels.map((label) => ListTile(
                leading: const Icon(Icons.label_outlined),
                title: Text(label.name),
                selected: _selectedLabel == label.id,
                onTap: () {
                  setState(() { _selectedIndex = 0; _selectedLabel = label.id; });
                  context.read<NoteProvider>().fetchNotes(label: label.id);
                  Navigator.pop(context);
                },
              )),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: noteProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : noteProvider.notes.isEmpty
                ? const Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notes yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ))
                : _buildNotesList(noteProvider),
      ),
      floatingActionButton: FloatingActionButton(
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
                child: Text('Pinned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => NoteCard(note: pinned[i], onTap: () => _openNote(pinned[i])),
                  childCount: pinned.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 0.85,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => NoteCard(note: others[i], onTap: () => _openNote(others[i])),
                childCount: others.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 0.85,
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
            child: Text('Pinned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          ...pinned.map((n) => NoteCard(note: n, onTap: () => _openNote(n), isListView: true)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
        ],
        ...others.map((n) => NoteCard(note: n, onTap: () => _openNote(n), isListView: true)),
      ],
    );
  }
}