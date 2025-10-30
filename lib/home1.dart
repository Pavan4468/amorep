import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'LearnVideo.dart';
import 'posts.dart';
import 'SearchPage.dart';
import 'humanity.dart';
import 'ECommercePage.dart';
import 'events_page.dart';
import 'CheapProductsPage.dart';
import 'CategoriesPage.dart';
import 'KidsProductsPage.dart';
import 'womens_page.dart';

// Translation maps for English, Italian, German, and French
const Map<String, Map<String, String>> translations = {
  'en': {
    'Popular': 'Popular',
    'Influencer': 'Influencer',
    'courses': 'Courses',
    'Cultural': 'Cultural',
    'Videos': 'Videos',
    'Posts': 'Posts',
    'Ads': 'Ads',
    'Users': 'Users',
    'SDGs': 'SDGs',
    'Categories': 'Categories',
    'Upcoming Events': 'Upcoming Events',
    'See More': 'See More',
    'No videos available': 'No videos available',
    'No posts available': 'No posts available',
    'No ads available': 'No ads available',
    'No users available': 'No users available',
    'No SDGs available': 'No SDGs available',
    'No events available': 'No events available',
    'Explore Now': 'Explore Now',
    'Men\'s Fashion': 'Men\'s Fashion',
    'Women\'s Fashion': 'Women\'s Fashion',
    'Kids\' Fashion': 'Kids\' Fashion',
    'Green Products': 'Green Products',
    'Could not open donation link': 'Could not open donation link',
    'Could not open URL': 'Could not open URL',
    'Check out this video!': 'Check out this video!',
    'Sustainable Development Goal': 'Sustainable Development Goal',
    'Trusted Companies': 'Trusted Companies',
    'Visit Website': 'Visit Website',
    'No Title': 'No Title',
    'No description available': 'No description available.',
    'Comments': 'Comments',
    'No comments yet. Be the first to comment!': 'No comments yet. Be the first to comment!',
    'Add a comment...': 'Add a comment...',
    'Add to Calendar': 'Add to Calendar',
    'Could not open Google Calendar': 'Could not open Google Calendar',
  },
  'it': {
    'Popular': 'Popolare',
    'Influencer': 'Influencer',
    'courses': 'Corsi',
    'Cultural': 'Culturale',
    'Videos': 'Video',
    'Posts': 'Post',
    'Ads': 'Annunci',
    'Users': 'Utenti',
    'SDGs': 'OSS',
    'Categories': 'Categorie',
    'Upcoming Events': 'Eventi in arrivo',
    'See More': 'Vedi altro',
    'No videos available': 'Nessun video disponibile',
    'No posts available': 'Nessun post disponibile',
    'No ads available': 'Nessun annuncio disponibile',
    'No users available': 'Nessun utente disponibile',
    'No SDGs available': 'Nessun OSS disponibile',
    'No events available': 'Nessun evento disponibile',
    'Explore Now': 'Esplora ora',
    'Men\'s Fashion': 'Moda uomo',
    'Women\'s Fashion': 'Moda donna',
    'Kids\' Fashion': 'Moda bambini',
    'Green Products': 'Prodotti Verdi',
    'Could not open donation link': 'Impossibile aprire il link per la donazione',
    'Could not open URL': 'Impossibile aprire l\'URL',
    'Check out this video!': 'Guarda questo video!',
    'Sustainable Development Goal': 'Obiettivo di sviluppo sostenibile',
    'Trusted Companies': 'Aziende fidate',
    'Visit Website': 'Visita il sito web',
    'No Title': 'Nessun titolo',
    'No description available': 'Nessuna descrizione disponibile.',
    'Comments': 'Commenti',
    'No comments yet. Be the first to comment!': 'Nessun commento ancora. Sii il primo a commentare!',
    'Add a comment...': 'Aggiungi un commento...',
    'Add to Calendar': 'Aggiungi al calendario',
    'Could not open Google Calendar': 'Impossibile aprire Google Calendar',
  },
  'de': {
    'Popular': 'Beliebt',
    'Influencer': 'Influencer',
    'courses': 'Kurse',
    'Cultural': 'Kulturell',
    'Videos': 'Videos',
    'Posts': 'Beiträge',
    'Ads': 'Anzeigen',
    'Users': 'Nutzer',
    'SDGs': 'SDGs',
    'Categories': 'Kategorien',
    'Upcoming Events': 'Bald Events',
    'See More': 'Mehr sehen',
    'No videos available': 'Keine Videos verfügbar',
    'No posts available': 'Keine Beiträge verfügbar',
    'No ads available': 'Keine Anzeigen verfügbar',
    'No users available': 'Keine Nutzer verfügbar',
    'No SDGs available': 'Keine SDGs verfügbar',
    'No events available': 'Keine Veranstaltungen verfügbar',
    'Explore Now': 'Jetzt erkunden',
    'Men\'s Fashion': 'Herrenmode',
    'Women\'s Fashion': 'Damenmode',
    'Kids\' Fashion': 'Kindermode',
    'Green Products': 'Grüne Produkte',
    'Could not open donation link': 'Spendenlink konnte nicht geöffnet werden',
    'Could not open URL': 'URL konnte nicht geöffnet werden',
    'Check out this video!': 'Schau dir dieses Video an!',
    'Sustainable Development Goal': 'Ziel für nachhaltige Entwicklung',
    'Trusted Companies': 'Vertrauenswürdige Unternehmen',
    'Visit Website': 'Website besuchen',
    'No Title': 'Kein Titel',
    'No description available': 'Keine Beschreibung verfügbar.',
    'Comments': 'Kommentare',
    'No comments yet. Be the first to comment!': 'Noch keine Kommentare. Sei der Erste, der kommentiert!',
    'Add a comment...': 'Einen Kommentar hinzufügen...',
    'Add to Calendar': 'Zum Kalender hinzufügen',
    'Could not open Google Calendar': 'Google Kalender konnte nicht geöffnet werden',
  },
  'fr': {
    'Popular': 'Populaire',
    'Influencer': 'Influenceur',
    'courses': 'Cours',
    'Cultural': 'Culturel',
    'Videos': 'Vidéos',
    'Posts': 'Publications',
    'Ads': 'Annonces',
    'Users': 'Utilisateurs',
    'SDGs': 'ODD',
    'Categories': 'Catégories',
    'Upcoming Events': 'À venir.',
    'See More': 'Voir plus',
    'No videos available': 'Aucune vidéo disponible',
    'No posts available': 'Aucune publication disponible',
    'No ads available': 'Aucune annonce disponible',
    'No users available': 'Aucun utilisateur disponible',
    'No SDGs available': 'Aucun ODD disponible',
    'No events available': 'Aucun événement disponible',
    'Explore Now': 'Explorer maintenant',
    'Men\'s Fashion': 'Mode homme',
    'Women\'s Fashion': 'Mode femme',
    'Kids\' Fashion': 'Mode enfants',
    'Green Products': 'Produits Verts',
    'Could not open donation link': 'Impossible d\'ouvrir le lien de don',
    'Could not open URL': 'Impossible d\'ouvrir l\'URL',
    'Check out this video!': 'Regardez cette vidéo !',
    'Sustainable Development Goal': 'Objectif de développement durable',
    'Trusted Companies': 'Entreprises de confiance',
    'Visit Website': 'Visiter le site web',
    'No Title': 'Aucun titre',
    'No description available': 'Aucune description disponible.',
    'Comments': 'Commentaires',
    'No comments yet. Be the first to comment!': 'Aucun commentaire pour l\'instant. Soyez le premier à commenter !',
    'Add a comment...': 'Ajouter un commentaire...',
    'Add to Calendar': 'Ajouter au calendrier',
    'Could not open Google Calendar': 'Impossible d\'ouvrir Google Calendar',
  },
};

void main() {
  runApp(MaterialApp(
    home: VideoScreen(),
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white, fontSize: 12),
        titleLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        labelMedium: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          textStyle: TextStyle(fontSize: 10),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          minimumSize: Size(0, 0),
        ),
      ),
    ),
  ));
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String selectedCategory = 'Popular';
  String selectedLanguage = 'en'; // Default language is English

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Men\'s Fashion',
      'image': 'https://plus.unsplash.com/premium_photo-1675130119426-0b2c2379a190?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzN8fG1lbnMlMjBmYXNoaW9ufGVufDB8fDB8fHww',
      'page': const CategoriesPage(),
    },
    {
      'name': 'Women\'s Fashion',
      'image': 'https://images.unsplash.com/photo-1651489337165-f0f62bc3fc9e?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHdvbWVucyUyMCUyMGZhc2hpb258ZW58MHx8MHx8fDA%3D',
      'page': const WomenProductsPage(),
    },
    {
      'name': 'Kids\' Fashion',
      'image': 'https://plus.unsplash.com/premium_photo-1661274061055-6f6d0f110ba6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGtpZHMlMjBmYXNoaW9ufGVufDB8fDB8fHww',
      'page': const KidsProductsPage(),
    },
    {
      'name': 'Green Products',
      'image': 'https://plus.unsplash.com/premium_photo-1664811569310-04a7c276df1c?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8ZW52aXJvbm1lbnR8ZW58MHx8MHx8fDA%3D',
      'page': const KidsProductsPage(), // Placeholder; replace with GreenProductsPage if defined
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLanguageSelector(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _buildCategorySelector(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['Videos']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LearnVideoPage()),
                  );
                }, screenWidth),
                _buildHorizontalVideoList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['Posts']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostsPage()),
                  );
                }, screenWidth),
                _buildPostsList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _sectionTitle(translations[selectedLanguage]!['Ads']!, null, screenWidth),
                _buildAdsList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['Users']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchTab()),
                  );
                }, screenWidth),
                _buildUsersList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['SDGs']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HumanityApp()),
                  );
                }, screenWidth),
                _buildSdgList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['Categories']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EShoppingHomePage()),
                  );
                }, screenWidth),
                _buildFashionCategoriesList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                _sectionTitle(translations[selectedLanguage]!['Upcoming Events']!, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsPage()),
                  );
                }, screenWidth),
                _buildUpcomingEventsList(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.04), // Increased gap after Upcoming Events
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
                          colors: [Colors.amber, Colors.amberAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[900]!],
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
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: screenWidth * 0.03,
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

  Widget _sectionTitle(String text, VoidCallback? onSeeMore, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (onSeeMore != null)
          TextButton(
            onPressed: onSeeMore,
            child: Text(
              translations[selectedLanguage]!['See More']!,
              style: TextStyle(
                color: Colors.amber,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySelector(double screenWidth) {
    List<String> categoryKeys = ['Popular', 'Influencer', 'courses', 'Cultural'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryKeys.map((category) {
          bool isSelected = selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.02),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Colors.amber, Colors.amberAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[900]!],
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
                  translations[selectedLanguage]![category]!,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: screenWidth * 0.03,
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

  Widget _buildHorizontalVideoList(double screenHeight, double screenWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.25,
        minHeight: 100,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('category', isEqualTo: selectedCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No videos available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var video = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return VideoCard(
                videoUrl: video['videoUrl'] ?? '',
                thumbnail: video['thumbnail'] ?? '',
                title: video['title'] ?? '',
                subtitle: video['subtitle'] ?? '',
                videoId: snapshot.data!.docs[index].id,
                screenWidth: screenWidth,
                language: selectedLanguage,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostsList(double screenHeight, double screenWidth) {
    final isLargeScreen = screenWidth >= 600;
    final cardWidth = isLargeScreen ? screenWidth * 0.45 : screenWidth * 0.4;
    final imageHeight = isLargeScreen ? screenHeight * 0.18 : screenHeight * 0.14;
    final fontSize = isLargeScreen ? screenWidth * 0.04 : screenWidth * 0.035;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.24, // Reduced height
        minHeight: 100,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No posts available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              post['id'] = snapshot.data!.docs[index].id;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(post: post, language: selectedLanguage),
                    ),
                  );
                },
                child: Container(
                  width: cardWidth,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.015), // Added spacing at the top
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post['image'] ?? '',
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.015),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                post['user'] ?? '',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenHeight * 0.005),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAdsList(double screenHeight, double screenWidth) {
    final isLargeScreen = screenWidth >= 600;
    final imageHeight = isLargeScreen ? screenHeight * 0.18 : screenHeight * 0.14;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.24, // Reduced height
        minHeight: 100,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No ads available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ad = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdDetailPage(ad: ad, language: selectedLanguage),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.4,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.015), // Added spacing at the top
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: ad['image'] ?? '',
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.015),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title'] ?? '',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUsersList(double screenHeight, double screenWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.15,
        minHeight: 80,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No users available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(user: user),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.22,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                        child: CachedNetworkImage(
                          imageUrl: user['profileImageUrl'] ?? '',
                          height: screenHeight * 0.08,
                          width: screenHeight * 0.08,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        user['username'] ?? '',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSdgList(double screenHeight, double screenWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.18,
        minHeight: 80,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('humanity').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No SDGs available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var sdg = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SdgDetailPage(sdg: sdg, language: selectedLanguage),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.27,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: sdg['image'] ?? '',
                          height: screenHeight * 0.08,
                          width: screenHeight * 0.08,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        sdg['title'] ?? '',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFashionCategoriesList(double screenHeight, double screenWidth) {
    final isLargeScreen = screenWidth >= 600;
    final imageHeight = isLargeScreen ? screenHeight * 0.18 : screenHeight * 0.14;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.28,
        minHeight: 120,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => category['page'],
                ),
              );
            },
            child: Container(
              width: screenWidth * 0.4,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.015), // Added spacing at the top
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: category['image'] ?? '',
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                      errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.015),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translations[selectedLanguage]![category['name']] ?? category['name'],
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          translations[selectedLanguage]!['Explore Now']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingEventsList(double screenHeight, double screenWidth) {
    final isLargeScreen = screenWidth >= 600;
    final imageHeight = isLargeScreen ? screenHeight * 0.18 : screenHeight * 0.14;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.24, // Reduced height
        minHeight: 100,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(translations[selectedLanguage]!['No events available']!, style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailPage(event: event, language: selectedLanguage),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.4,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.015), // Added spacing at the top
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: event['image'] ?? '',
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.015),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'] ?? '',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              event['location'] ?? '',
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.amber,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String videoId;
  final double screenWidth;
  final String language;

  VideoCard({
    required this.videoUrl,
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    required this.videoId,
    required this.screenWidth,
    required this.language,
  });

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    _checkLikeStatus();
  }

  void _checkLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .collection('likes')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          isLiked = doc.exists;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: widget.screenWidth * 0.5,
            margin: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.01),
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }
        var video = snapshot.data!.data() as Map<String, dynamic>;
        int likes = video['likes']?.toInt() ?? 0;
        int shares = video['shares']?.toInt() ?? 0;
        String views = video['views']?.toString() ?? '0';
        String time = video['time']?.toDate().toString() ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenVideoPage(videoUrl: widget.videoUrl),
              ),
            );
          },
          child: Container(
            width: widget.screenWidth * 0.5,
            margin: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.01),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _controller.value.isInitialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              Icon(
                                Icons.play_circle_fill,
                                color: Colors.amber.withOpacity(0.8),
                                size: widget.screenWidth * 0.1,
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(color: Colors.amber),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.white),
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(widget.screenWidth * 0.015),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: widget.screenWidth * 0.03,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: widget.screenWidth * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.amber,
                              size: widget.screenWidth * 0.05,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                if (isLiked) {
                                  await FirebaseFirestore.instance
                                      .collection('videos')
                                      .doc(widget.videoId)
                                      .collection('likes')
                                      .doc(user.uid)
                                      .delete();
                                  await FirebaseFirestore.instance
                                      .collection('videos')
                                      .doc(widget.videoId)
                                      .update({
                                    'likes': FieldValue.increment(-1),
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('videos')
                                      .doc(widget.videoId)
                                      .collection('likes')
                                      .doc(user.uid)
                                      .set({});
                                  await FirebaseFirestore.instance
                                      .collection('videos')
                                      .doc(widget.videoId)
                                      .update({
                                    'likes': FieldValue.increment(1),
                                  });
                                }
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: isLiked ? Colors.red : Colors.amber,
                                  size: widget.screenWidth * 0.05,
                                ),
                                SizedBox(width: widget.screenWidth * 0.01),
                                Text(
                                  likes.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(
                                  'https://buy.stripe.com/5kA5msaRAghndvW296');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(translations[widget.language]!['Could not open donation link']!),
                                    backgroundColor: Colors.amber,
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              Icons.volunteer_activism,
                              color: Colors.amber,
                              size: widget.screenWidth * 0.05,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Share.share(
                                '${widget.title}\n${widget.subtitle}\n${translations[widget.language]!['Check out this video!']} ${widget.videoUrl}',
                              );
                              FirebaseFirestore.instance
                                  .collection('videos')
                                  .doc(widget.videoId)
                                  .update({
                                'shares': FieldValue.increment(1),
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Colors.amber,
                                  size: widget.screenWidth * 0.05,
                                ),
                                SizedBox(width: widget.screenWidth * 0.01),
                                Text(
                                  shares.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.screenWidth * 0.03,
                                  ),
                                ),
                              ],
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
      },
    );
  }
}

class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPage({required this.videoUrl});

  @override
  _FullScreenVideoPageState createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    // Hide controls after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Center(
          child: _controller.value.isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (_showControls)
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white.withOpacity(0.8),
                            size: 64,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    if (_showControls)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.amber,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    if (_showControls)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                  ],
                )
              : CircularProgressIndicator(color: Colors.amber),
        ),
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final String language;

  PostDetailPage({required this.post, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(post['id'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.amber)),
          );
        }
        var updatedPost = snapshot.data!.data() as Map<String, dynamic>;
        updatedPost['id'] = snapshot.data!.id;
        bool isLiked = updatedPost['isLiked'] ?? false;
        int likes = updatedPost['likes']?.toInt() ?? 0;
        int commentsCount = updatedPost['commentsCount']?.toInt() ?? 0;
        List<dynamic> comments = updatedPost['comments'] ?? [];

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            title: Text(
              updatedPost['user'] ?? '',
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.amber),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: updatedPost['image'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
                  errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  updatedPost['content'] ?? '',
                  style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  "${translations[language]!['Comments']}: $commentsCount",
                  style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[400]),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(updatedPost['id'])
                            .update({
                          'isLiked': !isLiked,
                          'likes': isLiked
                              ? FieldValue.increment(-1)
                              : FieldValue.increment(1),
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.amber,
                            size: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            likes.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.amber, size: screenWidth * 0.05),
                      onPressed: () {
                        final TextEditingController commentController = TextEditingController();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              minChildSize: 0.4,
                              maxChildSize: 0.9,
                              builder: (context, scrollController) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                        width: screenWidth * 0.1,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD4AF37),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenHeight * 0.01,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${translations[language]!['Comments']} ($commentsCount)',
                                              style: TextStyle(
                                                color: Color(0xFFF5E6CC),
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, color: Color(0xFFD4AF37)),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(color: Color(0xFFD4AF37), height: 1),
                                      Expanded(
                                        child: comments.isEmpty
                                            ? Center(
                                                child: Text(
                                                  translations[language]!['No comments yet. Be the first to comment!']!,
                                                  style: TextStyle(
                                                    color: Color(0xFFF5E6CC),
                                                    fontSize: screenWidth * 0.04,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                controller: scrollController,
                                                padding: EdgeInsets.all(screenWidth * 0.04),
                                                itemCount: comments.length,
                                                itemBuilder: (context, commentIndex) {
                                                  final comment = comments[commentIndex];
                                                  return Padding(
                                                    padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: screenWidth * 0.04,
                                                          backgroundImage: CachedNetworkImageProvider(
                                                              comment['profile'] ?? 'https://i.pravatar.cc/150?img=0'),
                                                        ),
                                                        SizedBox(width: screenWidth * 0.02),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    comment['user'] ?? 'Anonymous',
                                                                    style: TextStyle(
                                                                      color: Color(0xFFF5E6CC),
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: screenWidth * 0.035,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    comment['time'] ?? 'Unknown',
                                                                    style: TextStyle(
                                                                      color: Color(0xFFD4AF37),
                                                                      fontSize: screenWidth * 0.025,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: screenHeight * 0.005),
                                                              Text(
                                                                comment['text'] ?? '',
                                                                style: TextStyle(
                                                                  color: Color(0xFFF5E6CC),
                                                                  fontSize: screenWidth * 0.032,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(screenWidth * 0.04),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          border: Border(top: BorderSide(color: Color(0xFFD4AF37))),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: commentController,
                                                style: TextStyle(color: Color(0xFFF5E6CC)),
                                                decoration: InputDecoration(
                                                  hintText: translations[language]!['Add a comment...'],
                                                  hintStyle: TextStyle(color: Color(0xFFD4AF37)),
                                                  filled: true,
                                                  fillColor: Colors.grey[900],
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            IconButton(
                                              icon: Icon(Icons.send, color: Color(0xFFD4AF37)),
                                              onPressed: () {
                                                if (commentController.text.trim().isNotEmpty) {
                                                  final user = FirebaseAuth.instance.currentUser;
                                                  final userName = user?.displayName ?? 'Anonymous';
                                                  final userProfile = user?.photoURL ?? 'https://i.pravatar.cc/150?img=0';
                                                  FirebaseFirestore.instance
                                                      .collection('posts')
                                                      .doc(updatedPost['id'])
                                                      .update({
                                                    'comments': FieldValue.arrayUnion([
                                                      {
                                                        'user': userName,
                                                        'profile': userProfile,
                                                        'text': commentController.text.trim(),
                                                        'time': 'Just now',
                                                      }
                                                    ]),
                                                    'commentsCount': FieldValue.increment(1),
                                                  });
                                                  commentController.clear();
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.amber, size: screenWidth * 0.05),
                      onPressed: () {
                        Share.share(
                          '${updatedPost['content']} ${translations[language]!['Check out this video!']} by ${updatedPost['user']} on AMO! ${updatedPost['image']}',
                          subject: translations[language]!['Check out this video!'],
                        );
                        FirebaseFirestore.instance
                            .collection('posts')
                            .doc(updatedPost['id'])
                            .update({
                          'shares': FieldValue.increment(1),
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdDetailPage extends StatelessWidget {
  final Map<String, dynamic> ad;
  final String language;

  AdDetailPage({required this.ad, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          ad['title'] ?? '',
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: ad['image'] ?? '',
              height: screenHeight * 0.25,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              ad['description'] ?? '',
              style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.015),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(ad['url'] ?? '');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translations[language]!['Could not open URL']!),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              },
              child: Text(
                ad['url'] ?? '',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: screenWidth * 0.03,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailPage({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final interests = List<String>.from(user['interests'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          user['username'] ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                imageUrl: user['profileImageUrl'] ??
                    'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              user['location'] ?? 'No Location',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildDetailTile(Icons.person, 'Username', user['username'] ?? ''),
            _buildDetailTile(Icons.work, 'Work', user['work'] ?? ''),
            _buildDetailTile(Icons.favorite, 'Relationship Status', user['relationshipStatus'] ?? ''),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Interests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: interests.map((interest) => _buildInterestChip(interest)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        value.isEmpty ? 'Not Set' : value,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

class SdgDetailPage extends StatelessWidget {
  final Map<String, dynamic> sdg;
  final String language;

  SdgDetailPage({required this.sdg, required this.language});

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
        ? 24.0
        : isTablet
            ? 20.0
            : isSmallScreen
                ? 16.0
                : 18.0;
    final descriptionFontSize = isLargeScreen
        ? 18.0
        : isTablet
            ? 16.0
            : isSmallScreen
                ? 14.0
                : 15.0;
    final imageHeight = isLargeScreen
        ? screenHeight * 0.3
        : isTablet
            ? screenHeight * 0.25
            : isSmallScreen
                ? screenHeight * 0.2
                : screenHeight * 0.25;
    final logoSize = isLargeScreen
        ? 150.0
        : isTablet
            ? 120.0
            : isSmallScreen
                ? 80.0
                : 100.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          sdg['title'] ?? translations[language]!['Sustainable Development Goal'],
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: sdg['image'] ?? '',
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.white,
                  size: screenWidth * 0.1,
                ),
              ),
            ),
            SizedBox(height: padding),
            Text(
              sdg['title'] ?? translations[language]!['No Title']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: padding / 2),
            Text(
              sdg['description'] ?? translations[language]!['No description available']!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: descriptionFontSize,
                height: 1.5,
              ),
            ),
            SizedBox(height: padding),
            Center(
              child: Column(
                children: [
                  Text(
                    translations[language]!['Trusted Companies']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: padding / 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: sdg['company_logo'] ??
                          'https://via.placeholder.com/150?text=Default+Logo',
                      height: logoSize * 1.6,
                      width: logoSize * 1.6,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        'https://www.shutterstock.com/image-vector/missing-picture-page-website-design-1552421075',
                        height: logoSize * 1.3,
                        width: logoSize * 1.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: padding),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final url = Uri.parse(sdg['link'] ?? '');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(translations[language]!['Could not open URL']!),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  }
                },
                child: Text(
                  translations[language]!['Visit Website']!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;
  final String language;

  EventDetailPage({required this.event, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          event['name'] ?? '',
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: event['image'] ?? '',
              height: screenHeight * 0.25,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(color: Colors.amber),
              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              event['description'] ?? '',
              style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              "Date: ${event['date'] ?? ''}",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Time: ${event['time'] ?? ''}",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Location: ${event['location'] ?? ''}",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(event['link'] ?? '');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translations[language]!['Could not open URL']!),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              },
              child: Text(
                event['link'] ?? '',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: screenWidth * 0.03,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            ElevatedButton(
              onPressed: () async {
                final String eventName = event['name'] ?? '';
                final String eventDate = event['date'] ?? '';
                final String eventDescription = event['description'] ?? '';
                final String formattedDate = eventDate.replaceAll('-', '');
                final String calendarUrl =
                    'https://www.google.com/calendar/render?action=TEMPLATE'
                    '&text=${Uri.encodeComponent(eventName)}'
                    '&dates=${formattedDate}/${formattedDate}'
                    '&details=${Uri.encodeComponent(eventDescription)}';
                final Uri url = Uri.parse(calendarUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translations[language]!['Could not open Google Calendar']!),
                      backgroundColor: Colors.amber,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                translations[language]!['Add to Calendar']!,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}