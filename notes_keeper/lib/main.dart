import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NoteKeeperApp());
}

// ─── DATA MODEL ───────────────────────────────────────────────────────────────

class Note {
  final String id;
  String title;
  String body;
  Color color;
  DateTime createdAt;
  bool isDeleted;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.color,
    required this.createdAt,
    this.isDeleted = false,
  });

  Note copyWith({String? title, String? body, Color? color, bool? isDeleted}) =>
      Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        color: color ?? this.color,
        createdAt: createdAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}

// ─── THEME ────────────────────────────────────────────────────────────────────

const List<Color> kNoteColors = [
  Color(0xFF7C6FCD), // lavender purple
  Color(0xFF5B8DEF), // cornflower blue
  Color(0xFF4ECDC4), // teal
  Color(0xFFFF6B9D), // pink
  Color(0xFFFFBE0B), // amber
  Color(0xFF06D6A0), // mint green
  Color(0xFFFF7043), // deep orange
  Color(0xFFAB47BC), // violet
];

// Dark navy palette
const Color kBg = Color(0xFF0D0E1A);
const Color kSurface = Color(0xFF13152A);
const Color kCard = Color(0xFF181A2E);
const Color kCardBorder = Color(0xFF252847);
const Color kAccent = Color(0xFF7C6FCD); // primary purple
const Color kAccent2 = Color(0xFF5B8DEF); // secondary blue
const Color kGreen = Color(0xFF06D6A0);
const Color kRed = Color(0xFFFF6B9D);
const Color kTextPrimary = Color(0xFFECEEFF);
const Color kTextSecondary = Color(0xFF5A5F80);
const Color kDivider = Color(0xFF1F2240);

String _formatDate(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

// ─── GLOBAL STATE ─────────────────────────────────────────────────────────────

class NotesState extends ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Welcome to Memo Keeper!',
      body:
          'Tap the + button below to create your first note. Pick a color, write your ideas, and keep everything organized.',
      color: const Color(0xFF7C6FCD),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Flutter MSE Project',
      body:
          'Notes & Memo Keeper — staggered grid, color picker, soft delete, sort toggle, font-size slider, search.',
      color: const Color(0xFF5B8DEF),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Note(
      id: '3',
      title: 'Project Ideas 💡',
      body:
          'Dark UI with refined accent palette. Staggered grid layout. Smooth page transitions.',
      color: const Color(0xFFAB47BC),
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    Note(
      id: '4',
      title: 'Shopping List 🛒',
      body: 'Milk, bread, eggs, coffee, apples, pasta, olive oil.',
      color: const Color(0xFFFFBE0B),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  bool newestFirst = true;
  String searchQuery = '';
  double fontSize = 14.0;

  List<Note> get activeNotes {
    var list = _notes.where((n) => !n.isDeleted).toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (n) =>
                n.title.toLowerCase().contains(q) ||
                n.body.toLowerCase().contains(q),
          )
          .toList();
    }
    list.sort(
      (a, b) => newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return list;
  }

  List<Note> get trashedNotes => _notes.where((n) => n.isDeleted).toList();

  void addNote(Note n) {
    _notes.add(n);
    notifyListeners();
  }

  void updateNote(Note u) {
    final i = _notes.indexWhere((n) => n.id == u.id);
    if (i != -1) _notes[i] = u;
    notifyListeners();
  }

  void softDelete(String id) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i != -1) _notes[i] = _notes[i].copyWith(isDeleted: true);
    notifyListeners();
  }

  void restore(String id) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i != -1) _notes[i] = _notes[i].copyWith(isDeleted: false);
    notifyListeners();
  }

  void permanentDelete(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void toggleSort() {
    newestFirst = !newestFirst;
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setFontSize(double s) {
    fontSize = s;
    notifyListeners();
  }
}

final notesState = NotesState();

// ─── APP ROOT ─────────────────────────────────────────────────────────────────

class NoteKeeperApp extends StatelessWidget {
  const NoteKeeperApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Memo Keeper',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: kBg,
      colorScheme: ColorScheme.dark(
        primary: kAccent,
        surface: kSurface,
        error: kRed,
      ),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

// ─── HOME SHELL ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  static const _pages = [GalleryScreen(), TrashScreen(), SettingsScreen()];

  void _openEditor([Note? note]) => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, a, __) => EditorScreen(existing: note),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 360),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: notesState,
    builder: (_, __) => Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _idx, children: _pages),
      floatingActionButton: _idx == 0 ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildNavBar(),
    ),
  );

  Widget _buildFab() => Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [kAccent, kAccent2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: kAccent.withOpacity(0.55),
          blurRadius: 22,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _openEditor(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    ),
  );

  // ── 3 PERFECTLY EQUAL NAV TABS ────────────────────────────────────
  Widget _buildNavBar() => Container(
    decoration: BoxDecoration(
      color: kSurface,
      border: Border(top: BorderSide(color: kDivider, width: 1.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 30,
          offset: const Offset(0, -6),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 66,
        child: Row(
          children: [
            _NavTab(
              icon: Icons.sticky_note_2_outlined,
              activeIcon: Icons.sticky_note_2_rounded,
              label: 'Notes',
              selected: _idx == 0,
              onTap: () => setState(() => _idx = 0),
            ),
            _NavTab(
              icon: Icons.delete_outline_rounded,
              activeIcon: Icons.delete_rounded,
              label: 'Trash',
              selected: _idx == 1,
              onTap: () => setState(() => _idx = 1),
            ),
            _NavTab(
              icon: Icons.tune_outlined,
              activeIcon: Icons.tune_rounded,
              label: 'Settings',
              selected: _idx == 2,
              onTap: () => setState(() => _idx = 2),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── NAV TAB — each one is Expanded so all 3 are perfectly equal ───────────────
class _NavTab extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? kAccent.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              selected ? activeIcon : icon,
              color: selected ? kAccent : kTextSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? kAccent : kTextSecondary,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── GALLERY SCREEN ───────────────────────────────────────────────────────────

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: notesState,
    builder: (_, __) {
      final notes = notesState.activeNotes;
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildSortBar(notes.length)),
          if (notes.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            _buildStaggeredGrid(notes),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      );
    },
  );

  SliverAppBar _buildAppBar() => SliverAppBar(
    backgroundColor: kBg,
    floating: true,
    expandedHeight: 92,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kAccent, kAccent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Memo Keeper',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder, width: 1.2),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: notesState.setSearch,
        style: const TextStyle(color: kTextPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search memos…',
          hintStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: kTextSecondary,
            size: 20,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: kTextSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    notesState.setSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    ),
  );

  Widget _buildSortBar(int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kAccent.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.notes_rounded, color: kAccent, size: 13),
              const SizedBox(width: 5),
              Text(
                '$count ${count == 1 ? "memo" : "memos"}',
                style: const TextStyle(
                  color: kAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: notesState.toggleSort,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCardBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(
                  notesState.newestFirst
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: kAccent,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  notesState.newestFirst ? 'Newest' : 'Oldest',
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── STAGGERED GRID — right column offset for natural stagger ─────
  Widget _buildStaggeredGrid(List<Note> notes) {
    final left = <Note>[], right = <Note>[];
    for (var i = 0; i < notes.length; i++) {
      (i % 2 == 0 ? left : right).add(notes[i]);
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: left
                    .map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(note: n),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30), // stagger offset
                  ...right.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NoteCard(note: n),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kAccent.withOpacity(0.2), kAccent2.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: kAccent.withOpacity(0.3), width: 1.5),
          ),
          child: const Icon(Icons.edit_note_rounded, color: kAccent, size: 42),
        ),
        const SizedBox(height: 20),
        const Text(
          'No memos yet',
          style: TextStyle(
            color: kTextPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap + below to write your first note',
          style: TextStyle(color: kTextSecondary, fontSize: 13),
        ),
      ],
    ),
  );
}

// ─── NOTE CARD ────────────────────────────────────────────────────────────────

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => EditorScreen(existing: note),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    ),
    onLongPress: () => _showOptions(context),
    child: Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: note.color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: note.color.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: note.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (note.title.isNotEmpty && note.body.isNotEmpty)
                  const SizedBox(height: 6),
                if (note.body.isNotEmpty)
                  AnimatedBuilder(
                    animation: notesState,
                    builder: (_, __) => Text(
                      note.body,
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: notesState.fontSize - 1.5,
                        height: 1.55,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: note.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(note.createdAt),
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showOptions(context),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: kTextSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _showOptions(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    backgroundColor: kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: note.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: kDivider, height: 1),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.edit_rounded,
            label: 'Edit Note',
            color: kAccent,
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => EditorScreen(existing: note)),
              );
            },
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Move to Trash',
            color: kRed,
            onTap: () {
              notesState.softDelete(note.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  backgroundColor: kCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: kRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Moved to trash',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          notesState.restore(note.id);
                          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                        },
                        child: const Text(
                          'Undo',
                          style: TextStyle(
                            color: kAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    leading: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(
      label,
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

// ─── EDITOR SCREEN ────────────────────────────────────────────────────────────

class EditorScreen extends StatefulWidget {
  final Note? existing;
  const EditorScreen({super.key, this.existing});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleCtrl, _bodyCtrl;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existing?.body ?? '');
    _selectedColor = widget.existing?.color ?? kNoteColors[0];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final t = _titleCtrl.text.trim(), b = _bodyCtrl.text.trim();
    if (t.isEmpty && b.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (widget.existing != null) {
      notesState.updateNote(
        widget.existing!.copyWith(title: t, body: b, color: _selectedColor),
      );
    } else {
      notesState.addNote(
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: t,
          body: b,
          color: _selectedColor,
          createdAt: DateTime.now(),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: kTextPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Icon(
                widget.existing != null
                    ? Icons.edit_document
                    : Icons.note_add_rounded,
                color: _selectedColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.existing != null ? 'Edit Memo' : 'New Memo',
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: _save,
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kAccent, kAccent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _lbl(Icons.palette_outlined, 'NOTE COLOR'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kNoteColors.length,
                    itemBuilder: (_, i) {
                      final c = kNoteColors[i];
                      final sel = c == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: sel ? 46 : 36,
                          height: sel ? 46 : 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: c.withOpacity(0.6),
                                      blurRadius: 14,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                _lbl(Icons.title_rounded, 'TITLE'),
                const SizedBox(height: 8),
                _box(
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter title…',
                      hintStyle: TextStyle(color: kTextSecondary, fontSize: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _lbl(Icons.article_outlined, 'MEMO'),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: notesState,
                      builder: (_, __) => Text(
                        'Font ${notesState.fontSize.toInt()}px',
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _box(
                  AnimatedBuilder(
                    animation: notesState,
                    builder: (_, __) => TextField(
                      controller: _bodyCtrl,
                      maxLines: null,
                      minLines: 12,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: notesState.fontSize,
                        height: 1.65,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write your memo here…',
                        hintStyle: TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _lbl(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: kTextSecondary, size: 14),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(
          color: kTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      ),
    ],
  );

  Widget _box(Widget child) => Container(
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _selectedColor.withOpacity(0.45), width: 1.5),
    ),
    child: child,
  );
}

// ─── TRASH SCREEN ─────────────────────────────────────────────────────────────

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: notesState,
    builder: (_, __) {
      final trash = notesState.trashedNotes;
      return Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.delete_rounded, color: kRed, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Trash',
                style: TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: [
            if (trash.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  for (final n in List.from(trash))
                    notesState.permanentDelete(n.id);
                },
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: kRed,
                  size: 18,
                ),
                label: const Text(
                  'Empty',
                  style: TextStyle(color: kRed, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        body: trash.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: kRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kRed.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: kRed,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Trash is empty',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Deleted notes appear here',
                      style: TextStyle(color: kTextSecondary, fontSize: 13),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kRed.withOpacity(0.22)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: kRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${trash.length} ${trash.length == 1 ? "note" : "notes"} in trash — restore or delete permanently.',
                            style: const TextStyle(
                              color: kRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trash.length,
                      itemBuilder: (_, i) => _TrashCard(note: trash[i]),
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

class _TrashCard extends StatelessWidget {
  final Note note;
  const _TrashCard({required this.note});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kCardBorder, width: 1.2),
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 52,
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? '(No title)' : note.title,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.body.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  note.body,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 5),
              Text(
                _formatDate(note.createdAt),
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            _ActionBtn(
              icon: Icons.restore_from_trash_rounded,
              color: kGreen,
              tooltip: 'Restore',
              onTap: () => notesState.restore(note.id),
            ),
            const SizedBox(height: 6),
            _ActionBtn(
              icon: Icons.delete_forever_rounded,
              color: kRed,
              tooltip: 'Delete forever',
              onTap: () => notesState.permanentDelete(note.id),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    ),
  );
}

// ─── SETTINGS SCREEN ──────────────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: notesState,
    builder: (_, __) => Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kAccent2.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.tune_rounded, color: kAccent2, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Settings',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          _Sec('READING'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SIcon(icon: Icons.format_size_rounded, color: kAccent),
                    const SizedBox(width: 12),
                    const Text(
                      'Font Size',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${notesState.fontSize.toInt()} px',
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'A',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: kAccent,
                          inactiveTrackColor: kAccent.withOpacity(0.18),
                          thumbColor: kAccent,
                          overlayColor: kAccent.withOpacity(0.15),
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: notesState.fontSize,
                          min: 11,
                          max: 22,
                          divisions: 11,
                          onChanged: notesState.setFontSize,
                        ),
                      ),
                    ),
                    const Text(
                      'A',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kDivider),
                  ),
                  child: Text(
                    'Preview: The quick brown fox jumps over the lazy dog.',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: notesState.fontSize,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _Sec('DISPLAY'),
          _Card(
            child: Row(
              children: [
                _SIcon(icon: Icons.swap_vert_rounded, color: kAccent2),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort Order',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Toggle newest & oldest first',
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: notesState.toggleSort,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kAccent2.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kAccent2.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          notesState.newestFirst
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: kAccent2,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notesState.newestFirst ? 'Newest' : 'Oldest',
                          style: const TextStyle(
                            color: kAccent2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          _Sec('STATISTICS'),
          _Card(
            child: Column(
              children: [
                _StatRow(
                  icon: Icons.sticky_note_2_rounded,
                  color: kAccent,
                  label: 'Active Notes',
                  value: '${notesState.activeNotes.length}',
                ),
                Divider(color: kDivider, height: 22),
                _StatRow(
                  icon: Icons.delete_rounded,
                  color: kRed,
                  label: 'In Trash',
                  value: '${notesState.trashedNotes.length}',
                ),
                Divider(color: kDivider, height: 22),
                _StatRow(
                  icon: Icons.format_size_rounded,
                  color: kGreen,
                  label: 'Font Size',
                  value: '${notesState.fontSize.toInt()} px',
                ),
              ],
            ),
          ),

          _Sec('ABOUT'),
          _Card(
            child: const Column(
              children: [
                _ARow(
                  icon: Icons.app_shortcut_rounded,
                  label: 'App',
                  value: 'Memo Keeper',
                ),
                Divider(color: kDivider, height: 22),
                _ARow(
                  icon: Icons.tag_rounded,
                  label: 'Version',
                  value: '1.0.0',
                ),
                Divider(color: kDivider, height: 22),
                _ARow(
                  icon: Icons.school_rounded,
                  label: 'Project',
                  value: 'MSE – Q.19',
                ),
                Divider(color: kDivider, height: 22),
                _ARow(
                  icon: Icons.build_rounded,
                  label: 'Built With',
                  value: 'Flutter',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Sec extends StatelessWidget {
  final String label;
  const _Sec(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: kTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kCardBorder, width: 1.2),
    ),
    child: child,
  );
}

class _SIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withOpacity(0.14),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          color: kTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _ARow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ARow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: kTextSecondary, size: 17),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          color: kTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
