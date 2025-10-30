import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

const Map<String, Map<String, String>> translations = {
  'en': {
    'SDGs': 'SDGs',
    'Sustainable Development Goals': 'Sustainable Development Goals',
    'SDG Description': 'The 17 Sustainable Development Goals (SDGs) are a universal call to action to end poverty, protect the planet, and ensure peace and prosperity for all.',
    'No goals found': 'No goals found.',
    'Error loading goals': 'Error loading goals: ',
    'Learn More': 'Learn More',
    'Donate Now': 'Donate on their website',
    'Goal Details': 'Goal Details',
    'Partner Organization': 'Partner Organization',
    'No Title': 'No Title',
    'No description available': 'No description available.',
    'Switch to Italian': 'Switch to Italian',
    'Switch to English': 'Switch to English',
  },
  'it': {
    'SDGs': 'OSS',
    'Sustainable Development Goals': 'Obiettivi di Sviluppo Sostenibile',
    'SDG Description': 'I 17 Obiettivi di Sviluppo Sostenibile (SDG) sono un invito universale all\'azione per porre fine alla povertà, proteggere il pianeta e garantire pace e prosperità per tutti.',
    'No goals found': 'Nessun obiettivo trovato.',
    'Error loading goals': 'Errore nel caricamento degli obiettivi: ',
    'Learn More': 'Scopri di più',
    'Donate Now': 'Dona sul loro sito web',
    'Goal Details': 'Dettagli dell\'obiettivo',
    'Partner Organization': 'Organizzazione partner',
    'No Title': 'Nessun titolo',
    'No description available': 'Nessuna descrizione disponibile.',
    'Switch to Italian': 'Passa all\'Italiano',
    'Switch to English': 'Passa all\'Inglese',
  },
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 3,
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
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          translations[selectedLanguage]!['SDGs']!,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildLanguageSelector(screenWidth),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B46C1), Color(0xFF4C2E8A)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translations[selectedLanguage]!['Sustainable Development Goals']!,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translations[selectedLanguage]!['SDG Description']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('humanity').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitFadingCircle(color: Color(0xFF6B46C1), size: 50),
                      );
                    }
                    if (snapshot.hasError) {
                      print('Firestore error: ${snapshot.error}');
                      return Center(
                        child: Text(
                          '${translations[selectedLanguage]!['Error loading goals']!}${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          translations[selectedLanguage]!['No goals found']!,
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      );
                    }

                    final goals = snapshot.data!.docs;
                    print('Fetched ${goals.length} goals');

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 600 ? 2 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: screenWidth > 600 ? 0.9 : 0.7,
                      ),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index].data() as Map<String, dynamic>;
                        print('Goal data: $goal');
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
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: screenHeight * 0.35,
                                        minHeight: screenHeight * 0.3,
                                      ),
                                      child: FadeInImage(
                                        placeholder: const AssetImage('assets/placeholder.png'),
                                        placeholderErrorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            constraints: BoxConstraints(
                                              maxHeight: screenHeight * 0.35,
                                              minHeight: screenHeight * 0.3,
                                            ),
                                            color: Colors.grey[200],
                                            child: const SpinKitFadingCircle(
                                              color: Color(0xFF6B46C1),
                                              size: 50,
                                            ),
                                          );
                                        },
                                        image: NetworkImage(goal['image'] ?? ''),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            constraints: BoxConstraints(
                                              maxHeight: screenHeight * 0.35,
                                              minHeight: screenHeight * 0.3,
                                            ),
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.error, color: Colors.red),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal['title_$selectedLanguage'] ??
                                              goal['title'] ??
                                              translations[selectedLanguage]!['No Title']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          translations[selectedLanguage]!['Donate Now']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.amber[700],
                                          ),
                                        ),
                                      ],
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
      {'code': 'en', 'name': 'EN'},
      {'code': 'it', 'name': 'IT'},
    ];
    return PopupMenuButton<String>(
      initialValue: selectedLanguage,
      onSelected: (String value) {
        setState(() {
          selectedLanguage = value;
          print('Language changed to: $value');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6B46C1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              languages.firstWhere((lang) => lang['code'] == selectedLanguage)['name']!,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => languages.map((lang) {
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Text(
            lang['name']!,
            style: GoogleFonts.poppins(
              color: selectedLanguage == lang['code'] ? const Color(0xFF6B46C1) : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HumanityGoalDetail extends StatefulWidget {
  final Map<String, dynamic> goal;
  final String language;

  const HumanityGoalDetail({required this.goal, required this.language});

  @override
  _HumanityGoalDetailState createState() => _HumanityGoalDetailState();
}

class _HumanityGoalDetailState extends State<HumanityGoalDetail> {
  late String currentLanguage;

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.language;
  }

  void toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == 'en' ? 'it' : 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    final padding = isLargeScreen ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isLargeScreen ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final descriptionFontSize = isLargeScreen ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final imageHeight = isLargeScreen ? screenHeight * 0.4 : isTablet ? screenHeight * 0.35 : isSmallScreen ? 200.0 : 250.0;
    final logoSize = isLargeScreen ? 200.0 : isTablet ? 160.0 : isSmallScreen ? 80.0 : 120.0;
    final logoTitleFontSize = isLargeScreen ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.goal['title_$currentLanguage'] ?? widget.goal['title'] ?? translations[currentLanguage]!['Goal Details']!,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: toggleLanguage,
              child: Text(
                translations[currentLanguage]![currentLanguage == 'en' ? 'Switch to Italian' : 'Switch to English']!,
                style: GoogleFonts.poppins(
                  color: Colors.amber[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B46C1), Color(0xFF4C2E8A)],
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
                          color: Color(0xFF6B46C1),
                          size: 50,
                        ),
                      );
                    },
                    image: NetworkImage(widget.goal['image'] ?? ''),
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
                  widget.goal['title_$currentLanguage'] ?? widget.goal['title'] ?? translations[currentLanguage]!['No Title']!,
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: padding / 2),
                Text(
                  widget.goal['description_$currentLanguage'] ?? widget.goal['description'] ?? translations[currentLanguage]!['No description available']!,
                  style: GoogleFonts.poppins(
                    fontSize: descriptionFontSize,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: padding),
                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.goal['company_name_$currentLanguage'] ?? widget.goal['company_name'] ?? translations[currentLanguage]!['Partner Organization']!,
                        style: GoogleFonts.poppins(
                          fontSize: logoTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                              color: Color(0xFF6B46C1),
                              size: 50,
                            ),
                          );
                        },
                        image: NetworkImage(
                          widget.goal['company_logo'] ?? 'https://via.placeholder.com/150?text=Default+Logo',
                        ),
                        height: logoSize,
                        width: logoSize,
                        fit: BoxFit.contain,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://via.placeholder.com/150?text=Default+Logo',
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
                if (widget.goal['link'] != null && widget.goal['link'].isNotEmpty)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          translations[currentLanguage]!['Donate Now']!,
                          style: GoogleFonts.poppins(
                            fontSize: descriptionFontSize,
                            color: Colors.amber[700],
                          ),
                        ),
                        SizedBox(height: padding / 2),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  url: widget.goal['link'],
                                  title: widget.goal['title_$currentLanguage'] ?? widget.goal['title'] ?? translations[currentLanguage]!['Learn More']!,
                                ),
                              ),
                            );
                          },
                          child: Text(translations[currentLanguage]!['Learn More']!),
                        ),
                      ],
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
              SnackBar(content: Text('Failed to load page: ${error.description}')),
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
          style: GoogleFonts.poppins(
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
                color: Color(0xFF6B46C1),
                size: 50,
              ),
            ),
        ],
      ),
    );
  }
}