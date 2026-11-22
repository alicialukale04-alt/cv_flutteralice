import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// Émulateur Android : 'http://10.0.2.2/api-test/public'
// Chrome (Web) / Réseau local : 'http://localhost/api-test/public'
const String kBaseUrl = 'http://localhost/api-test/public';

void main() => runApp(const CvApp());

// ============================================================================
// MODÈLES
// ============================================================================
class Langue {
  final String nom;
  final int niveau;
  const Langue(this.nom, this.niveau);
}

class Membre {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  Membre({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'],
      nom: json['nom'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      parente: json['parente'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, String> toJson() {
    return {
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'parente': parente,
    };
  }
}

// ============================================================================
// DONNÉES STATIQUES (Pour le CV)
// ============================================================================
class Donnees {
  static const prenom = 'Alice';
  static const nom = 'Lukale';
  static const postNom = 'Kokoy';
  static const titre = 'Étudiante en entrepreneuriat';
  static const photo = 'assets/images/alice.jpg';

  static const telephone = '+243 977 517 069';
  static const email = 'alicialukale04@gmail.com';
  static const localisation = 'Goma, RD Congo';

  static const formation = 'Entrepreneuriat';
  static const formationDesc =
      "Parcours axé sur la création, la gestion et le développement d'entreprises.";

  static const experienceRole = 'Stage';
  static const experienceEntreprise = 'Hayatcom';
  static const experienceDesc =
      'Immersion dans le secteur des télécommunications — découverte des métiers, des équipements et des infrastructures.';

  static const competenceNom = 'Télécommunications';
  static const competenceDesc =
      'Notions sur les réseaux, les équipements et les services de télécommunication.';

  static const langues = <Langue>[
    Langue('Français', 3),
    Langue('Anglais', 2),
    Langue('Swahili', 3),
    Langue('Lingala', 3),
  ];
}

// ============================================================================
// SERVICE API
// ============================================================================
class ApiService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/accounts/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return data;
    }
    throw Exception(data['message'] ?? 'Erreur de connexion');
  }

  static Future<List<Membre>> getMembres() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/famille-membres'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data['data'] as List;
      return list.map((e) => Membre.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement');
  }

  static String _parseError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data['errors'] != null) {
        return (data['errors'] as Map).values.first.toString();
      }
      return data['message'] ?? 'Erreur inconnue';
    } catch (_) {
      return 'Erreur serveur (${res.statusCode})';
    }
  }

  static Future<void> addMembre(Membre m, {File? image}) async {
    try {
      if (image != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$kBaseUrl/famille-membres'),
        );
        request.headers.addAll({'Accept': 'application/json'});
        request.fields.addAll(m.toJson());
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );

        final response = await request.send();
        final res = await http.Response.fromStream(response);
        if (res.statusCode != 201) throw Exception(_parseError(res));
      } else {
        final res = await http.post(
          Uri.parse('$kBaseUrl/famille-membres'),
          headers: _headers,
          body: jsonEncode(m.toJson()),
        );
        if (res.statusCode != 201) throw Exception(_parseError(res));
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static Future<void> updateMembre(Membre m, {File? image}) async {
    try {
      if (image != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$kBaseUrl/famille-membres/${m.id}'),
        );
        request.headers.addAll({'Accept': 'application/json'});
        request.fields.addAll(m.toJson());
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );

        final response = await request.send();
        final res = await http.Response.fromStream(response);
        if (res.statusCode != 200) throw Exception(_parseError(res));
      } else {
        final res = await http.put(
          Uri.parse('$kBaseUrl/famille-membres/${m.id}'),
          headers: _headers,
          body: jsonEncode(m.toJson()),
        );
        if (res.statusCode != 200) throw Exception(_parseError(res));
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  static Future<void> deleteMembre(int id) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/famille-membres/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) throw Exception('Erreur lors de la suppression');
  }
}

// ============================================================================
// DESIGN TOKENS (Ceux d'Alice)
// ============================================================================
const kBg = Color(0xFFFAF6F2);
const kSurface = Color(0xFFFFFFFF);
const kInk = Color(0xFF1C1317);
const kInk2 = Color(0xFF5C4A52);
const kInk3 = Color(0xFF9A8A91);
const kBorder = Color(0xFFF0E5E8);
const kAccent = Color(0xFFA83E5F);
const kAccentSoft = Color(0xFFFBE8EE);
const kGold = Color(0xFFB8924D);
const kDanger = Color(0xFFB93440);
const kDangerSoft = Color(0xFFFDECEE);

TextStyle sora(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = kInk,
  double? h,
  double? ls,
}) => GoogleFonts.sora(
  fontSize: size,
  fontWeight: w,
  color: c,
  height: h,
  letterSpacing: ls,
);

// ============================================================================
// APP
// ============================================================================
class CvApp extends StatelessWidget {
  const CvApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Alice Lukale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccent,
          brightness: Brightness.light,
        ).copyWith(primary: kAccent, surface: kSurface, onSurface: kInk),
        scaffoldBackgroundColor: kBg,
        splashFactory: InkSparkle.splashFactory,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: kAccent,
          selectionColor: kAccent.withOpacity(0.18),
          selectionHandleColor: kAccent,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================================
// COMPOSANTS RÉUTILISABLES
// ============================================================================
class Photo extends StatelessWidget {
  final String? asset;
  final String? networkUrl;
  final String nom;
  final double w;
  final double h;
  final double radius;
  final Color bg;
  final bool circular;

  const Photo({
    super.key,
    this.asset,
    this.networkUrl,
    required this.nom,
    this.w = 56,
    this.h = 56,
    this.radius = 12,
    this.bg = kAccentSoft,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final initiale = nom.isNotEmpty ? nom.trim()[0].toUpperCase() : '?';
    final placeholder = Container(
      width: w,
      height: h,
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initiale,
        style: sora(w * 0.35, w: FontWeight.w700, c: kAccent),
      ),
    );

    Widget child;
    if (networkUrl != null) {
      child = Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (asset != null) {
      child = Image.asset(
        asset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      child = placeholder;
    }

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: circular ? null : BorderRadius.circular(radius),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        color: bg,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class SectionHead extends StatelessWidget {
  final String num;
  final String label;
  const SectionHead(this.num, this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Text(
            num,
            style: sora(11, w: FontWeight.w700, c: kAccent, ls: 1.5),
          ),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: sora(11, w: FontWeight.w700, c: kInk, ls: 1.5),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: kBorder)),
        ],
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? bg;
  final Color? border;
  final VoidCallback? onTap;
  const CardBox({
    super.key,
    required this.child,
    this.padding,
    this.bg,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg ?? kSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border ?? kBorder),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

void toast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: sora(13, w: FontWeight.w500, c: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        backgroundColor: isError ? kDanger : kInk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}

// ============================================================================
// LOGIN
// ============================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  bool _hide = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await ApiService.login(_idCtrl.text.trim(), _mdpCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'Connexion',
                style: sora(36, w: FontWeight.w800, h: 1.0, ls: -1.2),
              ),
              const SizedBox(height: 40),

              _field(
                'Identifiant',
                _idCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              _field(
                'Mot de passe',
                _mdpCtrl,
                obscure: _hide,
                onSubmitted: (_) => _submit(),
                suffix: IconButton(
                  iconSize: 20,
                  splashRadius: 20,
                  icon: Icon(
                    _hide
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: kInk3,
                  ),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kDangerSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: kDanger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: sora(12.5, w: FontWeight.w500, c: kDanger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: kAccent,
                    disabledBackgroundColor: kAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Entrer',
                              style: sora(
                                15,
                                w: FontWeight.w700,
                                c: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    Widget? suffix,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: sora(12.5, w: FontWeight.w600, c: kInk2),
          ),
        ),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          cursorColor: kAccent,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: sora(15, w: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: kSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MAIN SHELL
// ============================================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [AccueilPage(onLogout: _logout), const FamillePage()];
    return Scaffold(
      backgroundColor: kBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_i), child: pages[_i]),
      ),
      bottomNavigationBar: _NavBar(
        index: _i,
        onChange: (v) => setState(() => _i = v),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  const _NavBar({required this.index, required this.onChange});

  static const _items = [
    (
      icon: Icons.article_outlined,
      active: Icons.article_rounded,
      label: 'Accueil',
    ),
    (
      icon: Icons.people_outline_rounded,
      active: Icons.people_rounded,
      label: 'Famille',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++) Expanded(child: _item(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final active = i == index;
    final it = _items[i];
    return InkWell(
      onTap: () => onChange(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              active ? it.active : it.icon,
              key: ValueKey(active),
              size: 22,
              color: active ? kAccent : kInk3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            it.label,
            style: sora(
              11,
              w: active ? FontWeight.w700 : FontWeight.w500,
              c: active ? kAccent : kInk3,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCUEIL (CV)
// ============================================================================
class AccueilPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const AccueilPage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mon CV',
                    style: sora(12.5, w: FontWeight.w600, c: kInk2, ls: 0.2),
                  ),
                  Material(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onLogout,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 17,
                          color: kInk2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              _header(),
              const SizedBox(height: 8),
              Container(height: 1, color: kBorder),

              const SectionHead('01', 'Formation'),
              CardBox(
                bg: kAccentSoft,
                border: kAccent.withOpacity(0.15),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 16,
                          color: kAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Spécialité',
                          style: sora(
                            11,
                            w: FontWeight.w700,
                            c: kAccent,
                            ls: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Donnees.formation,
                      style: sora(
                        28,
                        w: FontWeight.w800,
                        c: kInk,
                        ls: -0.8,
                        h: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Donnees.formationDesc,
                      style: sora(13, c: kInk2, h: 1.55),
                    ),
                  ],
                ),
              ),

              const SectionHead('02', 'Expérience'),
              CardBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kAccentSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            size: 18,
                            color: kAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Donnees.experienceEntreprise,
                                style: sora(16, w: FontWeight.w700, ls: -0.2),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Donnees.experienceRole,
                                style: sora(
                                  12,
                                  c: kGold,
                                  w: FontWeight.w600,
                                  ls: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Donnees.experienceDesc,
                      style: sora(12.5, c: kInk2, h: 1.55),
                    ),
                  ],
                ),
              ),

              const SectionHead('03', 'Compétence clé'),
              CardBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kInk,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.wifi_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secteur',
                                style: sora(
                                  11,
                                  w: FontWeight.w600,
                                  c: kInk3,
                                  ls: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Donnees.competenceNom,
                                style: sora(16, w: FontWeight.w700, ls: -0.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Donnees.competenceDesc,
                      style: sora(12.5, c: kInk2, h: 1.55),
                    ),
                  ],
                ),
              ),

              const SectionHead('04', 'Langues'),
              CardBox(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < Donnees.langues.length; i++) ...[
                      if (i > 0) Container(height: 1, color: kBorder),
                      _langRow(Donnees.langues[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kAccentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ÉTUDIANTE',
                  style: sora(10, w: FontWeight.w700, c: kAccent, ls: 1.2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Alice',
                style: sora(40, w: FontWeight.w800, h: 1.0, ls: -1.6),
              ),
              const SizedBox(height: 2),
              Text(
                'Lukale Kokoy',
                style: sora(17, w: FontWeight.w500, c: kInk2, ls: -0.2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 12, color: kInk3),
                  const SizedBox(width: 4),
                  Text(
                    Donnees.localisation,
                    style: sora(11.5, c: kInk3, w: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kAccent, width: 1.5),
          ),
          child: Photo(
            asset: Donnees.photo,
            nom: Donnees.prenom,
            w: 88,
            h: 88,
            circular: true,
          ),
        ),
      ],
    );
  }

  Widget _langRow(Langue l) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(l.nom, style: sora(13.5, w: FontWeight.w500)),
        ),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(color: i < l.niveau ? kAccent : kBorder),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 50,
          child: Text(
            l.niveau == 3 ? 'Bien' : 'Moyen',
            textAlign: TextAlign.right,
            style: sora(11, c: kInk3, w: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// FAMILLE (Dynamique via API)
// ============================================================================
class FamillePage extends StatefulWidget {
  const FamillePage({super.key});
  @override
  State<FamillePage> createState() => _FamillePageState();
}

class _FamillePageState extends State<FamillePage> {
  List<Membre> _membres = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _membres = await ApiService.getMembres();
    } catch (e) {
      if (mounted) toast(context, 'Erreur: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showForm({Membre? membre}) {
    final nomCtrl = TextEditingController(text: membre?.nom ?? '');
    final postnomCtrl = TextEditingController(text: membre?.postnom ?? '');
    final prenomCtrl = TextEditingController(text: membre?.prenom ?? '');
    final lieuCtrl = TextEditingController(text: membre?.lieuNaissance ?? '');
    final dateCtrl = TextEditingController(text: membre?.dateNaissance ?? '');
    final parenteCtrl = TextEditingController(text: membre?.parente ?? '');
    File? image;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      membre == null
                          ? 'Ajouter un membre'
                          : 'Modifier le membre',
                      style: sora(20, w: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField('Nom', nomCtrl, required: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            'Postnom',
                            postnomCtrl,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField('Prénom', prenomCtrl, required: true),
                    const SizedBox(height: 12),
                    _buildField('Lieu de naissance', lieuCtrl, required: true),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateCtrl,
                      readOnly: true,
                      decoration: _inputDeco(
                        'Date de naissance',
                        suffix: const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: kInk3,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setSheetState(() {
                            dateCtrl.text = DateFormat('yyyy-MM-dd')
                                .format(picked);
                          });
                        }
                      },
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'Lien de parenté (ex: Père)',
                      parenteCtrl,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null)
                          setSheetState(() => image = File(picked.path));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kBorder),
                        foregroundColor: kAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        image == null
                            ? 'Choisir une photo (Optionnel)'
                            : 'Photo sélectionnée',
                        style: sora(13, w: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final m = Membre(
                            id: membre?.id,
                            nom: nomCtrl.text,
                            postnom: postnomCtrl.text,
                            prenom: prenomCtrl.text,
                            lieuNaissance: lieuCtrl.text,
                            dateNaissance: dateCtrl.text,
                            parente: parenteCtrl.text,
                          );

                          try {
                            if (membre == null) {
                              await ApiService.addMembre(m, image: image);
                            } else {
                              await ApiService.updateMembre(m, image: image);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _load();
                          } catch (e) {
                            if (ctx.mounted)
                              toast(ctx, 'Erreur: $e', isError: true);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: kAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Enregistrer',
                          style: sora(15, w: FontWeight.w700, c: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      style: sora(14, w: FontWeight.w500),
      decoration: _inputDeco(label),
      validator: (v) => (required && v!.isEmpty) ? 'Requis' : null,
    );
  }

  InputDecoration _inputDeco(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: sora(13, c: kInk2),
      suffixIcon: suffix,
      filled: true,
      fillColor: kBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tel = Donnees.telephone.replaceAll(' ', '');

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Famille',
                        style: sora(34, w: FontWeight.w800, h: 1.05, ls: -1.4),
                      ),
                      IconButton(
                        onPressed: () => _showForm(),
                        icon: const Icon(
                          Icons.add_circle,
                          color: kAccent,
                          size: 32,
                        ),
                        tooltip: 'Ajouter un membre',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  const SectionHead('01', 'Membres'),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: kAccent),
                      ),
                    )
                  else if (_membres.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Aucun membre.', style: sora(14, c: kInk3)),
                      ),
                    )
                  else
                    for (int i = 0; i < _membres.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _membres.length - 1 ? 0 : 12,
                        ),
                        child: _parentCard(context, _membres[i]),
                      ),

                  const SectionHead('02', 'Contacts'),
                  CardBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _contactRow(
                          Icons.phone_rounded,
                          'Téléphone',
                          Donnees.telephone,
                          () async {
                            final url = Uri.parse('tel:$tel');
                            if (await canLaunchUrl(url)) launchUrl(url);
                          },
                          () {
                            Clipboard.setData(
                              ClipboardData(text: Donnees.telephone),
                            );
                            toast(context, 'Copié');
                          },
                        ),
                        Container(height: 1, color: kBorder),
                        _contactRow(
                          Icons.email_rounded,
                          'E-mail',
                          Donnees.email,
                          () async {
                            final url = Uri.parse('mailto:${Donnees.email}');
                            if (await canLaunchUrl(url)) launchUrl(url);
                          },
                          () {
                            Clipboard.setData(
                              ClipboardData(text: Donnees.email),
                            );
                            toast(context, 'Copié');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _parentCard(BuildContext context, Membre m) {
    return CardBox(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 110,
              height: 140,
              child: Photo(
                networkUrl: m.imageUrl,
                nom: m.nom,
                w: 110,
                h: 140,
                radius: 0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.parente.toUpperCase(),
                            style: sora(
                              10,
                              w: FontWeight.w700,
                              c: kAccent,
                              ls: 1.2,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: kInk3,
                          ),
                          onSelected: (val) async {
                            if (val == 'edit') {
                              _showForm(membre: m);
                            } else if (val == 'delete') {
                              try {
                                await ApiService.deleteMembre(m.id!);
                                _load();
                              } catch (e) {
                                if (context.mounted)
                                  toast(context, '$e', isError: true);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Modifier'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Supprimer',
                                style: TextStyle(color: kDanger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${m.nom} ${m.postnom} ${m.prenom}',
                      style: sora(18, w: FontWeight.w700, h: 1.15, ls: -0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Né(e) le ${m.dateNaissance}',
                      style: sora(12, c: kInk3, w: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
    VoidCallback onLongPress,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kAccentSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: kAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: sora(11, c: kInk3, w: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: sora(13, w: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: kInk3),
          ],
        ),
      ),
    );
  }
}
