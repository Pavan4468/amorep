import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Translation map for static text
const Map<String, Map<String, String>> translations = {
  'en': {
    'Sustainable Development Goals': 'Sustainable Development Goals',
    'SDG Description': 'The 17 Sustainable Development Goals (SDGs) are a universal call to action to end poverty, protect the planet, and ensure peace and prosperity for all.',
    'No goals found': 'No goals found.',
    'Error loading goals': 'Error loading goals: ',
    'Learn More': 'Learn More',
    'Donate Now': 'Donate Now',
    'Goal Details': 'Goal Details',
    'Partner Organization': 'Partner Organization',
    'No Title': 'No Title',
    'No description available': 'No description available.',
    'Donate to': 'Donate to ',
    'Support': 'Support ',
    'Donation Message': 'Your donation will help achieve this goal. Please proceed to the payment gateway.',
    'Proceed to Payment': 'Proceed to Payment',
    'Error opening payment page': 'Error opening payment page: ',
    'Failed to load page': 'Failed to load page: ',
  },
  'it': {
    'Sustainable Development Goals': 'Obiettivi di Sviluppo Sostenibile',
    'SDG Description': 'I 17 Obiettivi di Sviluppo Sostenibile (SDG) sono un invito universale all\'azione per porre fine alla povertà, proteggere il pianeta e garantire pace e prosperità per tutti.',
    'No goals found': 'Nessun obiettivo trovato.',
    'Error loading goals': 'Errore nel caricamento degli obiettivi: ',
    'Learn More': 'Scopri di più',
    'Donate Now': 'Dona ora',
    'Goal Details': 'Dettagli dell\'obiettivo',
    'Partner Organization': 'Organizzazione partner',
    'No Title': 'Nessun titolo',
    'No description available': 'Nessuna descrizione disponibile.',
    'Donate to': 'Dona a ',
    'Support': 'Supporta ',
    'Donation Message': 'La tua donazione aiuterà a raggiungere questo obiettivo. Procedi al gateway di pagamento.',
    'Proceed to Payment': 'Procedi al pagamento',
    'Error opening payment page': 'Errore nell\'apertura della pagina di pagamento: ',
    'Failed to load page': 'Impossibile caricare la pagina: ',
  },
  'de': {
    'Sustainable Development Goals': 'Ziele für nachhaltige Entwicklung',
    'SDG Description': 'Die 17 Ziele für nachhaltige Entwicklung (SDGs) sind ein universeller Aufruf zum Handeln, um Armut zu beenden, den Planeten zu schützen und Frieden und Wohlstand für alle zu gewährleisten.',
    'No goals found': 'Keine Ziele gefunden.',
    'Error loading goals': 'Fehler beim Laden der Ziele: ',
    'Learn More': 'Erfahre mehr',
    'Donate Now': 'Jetzt spenden',
    'Goal Details': 'Zieldetails',
    'Partner Organization': 'Partnerorganisation',
    'No Title': 'Kein Titel',
    'No description available': 'Keine Beschreibung verfügbar.',
    'Donate to': 'Spende an ',
    'Support': 'Unterstütze ',
    'Donation Message': 'Deine Spende hilft, dieses Ziel zu erreichen. Bitte fahre mit dem Zahlungsgateway fort.',
    'Proceed to Payment': 'Zum Zahlungsgateway',
    'Error opening payment page': 'Fehler beim Öffnen der Zahlungsseite: ',
    'Failed to load page': 'Seite konnte nicht geladen werden: ',
  },
  'fr': {
    'Sustainable Development Goals': 'Objectifs de Développement Durable',
    'SDG Description': 'Les 17 Objectifs de Développement Durable (ODD) sont un appel universel à l\'action pour mettre fin à la pauvreté, protéger la planète et garantir la paix et la prospérité pour tous.',
    'No goals found': 'Aucun objectif trouvé.',
    'Error loading goals': 'Erreur lors du chargement des objectifs : ',
    'Learn More': 'En savoir plus',
    'Donate Now': 'Faire un don maintenant',
    'Goal Details': 'Détails de l\'objectif',
    'Partner Organization': 'Organisation partenaire',
    'No Title': 'Aucun titre',
    'No description available': 'Aucune description disponible.',
    'Donate to': 'Faire un don à ',
    'Support': 'Soutenir ',
    'Donation Message': 'Votre don contribuera à atteindre cet objectif. Veuillez procéder au portail de paiement.',
    'Proceed to Payment': 'Passer au paiement',
    'Error opening payment page': 'Erreur lors de l\'ouverture de la page de paiement : ',
    'Failed to load page': 'Impossible de charger la page : ',
  },
};

void main() {
  runApp(HumanityApp());
}

class HumanityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Humanity Goals',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37), // Gold
            foregroundColor: Colors.black,
            textStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 2,
          ),
        ),
      ),
      home: HumanityGoalsScreen(),
    );
  }
}

class HumanityGoalsScreen extends StatefulWidget {
  @override
  _HumanityGoalsScreenState createState() => _HumanityGoalsScreenState();
}

class _HumanityGoalsScreenState extends State<HumanityGoalsScreen> {
  String selectedLanguage = 'en'; // Default language is English

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildLanguageSelector(screenWidth),
                const SizedBox(height: 16),
                Text(
                  translations[selectedLanguage]!['Sustainable Development Goals']!,
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  translations[selectedLanguage]!['SDG Description']!,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('humanity').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitFadingCircle(color: Color(0xFFD4AF37), size: 50),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${translations[selectedLanguage]!['Error loading goals']!}${snapshot.error}',
                          style: GoogleFonts.roboto(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          translations[selectedLanguage]!['No goals found']!,
                          style: GoogleFonts.roboto(color: Colors.grey),
                        ),
                      );
                    }

                    final goals = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HumanityGoalDetail(
                                  goal: goal,
                                  language: selectedLanguage,
                                ),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: FadeInImage(
                                        placeholder: const AssetImage('assets/placeholder.png'),
                                        placeholderErrorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const SpinKitFadingCircle(
                                              color: Color(0xFFD4AF37),
                                              size: 50,
                                            ),
                                          );
                                        },
                                        image: NetworkImage(goal['image'] ?? ''),
                                        fit: BoxFit.contain,
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error, color: Colors.red),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      goal['title_$selectedLanguage'] ?? goal['title'] ?? translations[selectedLanguage]!['No Title']!,
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(double screenWidth) {
    List<Map<String, String>> languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'fr', 'name': 'Français'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: languages.map((lang) {
          bool isSelected = selectedLanguage == lang['code'];
          return Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.02),
            child: GestureDetector(
              onTap: () => setState(() => selectedLanguage = lang['code']!),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Color(0xFFD4AF37), Colors.amberAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  lang['name']!,
                  style: GoogleFonts.roboto(
                    color: isSelected ? Colors.black : Colors.black87,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HumanityGoalDetail extends StatelessWidget {
  final Map<String, dynamic> goal;
  final String language;

  const HumanityGoalDetail({required this.goal, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    final padding = isLargeScreen
        ? 32.0
        : isTablet
            ? 24.0
            : isSmallScreen
                ? 12.0
                : 16.0;
    final titleFontSize = isLargeScreen
        ? 32.0
        : isTablet
            ? 28.0
            : isSmallScreen
                ? 20.0
                : 24.0;
    final descriptionFontSize = isLargeScreen
        ? 20.0
        : isTablet
            ? 18.0
            : isSmallScreen
                ? 14.0
                : 16.0;
    final imageHeight = isLargeScreen
        ? screenHeight * 0.4
        : isTablet
            ? screenHeight * 0.35
            : isSmallScreen
                ? 200.0
                : 250.0;
    final logoSize = isLargeScreen
        ? 200.0
        : isTablet
            ? 160.0
            : isSmallScreen
                ? 80.0
                : 120.0;
    final logoTitleFontSize = isLargeScreen
        ? 24.0
        : isTablet
            ? 20.0
            : isSmallScreen
                ? 16.0
                : 18.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          goal['title_$language'] ?? goal['title'] ?? translations[language]!['Goal Details']!,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/placeholder.png'),
                    placeholderErrorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const SpinKitFadingCircle(
                          color: Color(0xFFD4AF37),
                          size: 50,
                        ),
                      );
                    },
                    image: NetworkImage(goal['image'] ?? ''),
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                SizedBox(height: padding),
                Text(
                  goal['title_$language'] ?? goal['title'] ?? translations[language]!['No Title']!,
                  style: GoogleFonts.roboto(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: padding / 2),
                Text(
                  goal['description_$language'] ?? goal['description'] ?? translations[language]!['No description available']!,
                  style: GoogleFonts.roboto(
                    fontSize: descriptionFontSize,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: padding),
                Center(
                  child: Column(
                    children: [
                      Text(
                        goal['company_name_$language'] ?? goal['company_name'] ?? translations[language]!['Partner Organization']!,
                        style: GoogleFonts.roboto(
                          fontSize: logoTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: padding / 2),
                      FadeInImage(
                        placeholder: const AssetImage('assets/placeholder.png'),
                        placeholderErrorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: logoSize,
                            width: logoSize,
                            color: Colors.grey[300],
                            child: const SpinKitFadingCircle(
                              color: Color(0xFFD4AF37),
                              size: 50,
                            ),
                          );
                        },
                        image: NetworkImage(
                          goal['company_logo'] ??
                              'https://via.placeholder.com/150?text=Default+Logo',
                        ),
                        height: logoSize,
                        width: logoSize,
                        fit: BoxFit.contain,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://www.shutterstock.com/image-vector/missing-picture-page-website-design-mobile-1552421075',
                            height: logoSize,
                            width: logoSize,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: padding),
                if (goal['link'] != null && goal['link'].isNotEmpty)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(
                              url: goal['link'],
                              title: goal['title_$language'] ?? goal['title'] ?? translations[language]!['Learn More']!,
                            ),
                          ),
                        );
                      },
                      child: Text(translations[language]!['Learn More']!),
                    ),
                  ),
                SizedBox(height: padding),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationScreen(
                            goalTitle: goal['title_$language'] ?? goal['title'],
                            language: language,
                          ),
                        ),
                      );
                    },
                    child: Text(translations[language]!['Donate Now']!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({required this.url, required this.title});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${translations['en']!['Failed to load page']!}${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: SpinKitFadingCircle(
                color: Color(0xFFD4AF37),
                size: 50,
              ),
            ),
        ],
      ),
    );
  }
}

class DonationScreen extends StatelessWidget {
  final String? goalTitle;
  final String language;

  const DonationScreen({this.goalTitle, required this.language});

  Future<void> _launchStripePayment() async {
    const url = 'https://buy.stripe.com/5kA5msaRAghndvW296';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${translations[language]!['Donate to']!}${goalTitle ?? 'the Cause'}',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${translations[language]!['Support']!}${goalTitle ?? 'the Cause'}',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  translations[language]!['Donation Message']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _launchStripePayment();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${translations[language]!['Error opening payment page']!}$e')),
                      );
                    }
                  },
                  child: Text(translations[language]!['Proceed to Payment']!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}