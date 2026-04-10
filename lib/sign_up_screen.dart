import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_in_screen.dart';
import 'home_screen1.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form field controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _workingStatusController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hierarchical location data
  final Map<String, Map<String, List<String>>> _locations = {
    'Italy': {
      'Lombardia': ['Milano', 'Brescia', 'Monza', 'Bergamo', 'Como', 'Pavia', 'Varese', 'Cremona', 'Lecco'],
      'Lazio': ['Roma', 'Latina', 'Fiumicino', 'Guidonia Montecelio', 'Viterbo', 'Tivoli', 'Civitavecchia'],
      'Campania': ['Napoli', 'Salerno', 'Torre del Greco', 'Giugliano in Campania', 'Caserta', 'Benevento', 'Avellino'],
      'Veneto': ['Venezia', 'Verona', 'Padova', 'Vicenza', 'Treviso', 'Rovigo', 'Belluno'],
      'Piemonte': ['Torino', 'Novara', 'Alessandria', 'Asti', 'Cuneo', 'Biella', 'Vercelli'],
      'Toscana': ['Firenze', 'Pisa', 'Livorno', 'Arezzo', 'Siena', 'Lucca', 'Grosseto'],
      'Sicilia': ['Palermo', 'Catania', 'Messina', 'Siracusa', 'Trapani', 'Ragusa', 'Agrigento'],
      'Emilia-Romagna': ['Bologna', 'Parma', 'Modena', 'Ferrara', 'Rimini', 'Reggio Emilia', 'Piacenza'],
      'Puglia': ['Bari', 'Taranto', 'Lecce', 'Brindisi', 'Foggia', 'Barletta', 'Andria'],
      'Calabria': ['Reggio Calabria', 'Catanzaro', 'Cosenza', 'Crotone', 'Lamezia Terme'],
      'Liguria': ['Genova', 'La Spezia', 'Savona', 'Imperia'],
      'Sardegna': ['Cagliari', 'Sassari', 'Olbia', 'Oristano', 'Nuoro'],
      'Trentino-Alto Adige': ['Trento', 'Bolzano', 'Merano', 'Bressanone'],
      'Umbria': ['Perugia', 'Terni', 'Foligno', 'Spoleto'],
      'Marche': ['Ancona', 'Pesaro', 'Urbino', 'Macerata', 'Ascoli Piceno'],
      'Abruzzo': ["L'Aquila", 'Pescara', 'Chieti', 'Teramo'],
      'Basilicata': ['Potenza', 'Matera'],
      'Molise': ['Campobasso', 'Isernia'],
      "Valle d'Aosta": ['Aosta'],
      'Friuli-Venezia Giulia': ['Trieste', 'Udine', 'Pordenone', 'Gorizia'],
    },
    'Switzerland': {
      'Zurich': ['Zurich', 'Winterthur', 'Uster', 'Dübendorf', 'Dietikon'],
      'Geneva': ['Geneva', 'Vernier', 'Lancy', 'Meyrin', 'Carouge'],
      'Bern': ['Bern', 'Thun', 'Köniz', 'Biel/Bienne', 'Ostermundigen'],
      'Vaud': ['Lausanne', 'Yverdon-les-Bains', 'Montreux', 'Nyon', 'Vevey'],
      'Ticino': ['Lugano', 'Bellinzona', 'Locarno', 'Mendrisio', 'Chiasso'],
      'Basel-Stadt': ['Basel', 'Riehen', 'Bettingen'],
      'Aargau': ['Aarau', 'Wettingen', 'Baden', 'Zofingen', 'Lenzburg'],
      'St. Gallen': ['St. Gallen', 'Rapperswil-Jona', 'Wil', 'Gossau', 'Uzwil'],
      'Lucerne': ['Lucerne', 'Emmen', 'Kriens', 'Horw', 'Sursee'],
      'Valais': ['Sion', 'Sierre', 'Brig-Glis', 'Martigny', 'Monthey'],
    },
    'India': {
      'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool'],
      'Arunachal Pradesh': ['Itanagar', 'Tawang', 'Pasighat', 'Ziro'],
      'Assam': ['Guwahati', 'Dibrugarh', 'Silchar', 'Jorhat', 'Tezpur'],
      'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga'],
      'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg'],
      'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
      'Haryana': ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Hisar'],
      'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala', 'Solan', 'Mandi'],
      'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'],
      'Karnataka': ['Bangalore', 'Mysore', 'Mangalore', 'Hubli', 'Belgaum'],
      'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam'],
      'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
      'Manipur': ['Imphal', 'Thoubal', 'Churachandpur'],
      'Meghalaya': ['Shillong', 'Tura', 'Nongstoin'],
      'Mizoram': ['Aizawl', 'Lunglei', 'Champhai'],
      'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
      'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Sambalpur'],
      'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
      'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
      'Sikkim': ['Gangtok', 'Namchi', 'Gyalshing'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli'],
      'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam', 'Karimnagar'],
      'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
      'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Varanasi', 'Agra', 'Noida'],
      'Uttarakhand': ['Dehradun', 'Haridwar', 'Nainital', 'Rishikesh', 'Haldwani'],
      'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri', 'Asansol'],
    },
  };

  // Dropdown selections
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedGender;

  // Gender options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Interests multi-select
  List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    'Technology',
    'Finance',
    'Travel',
    'Fitness',
    'Music',
    'Art',
    'Food',
    'Gaming',
    'Books',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
    _animationController.forward();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a country'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a region'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a city'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a gender'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one interest'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    int? age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must be at least 18 to sign up'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'income': _incomeController.text.trim(),
        'country': _selectedCountry,
        'region': _selectedRegion,
        'city': _selectedCity,
        'gender': _selectedGender,
        'workingStatus': _workingStatusController.text.trim(),
        'age': _ageController.text.trim(),
        'interests': _selectedInterests,
        'name': _usernameController.text.trim(), // For ProfilePage compatibility
        'location': '$_selectedCity, $_selectedRegion, $_selectedCountry', // For ProfilePage compatibility
        'work': _workingStatusController.text.trim(), // For ProfilePage compatibility
        'relationshipStatus': '', // Default empty for ProfilePage
        'profileImageUrl': '', // Default empty, updated in ProfilePage if image is uploaded
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );

      // Navigate to MainPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration failed: Network error'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    // Define responsive values
    final double horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
    final double verticalPadding = screenWidth < 360 ? 16.0 : 24.0;
    final double fontSizeTitle = screenWidth < 360 ? 24.0 : 28.0;
    final double fontSizeSubtitle = screenWidth < 360 ? 14.0 : 16.0;
    final double fontSizeField = screenWidth < 360 ? 14.0 : 16.0;
    final double logoSize = screenWidth < 360 ? 100.0 : 120.0;
    final double spacing = screenWidth < 360 ? 12.0 : 16.0;
    final double buttonFontSize = screenWidth < 360 ? 16.0 : 18.0;
    final double buttonHeight = screenWidth < 360 ? 45.0 : 50.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/dove.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: SingleChildScrollView(
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenWidth < 360 ? 30.0 : 40.0),
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/fibo.jpg',
                          height: logoSize,
                          width: logoSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Join the journey to get started',
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth < 360 ? 30.0 : 40.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: TextFormField(
                              controller: _usernameController,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                                hintText: 'Username',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                                hintText: 'Email',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: TextFormField(
                              controller: _incomeController,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                                hintText: 'Monthly Income',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your income';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.public, color: Colors.blue),
                                hintText: 'Country',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              items: _locations.keys.map((String country) {
                                return DropdownMenuItem<String>(
                                  value: country,
                                  child: Text(country, style: TextStyle(color: Colors.black, fontSize: fontSizeField)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCountry = newValue;
                                  _selectedRegion = null; // Reset region when country changes
                                  _selectedCity = null; // Reset city when country changes
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a country';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 450),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRegion,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.map, color: Colors.blue),
                                hintText: 'Region',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              items: _selectedCountry != null
                                  ? _locations[_selectedCountry]!.keys.map((String region) {
                                      return DropdownMenuItem<String>(
                                        value: region,
                                        child: Text(region, style: TextStyle(color: Colors.black, fontSize: fontSizeField)),
                                      );
                                    }).toList()
                                  : [],
                              onChanged: (String? newValue) {
                                if (_selectedCountry == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please select a country first'),
                                      backgroundColor: Colors.grey[900],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _selectedRegion = newValue;
                                  _selectedCity = null; // Reset city when region changes
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a region';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCity,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.location_city, color: Colors.blue),
                                hintText: 'City',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              items: _selectedCountry != null && _selectedRegion != null
                                  ? _locations[_selectedCountry]![_selectedRegion]!.map((String city) {
                                      return DropdownMenuItem<String>(
                                        value: city,
                                        child: Text(city, style: TextStyle(color: Colors.black, fontSize: fontSizeField)),
                                      );
                                    }).toList()
                                  : [],
                              onChanged: (String? newValue) {
                                if (_selectedCountry == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please select a country first'),
                                      backgroundColor: Colors.grey[900],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  );
                                  return;
                                }
                                if (_selectedRegion == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please select a region first'),
                                      backgroundColor: Colors.grey[900],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _selectedCity = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a city';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 550),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
                                hintText: 'Gender',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              items: _genders.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender, style: TextStyle(color: Colors.black, fontSize: fontSizeField)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a gender';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: TextFormField(
                              controller: _workingStatusController,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.work, color: Colors.blue),
                                hintText: 'Working Status',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your working status';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 650),
                            child: TextFormField(
                              controller: _ageController,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.cake, color: Colors.blue),
                                hintText: 'Age',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your age';
                                }
                                int? age = int.tryParse(value.trim());
                                if (age == null) {
                                  return 'Please enter a valid age';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 700),
                            child: Container(
                              padding: EdgeInsets.all(spacing),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Interests',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: fontSizeField,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: screenWidth < 360 ? 8.0 : 10.0,
                                    runSpacing: screenWidth < 360 ? 8.0 : 10.0,
                                    children: _availableInterests.map((interest) {
                                      bool isSelected = _selectedInterests.contains(interest);
                                      return ChoiceChip(
                                        label: Text(interest, style: TextStyle(fontSize: fontSizeField - 2)),
                                        selected: isSelected,
                                        selectedColor: Colors.blue,
                                        backgroundColor: Colors.grey[300],
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: Colors.blue),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth < 360 ? 8.0 : 12.0,
                                          vertical: screenWidth < 360 ? 6.0 : 8.0,
                                        ),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedInterests.add(interest);
                                            } else {
                                              _selectedInterests.remove(interest);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 750),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: Colors.black, fontSize: fontSizeField),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                hintText: 'Password',
                                hintStyle: TextStyle(fontSize: fontSizeField),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing + 4),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: spacing + 8),
                          FadeInUp(
                            delay: const Duration(milliseconds: 800),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.blue,
                                    strokeWidth: 3,
                                  )
                                : ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: spacing),
                                      minimumSize: Size(double.infinity, buttonHeight),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: spacing),
                          FadeInUp(
                            delay: const Duration(milliseconds: 900),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                                );
                              },
                              child: Text(
                                'Already have an account? Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeField,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    _workingStatusController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}