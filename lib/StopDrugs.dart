import 'package:flutter/material.dart';

class StopDrugsPage extends StatefulWidget {
  @override
  _StopDrugsPageState createState() => _StopDrugsPageState();
}

class _StopDrugsPageState extends State<StopDrugsPage> {
  String _selectedLanguage = 'English';

  // Translation map for different languages
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'title': 'Stop Drugs',
      'hero_text': 'Break Free Today',
      'why_avoid': 'Why Avoid Drugs?',
      'why_avoid_text': 'Drugs can trap you in addiction, harm your body, and steal your future. Take control and choose health.',
      'health_dangers': 'Health Dangers',
      'heart_damage': 'Heart Damage',
      'heart_damage_text': 'Risk of high blood pressure, heart attacks, and strokes.',
      'lung_issues': 'Lung Issues',
      'lung_issues_text': 'Chronic cough, breathing problems, and lung cancer.',
      'liver_harm': 'Liver Harm',
      'liver_harm_text': 'Cirrhosis, liver failure, and digestive complications.',
      'stay_strong': 'Stay Strong: Tips',
      'find_passion': 'Find Your Passion',
      'find_passion_text': 'Dive into hobbies or connect with positive friends.',
      'ease_stress': 'Ease Stress',
      'ease_stress_text': 'Run, meditate, or enjoy a movie instead of drugs.',
      'talk_it_out': 'Talk It Out',
      'talk_it_out_text': 'Share your feelings with someone you trust.',
      'learn_more': 'Learn more about',
    },
    'Italian': {
      'title': 'Smetti con le Droghe',
      'hero_text': 'Liberati Oggi',
      'why_avoid': 'Perché Evitare le Droghe?',
      'why_avoid_text': 'Le droghe possono intrappolarti nella dipendenza, danneggiare il tuo corpo e rubarti il futuro. Prendi il controllo e scegli la salute.',
      'health_dangers': 'Pericoli per la Salute',
      'heart_damage': 'Danno Cardiaco',
      'heart_damage_text': 'Rischio di ipertensione, infarti e ictus.',
      'lung_issues': 'Problemi Polmonari',
      'lung_issues_text': 'Tosse cronica, problemi respiratori e cancro ai polmoni.',
      'liver_harm': 'Danno Epatico',
      'liver_harm_text': 'Cirrosi, insufficienza epatica e complicazioni digestive.',
      'stay_strong': 'Rimani Forte: Consigli',
      'find_passion': 'Trova la Tua Passione',
      'find_passion_text': 'Immergiti negli hobby o connettiti con amici positivi.',
      'ease_stress': 'Allevia lo Stress',
      'ease_stress_text': 'Corri, medita o guarda un film invece di usare droghe.',
      'talk_it_out': 'Parlane',
      'talk_it_out_text': 'Condividi i tuoi sentimenti con qualcuno di cui ti fidi.',
      'learn_more': 'Scopri di più su',
    },
    'German': {
      'title': 'Drogen Stoppen',
      'hero_text': 'Befreie Dich Heute',
      'why_avoid': 'Warum Drogen Vermeiden?',
      'why_avoid_text': 'Drogen können dich in die Sucht treiben, deinen Körper schädigen und deine Zukunft stehlen. Übernimm die Kontrolle und wähle Gesundheit.',
      'health_dangers': 'Gesundheitsrisiken',
      'heart_damage': 'Herzschäden',
      'heart_damage_text': 'Risiko von Bluthochdruck, Herzinfarkten und Schlaganfällen.',
      'lung_issues': 'Lungenprobleme',
      'lung_issues_text': 'Chronischer Husten, Atemprobleme und Lungenkrebs.',
      'liver_harm': 'Leberschäden',
      'liver_harm_text': 'Zirrhose, Leberversagen und Verdauungsprobleme.',
      'stay_strong': 'Bleib Stark: Tipps',
      'find_passion': 'Finde Deine Leidenschaft',
      'find_passion_text': 'Tauche in Hobbys ein oder verbinde dich mit positiven Freunden.',
      'ease_stress': 'Stress Abbauen',
      'ease_stress_text': 'Laufe, meditiere oder schaue einen Film anstelle von Drogen.',
      'talk_it_out': 'Sprich Darüber',
      'talk_it_out_text': 'Teile deine Gefühle mit jemandem, dem du vertraust.',
      'learn_more': 'Erfahre mehr über',
    },
    'French': {
      'title': 'Arrêter les Drogues',
      'hero_text': 'Libérez-vous Aujourd\'hui',
      'why_avoid': 'Pourquoi Éviter les Drogues ?',
      'why_avoid_text': 'Les drogues peuvent vous piéger dans la dépendance, nuire à votre corps et voler votre avenir. Prenez le contrôle et choisissez la santé.',
      'health_dangers': 'Dangers pour la Santé',
      'heart_damage': 'Dommages Cardiaques',
      'heart_damage_text': 'Risque d\'hypertension, de crises cardiaques et d\'accidents vasculaires cérébraux.',
      'lung_issues': 'Problèmes Pulmonaires',
      'lung_issues_text': 'Toux chronique, problèmes respiratoires et cancer du poumon.',
      'liver_harm': 'Dommages au Foie',
      'liver_harm_text': 'Cirrhose, insuffisance hépatique et complications digestives.',
      'stay_strong': 'Restez Fort : Conseils',
      'find_passion': 'Trouvez Votre Passion',
      'find_passion_text': 'Plongez dans des hobbies ou connectez-vous avec des amis positifs.',
      'ease_stress': 'Réduisez le Stress',
      'ease_stress_text': 'Courez, méditez ou regardez un film au lieu de consommer des drogues.',
      'talk_it_out': 'Parlez-en',
      'talk_it_out_text': 'Partagez vos sentiments avec quelqu\'un en qui vous avez confiance.',
      'learn_more': 'En savoir plus sur',
    },
  };

  @override
  Widget build(BuildContext context) {
    final translations = _translations[_selectedLanguage]!;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: Text(
      //     translations['title']!,
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 24,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.red[900]!, Colors.red[600]!],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selection Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['English', 'Italian', 'German', 'French'].map((language) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedLanguage = language;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedLanguage == language ? Colors.red[600] : Colors.grey[300],
                          foregroundColor: _selectedLanguage == language ? Colors.white : Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          language,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 28),

              // Hero Image Section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.network(
                        'https://ranchcreekrecovery.com/wp-content/uploads/2015/11/ina-4.jpg',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: Center(child: CircularProgressIndicator(color: Colors.red[600])),
                          );
                        },
                      ),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            translations['hero_text']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 28),

              // Disadvantages Section
              Text(
                translations['why_avoid']!,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: Text(
                  translations['why_avoid_text']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 28),

              // Health Risks Section
              Text(
                translations['health_dangers']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 12),
              HealthRiskTile(
                title: translations['heart_damage']!,
                subtitle: translations['heart_damage_text']!,
                icon: Icons.favorite,
                color: Colors.red[600]!,
              ),
              HealthRiskTile(
                title: translations['lung_issues']!,
                subtitle: translations['lung_issues_text']!,
                icon: Icons.cloud,
                color: Colors.blue[600]!,
              ),
              HealthRiskTile(
                title: translations['liver_harm']!,
                subtitle: translations['liver_harm_text']!,
                icon: Icons.local_hospital,
                color: Colors.orange[600]!,
              ),

              SizedBox(height: 28),

              // Prevention Tips Section
              Text(
                translations['stay_strong']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 12),
              PreventionTipTile(
                title: translations['find_passion']!,
                subtitle: translations['find_passion_text']!,
                color: Colors.red[600]!,
              ),
              PreventionTipTile(
                title: translations['ease_stress']!,
                subtitle: translations['ease_stress_text']!,
                color: Colors.blue[600]!,
              ),
              PreventionTipTile(
                title: translations['talk_it_out']!,
                subtitle: translations['talk_it_out_text']!,
                color: Colors.orange[600]!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Widget for Health Risks
class HealthRiskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  HealthRiskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_StopDrugsPageState()._translations[_StopDrugsPageState()._selectedLanguage]!['learn_more']} $title')),
          );
        },
      ),
    );
  }
}

// Custom Widget for Prevention Tips
class PreventionTipTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  PreventionTipTile({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.star, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ),
    );
  }
}