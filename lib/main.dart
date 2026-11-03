import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool appDarkMode = true;
Color get bg => appDarkMode ? const Color(0xFF080A12) : const Color(0xFFF5F7FC);
Color get panel => appDarkMode ? const Color(0xFF141A29) : Colors.white;
Color get panel2 => appDarkMode ? const Color(0xFF1D2538) : const Color(0xFFE9EDF5);
Color get foreground => appDarkMode ? Colors.white : const Color(0xFF182033);
Color get secondaryText => appDarkMode ? Colors.white70 : const Color(0xFF586174);
Color get mutedText => appDarkMode ? Colors.white54 : const Color(0xFF657086);
Color get faintText => appDarkMode ? Colors.white38 : const Color(0xFF8992A4);
Color get hairline => appDarkMode ? Colors.white10 : const Color(0x1F182033);
const violet = Color(0xFF8B5CF6);
const cyan = Color(0xFF39D5E8);

const Map<String, Map<String, String>> appTranslations = {"en":{"home":"Home","favorites":"Favorites","categories":"Categories","settings":"Settings","about":"About PromptGo","search":"Search prompts...","latest":"Latest Prompts","latestSub":"The 10 newest creative prompts","findCategory":"Find prompts by interest","all":"All","allPrompts":"All Prompts","yourFavorites":"Your Favorites","savedInspiration":"Your saved creative inspiration","noMatch":"No matching prompts","tryKeyword":"Try another keyword.","noPrompts":"No prompts yet","newSoon":"New creative prompts will appear here soon.","nothingSaved":"Nothing saved yet","tapHeart":"Tap the heart on any prompt to save it.","dark":"Dark theme","light":"Light theme","switchAppearance":"Switch app appearance","language":"App language","chooseLanguage":"Choose your preferred language","theme":"Appearance","onlineLibrary":"Online library","onlineDescription":"Prompts and categories sync from the internet.","favoriteDescription":"Save prompts on this device.","copyShare":"Copy and share","copyDescription":"Use prompts in your favorite creative tools.","promptDetails":"Prompt Details","yourPrompt":"YOUR PROMPT","writing":"Writing...","copyPrompt":"Copy Prompt","sharePrompt":"Share prompt","copied":"Prompt copied to clipboard","aboutDescription":"PromptGo is an online prompt library that helps you discover creative ideas, explore categories, save your favorite prompts, and copy or share prompts for your projects.","version":"Version 1.0.0"},"ps":{"home":"کور","favorites":"خوښې","categories":"کټګورۍ","settings":"تنظیمات","about":"د PromptGo په اړه","search":"پرومپټونه ولټوئ...","latest":"وروستي پرومپټونه","latestSub":"۱۰ نوي پرومپټونه","findCategory":"د خپلې خوښې کټګوري وټاکئ","all":"ټول","allPrompts":"ټول پرومپټونه","yourFavorites":"ستاسو خوښې","savedInspiration":"ستاسو خوندي شوي پرومپټونه","noMatch":"مناسب پرومپټ ونه موندل شو","tryKeyword":"بله کلمه وازمویئ.","noPrompts":"تر اوسه پرومپټ نشته","newSoon":"نوي پرومپټونه به ژر دلته ښکاره شي.","nothingSaved":"تر اوسه مو څه نه دي خوندي کړي","tapHeart":"د خوندي کولو لپاره د زړه نښه کېکاږئ.","dark":"تیاره بڼه","light":"روښانه بڼه","switchAppearance":"د اپ بڼه بدله کړئ","language":"د اپ ژبه","chooseLanguage":"خپله خوښه ژبه وټاکئ","theme":"بڼه","onlineLibrary":"آنلاین کتابتون","onlineDescription":"پرومپټونه او کټګورۍ له انټرنېټ سره همغږي کېږي.","favoriteDescription":"پرومپټونه په همدې موبایل کې خوندي کړئ.","copyShare":"کاپي او شریکول","copyDescription":"پرومپټونه په خپلو خوښو وسیلو کې وکاروئ.","promptDetails":"د پرومپټ معلومات","yourPrompt":"ستاسو پرومپټ","writing":"لیکل کېږي...","copyPrompt":"پرومپټ کاپي کړئ","sharePrompt":"پرومپټ شریک کړئ","copied":"پرومپټ کاپي شو","aboutDescription":"PromptGo یو آنلاین کتابتون دی چې تخلیقي نظریې، کټګورۍ او پرومپټونه درته برابروي؛ خپلې خوښې خوندي، کاپي او شریکولی شئ.","version":"نسخه ۱.۰.۰"},"ar":{"home":"الرئيسية","favorites":"المفضلة","categories":"الفئات","settings":"الإعدادات","about":"حول PromptGo","search":"ابحث عن المطالبات...","latest":"أحدث المطالبات","latestSub":"أحدث 10 مطالبات إبداعية","findCategory":"اكتشف المطالبات حسب الاهتمام","all":"الكل","allPrompts":"كل المطالبات","yourFavorites":"مفضلتك","savedInspiration":"إلهامك المحفوظ","noMatch":"لا توجد مطالبات مطابقة","tryKeyword":"جرّب كلمة أخرى.","noPrompts":"لا توجد مطالبات بعد","newSoon":"ستظهر المطالبات الجديدة هنا قريباً.","nothingSaved":"لم تحفظ شيئاً بعد","tapHeart":"اضغط على القلب لحفظ أي مطالبة.","dark":"الوضع الداكن","light":"الوضع الفاتح","switchAppearance":"تغيير مظهر التطبيق","language":"لغة التطبيق","chooseLanguage":"اختر لغتك المفضلة","theme":"المظهر","onlineLibrary":"المكتبة عبر الإنترنت","onlineDescription":"تتم مزامنة المطالبات والفئات عبر الإنترنت.","favoriteDescription":"احفظ المطالبات على هذا الجهاز.","copyShare":"نسخ ومشاركة","copyDescription":"استخدم المطالبات في أدواتك الإبداعية المفضلة.","promptDetails":"تفاصيل المطالبة","yourPrompt":"مطالبتك","writing":"جارٍ الكتابة...","copyPrompt":"نسخ المطالبة","sharePrompt":"مشاركة المطالبة","copied":"تم نسخ المطالبة","aboutDescription":"PromptGo مكتبة مطالبات عبر الإنترنت تساعدك على اكتشاف الأفكار الإبداعية واستكشاف الفئات وحفظ مطالباتك المفضلة ونسخها أو مشاركتها.","version":"الإصدار 1.0.0"},"ur":{"home":"ہوم","favorites":"پسندیدہ","categories":"اقسام","settings":"ترتیبات","about":"PromptGo کے بارے میں","search":"پرومپٹس تلاش کریں...","latest":"تازہ ترین پرومپٹس","latestSub":"10 نئے تخلیقی پرومپٹس","findCategory":"دلچسپی کے مطابق پرومپٹس تلاش کریں","all":"سب","allPrompts":"تمام پرومپٹس","yourFavorites":"آپ کے پسندیدہ","savedInspiration":"آپ کے محفوظ کردہ پرومپٹس","noMatch":"کوئی مماثل پرومپٹ نہیں ملا","tryKeyword":"کوئی اور لفظ آزمائیں۔","noPrompts":"ابھی کوئی پرومپٹ نہیں","newSoon":"نئے پرومپٹس جلد یہاں آئیں گے۔","nothingSaved":"ابھی کچھ محفوظ نہیں","tapHeart":"محفوظ کرنے کے لیے دل کے نشان پر ٹیپ کریں۔","dark":"ڈارک تھیم","light":"لائٹ تھیم","switchAppearance":"ایپ کی شکل تبدیل کریں","language":"ایپ کی زبان","chooseLanguage":"اپنی پسندیدہ زبان منتخب کریں","theme":"ظاہری شکل","onlineLibrary":"آن لائن لائبریری","onlineDescription":"پرومپٹس اور اقسام انٹرنیٹ سے ہم آہنگ ہوتی ہیں۔","favoriteDescription":"پرومپٹس اسی ڈیوائس پر محفوظ کریں۔","copyShare":"کاپی اور شیئر","copyDescription":"اپنے پسندیدہ تخلیقی ٹولز میں پرومپٹس استعمال کریں۔","promptDetails":"پرومپٹ کی تفصیلات","yourPrompt":"آپ کا پرومپٹ","writing":"لکھا جا رہا ہے...","copyPrompt":"پرومپٹ کاپی کریں","sharePrompt":"پرومپٹ شیئر کریں","copied":"پرومپٹ کاپی ہوگیا","aboutDescription":"PromptGo ایک آن لائن پرومپٹ لائبریری ہے جہاں آپ تخلیقی خیالات تلاش، پسندیدہ پرومپٹس محفوظ، کاپی اور شیئر کر سکتے ہیں۔","version":"ورژن 1.0.0"},"fa":{"home":"خانه","favorites":"علاقه‌مندی‌ها","categories":"دسته‌بندی‌ها","settings":"تنظیمات","about":"درباره PromptGo","search":"جستجوی پرامپت‌ها...","latest":"جدیدترین پرامپت‌ها","latestSub":"۱۰ پرامپت خلاقانه جدید","findCategory":"پرامپت‌ها را بر اساس علاقه پیدا کنید","all":"همه","allPrompts":"همه پرامپت‌ها","yourFavorites":"علاقه‌مندی‌های شما","savedInspiration":"پرامپت‌های ذخیره‌شده شما","noMatch":"پرامپت مرتبطی پیدا نشد","tryKeyword":"کلمه دیگری را امتحان کنید.","noPrompts":"هنوز پرامپتی وجود ندارد","newSoon":"پرامپت‌های جدید به‌زودی اینجا نمایش داده می‌شوند.","nothingSaved":"هنوز چیزی ذخیره نشده","tapHeart":"برای ذخیره، روی قلب بزنید.","dark":"حالت تاریک","light":"حالت روشن","switchAppearance":"تغییر ظاهر برنامه","language":"زبان برنامه","chooseLanguage":"زبان دلخواه خود را انتخاب کنید","theme":"ظاهر","onlineLibrary":"کتابخانه آنلاین","onlineDescription":"پرامپت‌ها و دسته‌بندی‌ها از اینترنت همگام می‌شوند.","favoriteDescription":"پرامپت‌ها را در این دستگاه ذخیره کنید.","copyShare":"کپی و اشتراک‌گذاری","copyDescription":"از پرامپت‌ها در ابزارهای خلاقانه دلخواه استفاده کنید.","promptDetails":"جزئیات پرامپت","yourPrompt":"پرامپت شما","writing":"در حال نوشتن...","copyPrompt":"کپی پرامپت","sharePrompt":"اشتراک‌گذاری پرامپت","copied":"پرامپت کپی شد","aboutDescription":"PromptGo یک کتابخانه آنلاین پرامپت است که به شما کمک می‌کند ایده‌های خلاقانه پیدا کنید، دسته‌بندی‌ها را ببینید و پرامپت‌های دلخواه را ذخیره، کپی یا به اشتراک بگذارید.","version":"نسخه ۱.۰.۰"},"hi":{"home":"होम","favorites":"पसंदीदा","categories":"श्रेणियाँ","settings":"सेटिंग्स","about":"PromptGo के बारे में","search":"प्रॉम्प्ट खोजें...","latest":"नवीनतम प्रॉम्प्ट","latestSub":"10 नए रचनात्मक प्रॉम्प्ट","findCategory":"रुचि के अनुसार प्रॉम्प्ट खोजें","all":"सभी","allPrompts":"सभी प्रॉम्प्ट","yourFavorites":"आपके पसंदीदा","savedInspiration":"आपके सहेजे गए प्रॉम्प्ट","noMatch":"कोई मेल खाता प्रॉम्प्ट नहीं","tryKeyword":"दूसरा शब्द आज़माएँ।","noPrompts":"अभी कोई प्रॉम्प्ट नहीं","newSoon":"नए प्रॉम्प्ट जल्द यहाँ दिखेंगे।","nothingSaved":"अभी कुछ सहेजा नहीं गया","tapHeart":"सहेजने के लिए दिल के निशान पर टैप करें।","dark":"डार्क थीम","light":"लाइट थीम","switchAppearance":"ऐप का रूप बदलें","language":"ऐप की भाषा","chooseLanguage":"अपनी पसंदीदा भाषा चुनें","theme":"दिखावट","onlineLibrary":"ऑनलाइन लाइब्रेरी","onlineDescription":"प्रॉम्प्ट और श्रेणियाँ इंटरनेट से सिंक होती हैं।","favoriteDescription":"प्रॉम्प्ट इस डिवाइस पर सहेजें।","copyShare":"कॉपी और शेयर","copyDescription":"अपने पसंदीदा क्रिएटिव टूल में प्रॉम्प्ट इस्तेमाल करें।","promptDetails":"प्रॉम्प्ट विवरण","yourPrompt":"आपका प्रॉम्प्ट","writing":"लिखा जा रहा है...","copyPrompt":"प्रॉम्प्ट कॉपी करें","sharePrompt":"प्रॉम्प्ट शेयर करें","copied":"प्रॉम्प्ट कॉपी हो गया","aboutDescription":"PromptGo एक ऑनलाइन प्रॉम्प्ट लाइब्रेरी है जहाँ आप रचनात्मक विचार खोज सकते हैं, श्रेणियाँ देख सकते हैं और पसंदीदा प्रॉम्प्ट सहेज, कॉपी या शेयर कर सकते हैं।","version":"संस्करण 1.0.0"},"tr":{"home":"Ana Sayfa","favorites":"Favoriler","categories":"Kategoriler","settings":"Ayarlar","about":"PromptGo Hakkında","search":"İstemleri ara...","latest":"En Yeni İstemler","latestSub":"En yeni 10 yaratıcı istem","findCategory":"İlgi alanına göre istem bul","all":"Tümü","allPrompts":"Tüm İstemler","yourFavorites":"Favorileriniz","savedInspiration":"Kaydettiğiniz yaratıcı fikirler","noMatch":"Eşleşen istem bulunamadı","tryKeyword":"Başka bir kelime deneyin.","noPrompts":"Henüz istem yok","newSoon":"Yeni istemler yakında burada görünecek.","nothingSaved":"Henüz kaydedilen yok","tapHeart":"Kaydetmek için kalp simgesine dokunun.","dark":"Koyu tema","light":"Açık tema","switchAppearance":"Uygulama görünümünü değiştir","language":"Uygulama dili","chooseLanguage":"Tercih ettiğiniz dili seçin","theme":"Görünüm","onlineLibrary":"Çevrimiçi kütüphane","onlineDescription":"İstemler ve kategoriler internetle eşitlenir.","favoriteDescription":"İstemleri bu cihazda kaydedin.","copyShare":"Kopyala ve paylaş","copyDescription":"İstemleri sevdiğiniz yaratıcı araçlarda kullanın.","promptDetails":"İstem Detayları","yourPrompt":"İSTEMİNİZ","writing":"Yazılıyor...","copyPrompt":"İstemi Kopyala","sharePrompt":"İstemi Paylaş","copied":"İstem panoya kopyalandı","aboutDescription":"PromptGo, yaratıcı fikirleri keşfetmenize, kategorilere göz atmanıza, favori istemlerinizi kaydetmenize, kopyalamanıza ve paylaşmanıza yardımcı olan çevrimiçi bir istem kütüphanesidir.","version":"Sürüm 1.0.0"},"zh":{"home":"首页","favorites":"收藏","categories":"分类","settings":"设置","about":"关于 PromptGo","search":"搜索提示词...","latest":"最新提示词","latestSub":"最新的 10 个创意提示词","findCategory":"按兴趣查找提示词","all":"全部","allPrompts":"所有提示词","yourFavorites":"我的收藏","savedInspiration":"已保存的创意灵感","noMatch":"没有匹配的提示词","tryKeyword":"请尝试其他关键词。","noPrompts":"暂无提示词","newSoon":"新提示词很快会显示在这里。","nothingSaved":"尚未收藏内容","tapHeart":"点击心形图标即可收藏。","dark":"深色主题","light":"浅色主题","switchAppearance":"切换应用外观","language":"应用语言","chooseLanguage":"选择您偏好的语言","theme":"外观","onlineLibrary":"在线提示词库","onlineDescription":"提示词和分类通过互联网同步。","favoriteDescription":"将提示词保存在此设备上。","copyShare":"复制和分享","copyDescription":"在您喜欢的创意工具中使用提示词。","promptDetails":"提示词详情","yourPrompt":"您的提示词","writing":"正在输入...","copyPrompt":"复制提示词","sharePrompt":"分享提示词","copied":"提示词已复制","aboutDescription":"PromptGo 是一个在线提示词库，帮助您发现创意灵感、浏览分类、保存收藏，并复制或分享提示词。","version":"版本 1.0.0"},"es":{"home":"Inicio","favorites":"Favoritos","categories":"Categorías","settings":"Ajustes","about":"Acerca de PromptGo","search":"Buscar prompts...","latest":"Prompts recientes","latestSub":"Los 10 prompts creativos más nuevos","findCategory":"Encuentra prompts por interés","all":"Todo","allPrompts":"Todos los prompts","yourFavorites":"Tus favoritos","savedInspiration":"Tu inspiración guardada","noMatch":"No hay prompts coincidentes","tryKeyword":"Prueba otra palabra.","noPrompts":"Aún no hay prompts","newSoon":"Los nuevos prompts aparecerán aquí pronto.","nothingSaved":"Aún no has guardado nada","tapHeart":"Toca el corazón para guardar un prompt.","dark":"Tema oscuro","light":"Tema claro","switchAppearance":"Cambiar apariencia de la app","language":"Idioma de la app","chooseLanguage":"Elige tu idioma preferido","theme":"Apariencia","onlineLibrary":"Biblioteca en línea","onlineDescription":"Los prompts y categorías se sincronizan por internet.","favoriteDescription":"Guarda prompts en este dispositivo.","copyShare":"Copiar y compartir","copyDescription":"Usa prompts en tus herramientas creativas favoritas.","promptDetails":"Detalles del prompt","yourPrompt":"TU PROMPT","writing":"Escribiendo...","copyPrompt":"Copiar prompt","sharePrompt":"Compartir prompt","copied":"Prompt copiado","aboutDescription":"PromptGo es una biblioteca de prompts en línea que te ayuda a descubrir ideas creativas, explorar categorías y guardar, copiar o compartir tus prompts favoritos.","version":"Versión 1.0.0"},"fr":{"home":"Accueil","favorites":"Favoris","categories":"Catégories","settings":"Paramètres","about":"À propos de PromptGo","search":"Rechercher des prompts...","latest":"Derniers prompts","latestSub":"Les 10 nouveaux prompts créatifs","findCategory":"Trouver des prompts par intérêt","all":"Tout","allPrompts":"Tous les prompts","yourFavorites":"Vos favoris","savedInspiration":"Votre inspiration enregistrée","noMatch":"Aucun prompt correspondant","tryKeyword":"Essayez un autre mot.","noPrompts":"Aucun prompt pour le moment","newSoon":"Les nouveaux prompts apparaîtront bientôt ici.","nothingSaved":"Rien d'enregistré pour le moment","tapHeart":"Touchez le cœur pour enregistrer un prompt.","dark":"Thème sombre","light":"Thème clair","switchAppearance":"Changer l'apparence de l'application","language":"Langue de l'application","chooseLanguage":"Choisissez votre langue préférée","theme":"Apparence","onlineLibrary":"Bibliothèque en ligne","onlineDescription":"Les prompts et catégories se synchronisent via Internet.","favoriteDescription":"Enregistrez les prompts sur cet appareil.","copyShare":"Copier et partager","copyDescription":"Utilisez les prompts dans vos outils créatifs préférés.","promptDetails":"Détails du prompt","yourPrompt":"VOTRE PROMPT","writing":"Écriture...","copyPrompt":"Copier le prompt","sharePrompt":"Partager le prompt","copied":"Prompt copié","aboutDescription":"PromptGo est une bibliothèque de prompts en ligne qui vous aide à découvrir des idées créatives, explorer des catégories et enregistrer, copier ou partager vos prompts préférés.","version":"Version 1.0.0"}};
const Map<String, String> appLanguageNames = {"en":"English","ps":"پښتو","fa":"فارسی","ar":"العربية","ur":"اردو","hi":"हिन्दी","tr":"Türkçe","zh":"中文","es":"Español","fr":"Français"};
String appLanguageCode = 'en';
String tr(String key) => appTranslations[appLanguageCode]?[key] ?? appTranslations['en']![key] ?? key;
bool get appIsRtl => const ['ps', 'ar', 'ur', 'fa'].contains(appLanguageCode);

const supabaseUrl = 'https://evaammherpizsntcbzbf.supabase.co';
const supabaseKey = 'sb_publishable_ZYPPNKKdKoi2-_gMiIl-cw_nJ87SQCZ';
final db = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(const PromptGoApp());
}

class PromptGoApp extends StatefulWidget {
  const PromptGoApp({super.key});
  @override
  State<PromptGoApp> createState() => _PromptGoAppState();
}
class _PromptGoAppState extends State<PromptGoApp> {
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() { appDarkMode = prefs.getBool('promptgo_dark_mode') ?? true; appLanguageCode = prefs.getString('promptgo_language') ?? 'en'; });
  }
  Future<void> _selectLanguage(String code) async {
    appLanguageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('promptgo_language', code);
    if (mounted) setState(() {});
  }\n  Future<void> _toggleTheme() async {
    setState(() => appDarkMode = !appDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promptgo_dark_mode', appDarkMode);
  }
  @override
  Widget build(BuildContext context) {
    final brightness = appDarkMode ? Brightness.dark : Brightness.light;
    final theme = ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: violet, brightness: brightness,
        primary: violet, secondary: cyan, surface: panel),
      useMaterial3: true,
      appBarTheme: AppBarTheme(backgroundColor: bg, foregroundColor: foreground, elevation: 0),
      drawerTheme: DrawerThemeData(backgroundColor: bg),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptGo',
      theme: theme,
      locale: Locale(appLanguageCode),
      supportedLocales: const [Locale('en'), Locale('ps'), Locale('fa'), Locale('ar'), Locale('ur'), Locale('hi'), Locale('tr'), Locale('zh'), Locale('es'), Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Directionality(
        textDirection: appIsRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: SplashScreen(onToggleTheme: _toggleTheme, onSelectLanguage: _selectLanguage),
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
  final Future<void> Function() onToggleTheme;
  final Future<void> Function(String) onSelectLanguage;
  const SplashScreen({super.key, required this.onToggleTheme, required this.onSelectLanguage});
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
        pageBuilder: (_, __, ___) => HomeScreen(onToggleTheme: widget.onToggleTheme, onSelectLanguage: widget.onSelectLanguage),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: BoxDecoration(gradient: RadialGradient(
        center: const Alignment(0, -.25), radius: 1.1,
        colors: [const Color(0xFF2A2050), bg, bg],
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
            Text('PromptGo', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: -1, color: foreground)),
            const SizedBox(height: 8),
            Text('Ideas into incredible creations', style: TextStyle(color: secondaryText, fontSize: 13)),
            const SizedBox(height: 42),
            Text('VERSION 1.0.0', style: TextStyle(color: faintText, fontSize: 10, letterSpacing: 2)),
          ]),
        ),
      )),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final Future<void> Function() onToggleTheme;
  final Future<void> Function(String) onSelectLanguage;
  const HomeScreen({super.key, required this.onToggleTheme, required this.onSelectLanguage});
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
      Text('PromptGo', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: foreground)),
      const Spacer(),
      if (searchOpen) Expanded(child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          controller: searchController, autofocus: true,
          onChanged: (v) => setState(() => search = v),
          decoration: InputDecoration(
            hintText: tr('search'), isDense: true, filled: true, fillColor: panel2,
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
      Text(title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.8, color: foreground)),
      const SizedBox(height: 5),
      Text(sub, style: TextStyle(color: mutedText, fontSize: 12)),
    ]),
  );

  Widget homeBody() {
    final list = visible;
    final featured = prompts.where((p) => p.featured).take(8).toList();
    return ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.only(bottom: 25), children: [
      const SizedBox(height: 5),
      if (prompts.isNotEmpty) ...[
        heading(tr('latest'), tr('latestSub')),
        const SizedBox(height: 14),
        latestPrompts(prompts.take(10).toList()),
      ],
      if (featured.isNotEmpty) ...[const SizedBox(height: 24), featuredSlider(featured)],
      const SizedBox(height: 27),
      heading(tr('categories'), tr('findCategory')),
      const SizedBox(height: 13),
      categoryChips(),
      const SizedBox(height: 27),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        Text(categoryName(), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: foreground)),
        const Spacer(),
        Text(list.length.toString() + ' prompts', style: TextStyle(color: faintText, fontSize: 11)),
      ])),
      const SizedBox(height: 14),
      if (list.isEmpty) emptyState(search.isNotEmpty ? tr('noMatch') : tr('noPrompts'),
        search.isNotEmpty ? tr('tryKeyword') : tr('newSoon'))
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
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

  Widget latestPrompts(List<Prompt> items) => SizedBox(
    height: 166,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (ctx, i) {
        final p = items[i];
        return SizedBox(
          width: 132,
          child: GestureDetector(
            onTap: () => openPrompt(p),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(fit: StackFit.expand, children: [
                image(p.imageUrl),
                const DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE8000000)],
                  ),
                )),
                Positioned(left: 10, right: 9, bottom: 10,
                  child: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))),
                Positioned(top: 9, left: 9, child: pill('NEW', cyan)),
              ]),
            ),
          ),
        );
      },
    ),
  );

  Widget categoryChips() => SizedBox(height: 42, child: ListView(
    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      chip(null, tr('all')),
      ...categories.map((c) => chip(c.id, c.name)),
    ],
  ));

  Widget chip(String? id, String label) {
    final active = category == id;
    return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
      selected: active, label: Text(label),
      onSelected: (_) => setState(() => category = active ? null : id),
      selectedColor: violet, backgroundColor: panel,
      side: BorderSide(color: active ? violet : hairline),
      labelStyle: TextStyle(color: active ? Colors.white : secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
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
            border: Border.all(color: hairline)),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3, color: foreground))),
          ]),
        ));
      },
    ),
  );

  Widget favoritesBody() => ListView(
    physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.only(top: 8, bottom: 24),
    children: [
      heading(tr('yourFavorites'), tr('savedInspiration')),
      const SizedBox(height: 22),
      if (visible.isEmpty) emptyState(tr('nothingSaved'), tr('tapHeart'))
      else promptGrid(visible),
    ],
  );

  Widget bottomBar() => Container(
    decoration: BoxDecoration(color: bg,
      border: Border(top: BorderSide(color: hairline))),
    child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 9),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        navItem(Icons.home_rounded, tr('home'), 0),
        navItem(Icons.favorite_rounded, tr('favorites'), 1),
      ]),
    )),
  );

  Widget navItem(IconData icon, String label, int index) {
    final active = tab == index;
    return InkWell(onTap: () => setState(() { tab = index; category = null; }),
      borderRadius: BorderRadius.circular(14),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        child: Row(children: [
          Icon(icon, size: 19, color: active ? cyan : faintText),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: active ? foreground : faintText,
            fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget buildDrawer() => Drawer(
    backgroundColor: bg,
    child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 28, 22, 26), child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(colors: [violet, cyan])),
          child: const Icon(Icons.auto_awesome_rounded, size: 27)),
        const SizedBox(width: 13),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PromptGo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: foreground)),
          Text('Ideas into incredible creations', style: TextStyle(color: mutedText, fontSize: 10)),
        ]),
      ])),
      Divider(color: hairline),
      drawerItem(Icons.home_rounded, tr('home'), () { setState(() => tab = 0); Navigator.pop(context); }),
      drawerItem(Icons.favorite_rounded, tr('favorites'), () { setState(() => tab = 1); Navigator.pop(context); }),
      drawerItem(Icons.category_rounded, tr('categories'), () { Navigator.pop(context); setState(() => tab = 0); }),
      drawerItem(Icons.settings_rounded, tr('settings'), () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(onToggleTheme: widget.onToggleTheme, onSelectLanguage: widget.onSelectLanguage)));
      }),\n      SwitchListTile(
        secondary: Icon(appDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: violet),
        title: Text(appDarkMode ? tr('dark') : tr('light'), style: TextStyle(color: foreground, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(tr('switchAppearance'), style: TextStyle(color: mutedText, fontSize: 11)),
        value: appDarkMode,
        activeColor: violet,
        onChanged: (_) => widget.onToggleTheme(),
      ),
      const Spacer(),
      Divider(color: hairline),
      drawerItem(Icons.info_outline_rounded, tr('about'), () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPromptGoScreen()));
      }),
      const Padding(padding: EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Text('VERSION 1.0.0', style: TextStyle(color: faintText, fontSize: 10, letterSpacing: 1.5))),
    ])),
  );

  Widget drawerItem(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: secondaryText, size: 21),
    title: Text(title, style: TextStyle(color: foreground, fontSize: 13, fontWeight: FontWeight.w600)),
    onTap: onTap,
  );

  Widget emptyState(String title, String subtitle) => Padding(
    padding: const EdgeInsets.fromLTRB(30, 48, 30, 48),
    child: Column(children: [
      Container(width: 70, height: 70, decoration: BoxDecoration(
        color: violet.withOpacity(.13), borderRadius: BorderRadius.circular(23)),
        child: const Icon(Icons.auto_awesome_rounded, color: violet, size: 32)),
      const SizedBox(height: 16),
      Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: foreground)),
      const SizedBox(height: 7),
      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: mutedText, fontSize: 12)),
    ]),
  );

  String categoryName() {
    if (category == null) return tr('allPrompts');
    for (final c in categories) { if (c.id == category) return c.name; }
    return tr('allPrompts');
  }

  Widget image(String url) {
    if (url.trim().isEmpty) return Container(color: panel2,
      child: Center(child: Icon(Icons.image_not_supported_outlined, color: mutedText, size: 35)));
    return Image.network(url, fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null ? child :
        Container(color: panel2, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: violet))),
      errorBuilder: (_, __, ___) => Container(color: panel2,
        child: Center(child: Icon(Icons.broken_image_outlined, color: mutedText, size: 32))),
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('copied'))));
  }

  Future<void> sharePrompt() async => Share.share(widget.prompt.title + '\n\n' + widget.prompt.text);

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('promptDetails'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground)),
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
          : Image.network(p.imageUrl, fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null ? child :
              Container(color: panel2, child: const Center(child: CircularProgressIndicator(color: violet))),
            errorBuilder: (_, __, ___) => Container(color: panel2,
              child: Center(child: Icon(Icons.broken_image_outlined, size: 42, color: mutedText))),
          ),
        )),
        const SizedBox(height: 22),
        Text(p.title, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -.5, color: foreground)),
        const SizedBox(height: 18),
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: cyan, size: 17),
          const SizedBox(width: 8),
          Text(tr('yourPrompt'), style: const TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const Spacer(),
          if (!complete) Text(tr('writing'), style: TextStyle(color: faintText, fontSize: 10)),
        ]),
        const SizedBox(height: 11),
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(
          color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: violet.withOpacity(.22))),
          child: SelectableText(shown, style: TextStyle(fontSize: 13, height: 1.75, color: foreground.withOpacity(.9))),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: complete
          ? Column(key: const ValueKey('ready'), children: [
              SizedBox(width: double.infinity, height: 54, child: DecoratedBox(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [violet, Color(0xFF5579F8)]),
                  borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: violet.withOpacity(.25), blurRadius: 20, offset: const Offset(0, 8))]),
                child: ElevatedButton.icon(onPressed: copyPrompt, icon: const Icon(Icons.copy_rounded, size: 19),
                  label: Text(tr('copyPrompt'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              )),
              const SizedBox(height: 10),
              TextButton.icon(onPressed: sharePrompt, icon: const Icon(Icons.share_outlined, size: 17),
                label: Text(tr('sharePrompt')), style: TextButton.styleFrom(foregroundColor: secondaryText)),
            ])
          : const SizedBox(key: ValueKey('typing'), height: 54,
              child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: violet)))),
        ),
      ]),
    );
  }
}


class AboutPromptGoScreen extends StatelessWidget {
  const AboutPromptGoScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('about'), style: TextStyle(color: foreground, fontWeight: FontWeight.w700))),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const SizedBox(height: 18),
      Center(child: Container(width: 86, height: 86,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(colors: [violet, Color(0xFF547CFF), cyan])),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 44))),
      const SizedBox(height: 18),
      Text('PromptGo', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: foreground)),
      const SizedBox(height: 7),
      Text('Ideas into incredible creations', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: mutedText)),
      const SizedBox(height: 26),
      Container(padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)),
        child: Text(tr('aboutDescription'),
          style: TextStyle(color: foreground, height: 1.6, fontSize: 13))),
      const SizedBox(height: 18),
      ListTile(leading: Icon(Icons.cloud_done_outlined, color: violet),
        title: Text(tr('onlineLibrary'), style: TextStyle(color: foreground)),
        subtitle: Text(tr('onlineDescription'), style: TextStyle(color: mutedText))),
      ListTile(leading: Icon(Icons.favorite_border_rounded, color: violet),
        title: Text(tr('favorites'), style: TextStyle(color: foreground)),
        subtitle: Text(tr('favoriteDescription'), style: TextStyle(color: mutedText))),
      ListTile(leading: Icon(Icons.copy_rounded, color: violet),
        title: Text(tr('copyShare'), style: TextStyle(color: foreground)),
        subtitle: Text(tr('copyDescription'), style: TextStyle(color: mutedText))),
      const SizedBox(height: 20),
      Center(child: Text(tr('version'), style: TextStyle(color: mutedText, fontSize: 11))),
    ]),
  );
}


class SettingsScreen extends StatefulWidget {
  final Future<void> Function() onToggleTheme;
  final Future<void> Function(String) onSelectLanguage;
  const SettingsScreen({super.key, required this.onToggleTheme, required this.onSelectLanguage});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('settings'), style: TextStyle(color: foreground, fontWeight: FontWeight.w700))),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Text(tr('language'), style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(tr('chooseLanguage'), style: TextStyle(color: mutedText, fontSize: 12)),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: hairline)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: appLanguageCode,
          isExpanded: true,
          dropdownColor: panel,
          style: TextStyle(color: foreground, fontSize: 14),
          items: appLanguageNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: (value) async {
            if (value == null) return;
            await widget.onSelectLanguage(value);
            if (mounted) setState(() {});
          },
        )),
      ),
      const SizedBox(height: 28),
      Text(tr('theme'), style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Container(decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15)),
        child: SwitchListTile(
          secondary: Icon(appDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: violet),
          title: Text(appDarkMode ? tr('dark') : tr('light'), style: TextStyle(color: foreground)),
          subtitle: Text(tr('switchAppearance'), style: TextStyle(color: mutedText, fontSize: 12)),
          value: appDarkMode,
          activeColor: violet,
          onChanged: (_) async { await widget.onToggleTheme(); if (mounted) setState(() {}); },
        ),
      ),
    ]),
  );
}
