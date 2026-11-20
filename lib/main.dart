import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const CvApp());

class Langue {
  final String nom;
  final int niveau;
  const Langue(this.nom, this.niveau);
}

class Membre {
  final String nom;
  final String role;
  final String sousTitre;
  final String photo;
  const Membre(this.nom, this.role, this.sousTitre, this.photo);
}

class Donnees {
  static const identifiant = 'alice';
  static const motDePasse = 'alice1234';

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

  static const famille = <Membre>[
    Membre('Papy Lukale', 'Père', 'Parent biologique', 'assets/images/papy.jpg'),
    Membre('Safi Yolande', 'Mère', 'Parent biologique', 'assets/images/safi.jpg'),
  ];
}

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
}) =>
    GoogleFonts.sora(
        fontSize: size, fontWeight: w, color: c, height: h, letterSpacing: ls);

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

class Photo extends StatelessWidget {
  final String? asset;
  final String nom;
  final double w;
  final double h;
  final double radius;
  final Color bg;
  final bool circular;
  const Photo({
    super.key,
    this.asset,
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
      child: Text(initiale,
          style: sora(w * 0.35, w: FontWeight.w700, c: kAccent)),
    );
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: circular ? null : BorderRadius.circular(radius),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        color: bg,
      ),
      clipBehavior: Clip.antiAlias,
      child: asset == null
          ? placeholder
          : Image.asset(
              asset!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
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
          Text(num,
              style: sora(11,
                  w: FontWeight.w700, c: kAccent, ls: 1.5)),
          const SizedBox(width: 12),
          Text(label.toUpperCase(),
              style: sora(11,
                  w: FontWeight.w700, c: kInk, ls: 1.5)),
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

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg,
          style: sora(13, w: FontWeight.w500, c: Colors.white)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      backgroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
}

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_idCtrl.text.trim().toLowerCase() == Donnees.identifiant &&
        _mdpCtrl.text == Donnees.motDePasse) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Identifiant ou mot de passe incorrect.';
      });
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
              Text('Connexion',
                  style: sora(36,
                      w: FontWeight.w800, h: 1.0, ls: -1.2)),
              const SizedBox(height: 40),

              _field('Identifiant', _idCtrl,
                  textInputAction: TextInputAction.next),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kDangerSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: kDanger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: sora(12.5,
                              w: FontWeight.w500, c: kDanger)),
                    ),
                  ]),
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
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Entrer',
                                style: sora(15,
                                    w: FontWeight.w700,
                                    c: Colors.white)),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Colors.white),
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
          child: Text(label, style: sora(12.5, w: FontWeight.w600, c: kInk2)),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
    final pages = [
      AccueilPage(onLogout: _logout),
      const FamillePage(),
    ];
    return Scaffold(
      backgroundColor: kBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_i), child: pages[_i]),
      ),
      bottomNavigationBar:
          _NavBar(index: _i, onChange: (v) => setState(() => _i = v)),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  const _NavBar({required this.index, required this.onChange});

  static const _items = [
    (icon: Icons.article_outlined, active: Icons.article_rounded, label: 'Accueil'),
    (icon: Icons.people_outline_rounded, active: Icons.people_rounded, label: 'Famille'),
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
              for (int i = 0; i < _items.length; i++)
                Expanded(child: _item(i)),
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
                  Text('Mon CV',
                      style: sora(12.5,
                          w: FontWeight.w600, c: kInk2, ls: 0.2)),
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
                        child: const Icon(Icons.logout_rounded,
                            size: 17, color: kInk2),
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
                    Row(children: [
                      const Icon(Icons.school_rounded,
                          size: 16, color: kAccent),
                      const SizedBox(width: 8),
                      Text('Spécialité',
                          style: sora(11,
                              w: FontWeight.w700,
                              c: kAccent,
                              ls: 1.2)),
                    ]),
                    const SizedBox(height: 14),
                    Text(Donnees.formation,
                        style: sora(28,
                            w: FontWeight.w800,
                            c: kInk,
                            ls: -0.8,
                            h: 1.05)),
                    const SizedBox(height: 10),
                    Text(Donnees.formationDesc,
                        style: sora(13, c: kInk2, h: 1.55)),
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
                          child: const Icon(Icons.business_center_rounded,
                              size: 18, color: kAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Donnees.experienceEntreprise,
                                  style: sora(16,
                                      w: FontWeight.w700, ls: -0.2)),
                              const SizedBox(height: 2),
                              Text(Donnees.experienceRole,
                                  style: sora(12,
                                      c: kGold,
                                      w: FontWeight.w600,
                                      ls: 0.2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(Donnees.experienceDesc,
                        style: sora(12.5, c: kInk2, h: 1.55)),
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
                          child: const Icon(Icons.wifi_rounded,
                              size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Secteur',
                                  style: sora(11,
                                      w: FontWeight.w600,
                                      c: kInk3,
                                      ls: 1)),
                              const SizedBox(height: 2),
                              Text(Donnees.competenceNom,
                                  style: sora(16,
                                      w: FontWeight.w700, ls: -0.2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(Donnees.competenceDesc,
                        style: sora(12.5, c: kInk2, h: 1.55)),
                  ],
                ),
              ),

              const SectionHead('04', 'Langues'),
              CardBox(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kAccentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('ÉTUDIANTE',
                    style: sora(10,
                        w: FontWeight.w700, c: kAccent, ls: 1.2)),
              ),
              const SizedBox(height: 12),
              Text('Alice',
                  style: sora(40,
                      w: FontWeight.w800, h: 1.0, ls: -1.6)),
              const SizedBox(height: 2),
              Text('Lukale Kokoy',
                  style: sora(17,
                      w: FontWeight.w500, c: kInk2, ls: -0.2)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.place_outlined,
                    size: 12, color: kInk3),
                const SizedBox(width: 4),
                Text(Donnees.localisation,
                    style: sora(11.5,
                        c: kInk3, w: FontWeight.w500)),
              ]),
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
              child: Text(l.nom,
                  style: sora(13.5, w: FontWeight.w500)),
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
                          child: Container(
                            color: i < l.niveau ? kAccent : kBorder,
                          ),
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

class FamillePage extends StatelessWidget {
  const FamillePage({super.key});

  Future<void> _open(BuildContext context, String url) async {
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) toast(context, "Impossible d'ouvrir");
    } catch (_) {
      if (context.mounted) toast(context, "Impossible d'ouvrir");
    }
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) toast(context, 'Copié dans le presse-papiers');
  }

  @override
  Widget build(BuildContext context) {
    final tel = Donnees.telephone.replaceAll(' ', '');

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Famille',
                  style: sora(34,
                      w: FontWeight.w800, h: 1.05, ls: -1.4)),
              const SizedBox(height: 6),
              

              const SectionHead('01', 'Parents'),
              for (int i = 0; i < Donnees.famille.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i == Donnees.famille.length - 1 ? 0 : 12),
                  child: _parentCard(context, Donnees.famille[i]),
                ),

              const SectionHead('02', 'Contacts'),
              CardBox(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _contactRow(
                      Icons.phone_rounded,
                      'Téléphone',
                      Donnees.telephone,
                      () => _open(context, 'tel:$tel'),
                      () => _copy(context, Donnees.telephone),
                    ),
                    Container(height: 1, color: kBorder),
                    _contactRow(
                      Icons.email_rounded,
                      'E-mail',
                      Donnees.email,
                      () => _open(context, 'mailto:${Donnees.email}'),
                      () => _copy(context, Donnees.email),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
            ],
          ),
        ),
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
                asset: m.photo,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAccentSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(m.role.toUpperCase(),
                          style: sora(10,
                              w: FontWeight.w700,
                              c: kAccent,
                              ls: 1.2)),
                    ),
                    const SizedBox(height: 10),
                    Text(m.nom,
                        style: sora(20,
                            w: FontWeight.w700, h: 1.15, ls: -0.4)),
                    const SizedBox(height: 4),
                    Text(m.sousTitre,
                        style: sora(12, c: kInk3, w: FontWeight.w500)),
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
                  Text(label,
                      style: sora(11, c: kInk3, w: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: sora(13, w: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: kInk3),
          ],
        ),
      ),
    );
  }
}