import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bg = Color(0xFF080A12);
const panel = Color(0xFF141A29);
const panel2 = Color(0xFF1D2538);
const violet = Color(0xFF8B5CF6);
const cyan = Color(0xFF39D5E8);
const supabaseUrl = 'https://evaammherpizsntcbzbf.supabase.co';
const supabaseKey = 'sb_publishable_ZYPPNKKdKoi2-_gMiIl-cw_nJ87SQCZ';
final db = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(const PromptGoApp());
}

class PromptGoApp extends StatelessWidget {
  const PromptGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: violet, secondary: cyan, surface: panel),
      useMaterial3: true,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptGo',
      theme: theme.copyWith(
        textTheme: GoogleFonts.interTextTheme(theme.textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: bg, elevation: 0),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const SplashScreen(),
    );
  }
}

class Prompt {
  final String id, title, imageUrl, text;
  final String? categoryId;
  final bool featured;
  const Prompt(this.id, this.title, this.imageUrl, this.text, this.categoryId, this.featured);
  factory Prompt.fromMap(Map<String, dynamic> m) => Prompt(
    m['id'].toString(), (m['title'] ?? 'Untitled').toString(),
    (m['image_url'] ?? '').toString(), (m['prompt_text'] ?? '').toString(),
    m['category_id']?.toString(), m['is_featured'] == true,
  );
}

class PromptCategory {
  final String id, name;
  const PromptCategory(this.id, this.name);
  factory PromptCategory.fromMap(Map<String, dynamic> m) =>
      PromptCategory(m['id'].toString(), (m['name'] ?? '').toString());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment(0, -.25), radius: 1.1,
        colors: [Color(0xFF2A2050), bg, bg],
      )),
      child: Center(child: FadeTransition(
        opacity: controller,
        child: ScaleTransition(
          scale: Tween(begin: .8, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 108, height: 108,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(colors: [violet, Color(0xFF547CFF), cyan]),
                boxShadow: [BoxShadow(color: violet.withOpacity(.4), blurRadius: 40)],
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('PromptGo', style: GoogleFonts.inter(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 8),
            const Text('Ideas into incredible creations', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 42),
            const Text('VERSION 1.0.0', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
          ]),
        ),
      )),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Prompt> prompts = [];
  List<PromptCategory> categories = [];
  Set<String> favorites = {};
  bool loading = true, searchOpen = false;
  String search = '';
  String? category;
  int tab = 0;
  final searchController = TextEditingController();

  @override
  void initState() { super.initState(); load(); }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final promptRows = await db
        .from('prompts')
        .select('id,category_id,title,image_url,prompt_text,is_featured,created_at')
        .order('created_at', ascending: false);
    final categoryRows = await db
        .from('categories')
        .select('id,name,sort_order')
        .order('sort_order')
        .order('name');
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      prompts = (promptRows as List)
          .map((e) => Prompt.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      categories = (categoryRows as List)
          .map((e) => PromptCategory.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      favorites = (prefs.getStringList('promptgo_favorites') ?? []).toSet();
      loading = false;
    });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }

  Future<void> toggleFavorite(Prompt p) async {
    final next = {...favorites};
    if (next.contains(p.id)) { next.remove(p.id); } else { next.add(p.id); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('promptgo_favorites', next.toList());
    if (mounted) setState(() => favorites = next);
  }

  List<Prompt> get visible {
    Iterable<Prompt> list = prompts;
    if (tab == 1) list = list.where((p) => favorites.contains(p.id));
    if (category != null) list = list.where((p) => p.categoryId == category);
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      list = list.where((p) => p.title.toLowerCase().contains(q) || p.text.toLowerCase().contains(q));
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: buildDrawer(),
    body: SafeArea(child: Column(children: [
      topBar(),
      Expanded(child: loading
        ? const Center(child: CircularProgressIndicator(color: violet))
        : RefreshIndicator(color: violet, backgroundColor: panel, onRefresh: load,
            child: tab == 1 ? favoritesBody() : homeBody())),
    ])),
    bottomNavigationBar: bottomBar(),
  );

  Widget topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [violet, cyan]),
      ), child: const Icon(Icons.auto_awesome_rounded, size: 22)),
      const SizedBox(width: 10),
      Text('PromptGo', style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w900)),
      const Spacer(),
      if (searchOpen) Expanded(child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          controller: searchController, autofocus: true,
          onChanged: (v) => setState(() => search = v),
          decoration: InputDecoration(
            hintText: 'Search prompts...', isDense: true, filled: true, fillColor: panel2,
            prefixIcon: const Icon(Icons.search, size: 19),
            suffixIcon: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
              searchController.clear(); setState(() { search = ''; searchOpen = false; });
            }),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      )) else actionButton(Icons.search_rounded, () => setState(() => searchOpen = true)),
      const SizedBox(width: 8),
      Builder(builder: (ctx) => actionButton(Icons.menu_rounded, () => Scaffold.of(ctx).openDrawer())),
    ]),
  );

  Widget actionButton(IconData icon, VoidCallback tap) => Material(
    color: panel2, borderRadius: BorderRadius.circular(13),
    child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(13),
      child: SizedBox(width: 42, height: 42, child: Icon(icon, size: 21))),
  );

  Widget heading(String title, String sub) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.8)),
      const SizedBox(height: 5),
      Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );

  Widget homeBody() {
    final list = visible;
    final featured = prompts.where((p) => p.featured).take(8).toList();
    return ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.only(bottom: 25), children: [
      const SizedBox(height: 5),
      heading('Discover', 'Explore ideas. Create more.'),
      if (featured.isNotEmpty) ...[const SizedBox(height: 18), featuredSlider(featured)],
      const SizedBox(height: 27),
      heading('Categories', 'Find prompts by interest'),
      const SizedBox(height: 13),
      categoryChips(),
      const SizedBox(height: 27),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        Text(categoryName(), style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(list.length.toString() + ' prompts', style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ])),
      const SizedBox(height: 14),
      if (list.isEmpty) emptyState(search.isNotEmpty ? 'No matching prompts' : 'No prompts yet',
        search.isNotEmpty ? 'Try another keyword.' : 'New creative prompts will appear here soon.')
      else promptGrid(list),
    ]);
  }

  Widget featuredSlider(List<Prompt> items) => SizedBox(
    height: 205,
    child: PageView.builder(
      controller: PageController(viewportFraction: .88), itemCount: items.length,
      itemBuilder: (ctx, i) {
        final p = items[i];
        return Padding(padding: const EdgeInsets.only(right: 12), child: GestureDetector(
          onTap: () => openPrompt(p),
          child: ClipRRect(borderRadius: BorderRadius.circular(23), child: Stack(fit: StackFit.expand, children: [
            image(p.imageUrl),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xE6000000)],
            ))),
            Positioned(top: 14, left: 14, child: pill('FEATURED', violet)),
            Positioned(left: 18, right: 18, bottom: 17, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                const Row(children: [Text('Explore prompt', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 14, color: cyan)]),
              ],
            )),
          ])),
        ));
      },
    ),
  );

  Widget categoryChips() => SizedBox(height: 42, child: ListView(
    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      chip(null, 'All'),
      ...categories.map((c) => chip(c.id, c.name)),
    ],
  ));

  Widget chip(String? id, String label) {
    final active = category == id;
    return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
      selected: active, label: Text(label),
      onSelected: (_) => setState(() => category = active ? null : id),
      selectedColor: violet, backgroundColor: panel,
      side: BorderSide(color: active ? violet : Colors.white10),
      labelStyle: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ));
  }

  Widget promptGrid(List<Prompt> items) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: .76,
      ),
      itemBuilder: (ctx, i) {
        final p = items[i];
        return GestureDetector(onTap: () => openPrompt(p), child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Colors.white.withOpacity(.06))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Stack(fit: StackFit.expand, children: [
              image(p.imageUrl),
              Positioned(top: 9, right: 9, child: GestureDetector(
                onTap: () => toggleFavorite(p),
                child: glassIcon(favorites.contains(p.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  favorites.contains(p.id) ? Colors.pinkAccent : Colors.white),
              )),
              if (p.featured) Positioned(top: 9, left: 9, child: pill('FEATURED', violet)),
            ])),
            Padding(padding: const EdgeInsets.fromLTRB(11, 10, 11, 12), child: Text(p.title,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3))),
          ]),
        ));
      },
    ),
  );

  Widget favoritesBody() => ListView(
    physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.only(top: 8, bottom: 24),
    children: [
      heading('Your Favorites', 'Your saved creative inspiration'),
      const SizedBox(height: 22),
      if (visible.isEmpty) emptyState('Nothing saved yet', 'Tap the heart on any prompt to save it.')
      else promptGrid(visible),
    ],
  );

  Widget bottomBar() => Container(
    decoration: BoxDecoration(color: const Color(0xFF0D111D),
      border: Border(top: BorderSide(color: Colors.white.withOpacity(.06)))),
    child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 9),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        navItem(Icons.home_rounded, 'Home', 0),
        navItem(Icons.favorite_rounded, 'Favorites', 1),
      ]),
    )),
  );

  Widget navItem(IconData icon, String label, int index) {
    final active = tab == index;
    return InkWell(onTap: () => setState(() { tab = index; category = null; }),
      borderRadius: BorderRadius.circular(14),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        child: Row(children: [
          Icon(icon, size: 19, color: active ? cyan : Colors.white38),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38,
            fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget buildDrawer() => Drawer(
    backgroundColor: const Color(0xFF101524),
    child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 28, 22, 26), child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(colors: [violet, cyan])),
          child: const Icon(Icons.auto_awesome_rounded, size: 27)),
        const SizedBox(width: 13),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PromptGo', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
          const Text('Ideas into incredible creations', style: TextStyle(color: Colors.white54, fontSize: 10)),
        ]),
      ])),
      const Divider(color: Colors.white10),
      drawerItem(Icons.home_rounded, 'Home', () { setState(() => tab = 0); Navigator.pop(context); }),
      drawerItem(Icons.favorite_rounded, 'Favorites', () { setState(() => tab = 1); Navigator.pop(context); }),
      drawerItem(Icons.category_rounded, 'Categories', () { Navigator.pop(context); setState(() => tab = 0); }),
      const Spacer(),
      const Divider(color: Colors.white10),
      drawerItem(Icons.info_outline_rounded, 'About PromptGo', () {
        Navigator.pop(context);
        showAboutDialog(context: context, applicationName: 'PromptGo',
          applicationVersion: '1.0.0', applicationLegalese: 'Ideas into incredible creations.');
      }),
      const Padding(padding: EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Text('VERSION 1.0.0', style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1.5))),
    ])),
  );

  Widget drawerItem(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: Colors.white70, size: 21),
    title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    onTap: onTap,
  );

  Widget emptyState(String title, String subtitle) => Padding(
    padding: const EdgeInsets.fromLTRB(30, 48, 30, 48),
    child: Column(children: [
      Container(width: 70, height: 70, decoration: BoxDecoration(
        color: violet.withOpacity(.13), borderRadius: BorderRadius.circular(23)),
        child: const Icon(Icons.auto_awesome_rounded, color: violet, size: 32)),
      const SizedBox(height: 16),
      Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );

  String categoryName() {
    if (category == null) return 'All Prompts';
    for (final c in categories) { if (c.id == category) return c.name; }
    return 'Prompts';
  }

  Widget image(String url) {
    if (url.trim().isEmpty) return Container(color: panel2,
      child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 35)));
    return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: panel2,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: violet))),
      errorWidget: (_, __, ___) => Container(color: panel2,
        child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 32))),
    );
  }

  Widget pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(.92), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .7)),
  );

  Widget glassIcon(IconData icon, Color color) => Container(width: 31, height: 31,
    decoration: BoxDecoration(color: Colors.black.withOpacity(.48), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color, size: 17));

  void openPrompt(Prompt p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PromptDetailScreen(
      prompt: p, isFavorite: favorites.contains(p.id), onFavorite: () => toggleFavorite(p),
    ))).then((_) { if (mounted) setState(() {}); });
  }
}

class PromptDetailScreen extends StatefulWidget {
  final Prompt prompt;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const PromptDetailScreen({super.key, required this.prompt, required this.isFavorite, required this.onFavorite});
  @override
  State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
  Timer? timer;
  String shown = '';
  int position = 0;
  bool complete = false, favorite = false;

  @override
  void initState() { super.initState(); favorite = widget.isFavorite; startTyping(); }

  void startTyping() {
    final text = widget.prompt.text;
    timer = Timer.periodic(const Duration(milliseconds: 13), (t) {
      if (!mounted) return;
      if (position >= text.length) {
        t.cancel(); setState(() => complete = true); return;
      }
      final next = (position + 3).clamp(0, text.length);
      setState(() { shown = text.substring(0, next); position = next; });
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  Future<void> copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: widget.prompt.text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt copied to clipboard')));
  }

  Future<void> sharePrompt() async => Share.share(widget.prompt.title + '\n\n' + widget.prompt.text);

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Details', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: () { setState(() => favorite = !favorite); widget.onFavorite(); },
            icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: favorite ? Colors.pinkAccent : Colors.white)),
          IconButton(onPressed: sharePrompt, icon: const Icon(Icons.share_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
        ClipRRect(borderRadius: BorderRadius.circular(23), child: AspectRatio(aspectRatio: 1.12,
          child: p.imageUrl.isEmpty ? Container(color: panel2, child: const Icon(Icons.image_outlined, size: 48))
          : CachedNetworkImage(imageUrl: p.imageUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: panel2, child: const Center(child: CircularProgressIndicator(color: violet))),
            errorWidget: (_, __, ___) => Container(color: panel2, child: const Icon(Icons.broken_image_outlined, size: 42, color: Colors.white38)),
          ),
        )),
        const SizedBox(height: 22),
        Text(p.title, style: GoogleFonts.inter(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        const SizedBox(height: 18),
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: cyan, size: 17),
          const SizedBox(width: 8),
          Text('YOUR PROMPT', style: GoogleFonts.inter(color: cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const Spacer(),
          if (!complete) const Text('Writing...', style: TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
        const SizedBox(height: 11),
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(
          color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: violet.withOpacity(.22))),
          child: SelectableText(shown, style: GoogleFonts.inter(fontSize: 13, height: 1.75, color: Colors.white.withOpacity(.9))),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: complete
          ? Column(key: const ValueKey('ready'), children: [
              SizedBox(width: double.infinity, height: 54, child: DecoratedBox(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [violet, Color(0xFF5579F8)]),
                  borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: violet.withOpacity(.25), blurRadius: 20, offset: const Offset(0, 8))]),
                child: ElevatedButton.icon(onPressed: copyPrompt, icon: const Icon(Icons.copy_rounded, size: 19),
                  label: const Text('Copy Prompt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              )),
              const SizedBox(height: 10),
              TextButton.icon(onPressed: sharePrompt, icon: const Icon(Icons.share_outlined, size: 17),
                label: const Text('Share prompt'), style: TextButton.styleFrom(foregroundColor: Colors.white70)),
            ])
          : const SizedBox(key: ValueKey('typing'), height: 54,
              child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: violet)))),
        ),
      ]),
    );
  }
}
