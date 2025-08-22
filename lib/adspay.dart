import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:url_launcher/url_launcher.dart';

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfn63u46n',
    'PavanReddy',
    cache: false,
  );

  Future<String?> uploadFile(File file) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: file.path.endsWith('.mp4')
              ? CloudinaryResourceType.Video
              : CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}

class AdPay extends StatefulWidget {
  const AdPay({Key? key}) : super(key: key);

  @override
  _AdPayState createState() => _AdPayState();
}

class _AdPayState extends State<AdPay> {
  bool _isLoading = false;
  bool _isPaymentCompleted = false;
  File? _mediaFile;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _contributionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tutorialController = TextEditingController();
  String? _targetedAudience;
  String? _targetedGender;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final String _stripePaymentUrl = 'https://buy.stripe.com/cN28yEcZIghn4Zq6op';

  // Location data
  List<String> _selectedCountries = [];
  List<String> _selectedRegions = [];
  List<String> _selectedCities = [];

  final Map<String, Map<String, List<String>>> _locationData = {
    'Italia': {
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

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.amber),
              title: Text(
                'Pick Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * (MediaQuery.of(context).size.width / 400),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _mediaFile = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_collection, color: Colors.amber),
              title: Text(
                'Pick Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * (MediaQuery.of(context).size.width / 400),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _mediaFile = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPayment() async {
    final Uri url = Uri.parse(_stripePaymentUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        setState(() {
          _isPaymentCompleted = true;
        });
        Fluttertoast.showToast(msg: 'Payment page opened. Complete payment to proceed.');
      } else {
        Fluttertoast.showToast(msg: 'Could not launch payment page.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Payment error: $e');
    }
  }

  Future<String?> _uploadMediaToCloudinary() async {
    if (_mediaFile == null) return null;
    try {
      final mediaUrl = await _storageService.uploadFile(_mediaFile!);
      if (mediaUrl == null) {
        Fluttertoast.showToast(msg: 'Failed to upload media.');
      }
      return mediaUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Upload error: $e');
      return null;
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() ||
        _mediaFile == null ||
        _selectedCountries.isEmpty ||
        _selectedRegions.isEmpty ||
        _selectedCities.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Please complete all fields, upload media, and select at least one country, region, and city.');
      return;
    }

    if (!_isPaymentCompleted) {
      await _launchPayment();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final mediaUrl = await _uploadMediaToCloudinary();
    if (mediaUrl == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('adspayment').add({
        'name': _nameController.text,
        'email': _emailController.text,
        'contact': _contactController.text,
        'address': _addressController.text,
        'contribution_amount': double.tryParse(_contributionController.text) ?? 0.0,
        'website': _websiteController.text,
        'username': _usernameController.text,
        'description': _descriptionController.text,
        'tutorial': _tutorialController.text,
        'targeted_audience': _targetedAudience,
        'countries': _selectedCountries,
        'regions': _selectedRegions,
        'cities': _selectedCities,
        'targeted_gender': _targetedGender,
        'media_url': mediaUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(msg: 'Ad data submitted successfully!');
      _resetForm();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to submit data: $e');
    }

    setState(() {
      _isLoading = false;
      _isPaymentCompleted = false;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _contactController.clear();
    _addressController.clear();
    _contributionController.clear();
    _websiteController.clear();
    _usernameController.clear();
    _descriptionController.clear();
    _tutorialController.clear();
    setState(() {
      _mediaFile = null;
      _targetedAudience = null;
      _selectedCountries = [];
      _selectedRegions = [];
      _selectedCities = [];
      _targetedGender = null;
      _isPaymentCompleted = false;
    });
  }

  void _showPicker(String type) {
    if (type != 'countries' && _selectedCountries.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select countries first.');
      return;
    }

    List<String> items = [];
    List<String> selectedItems;
    String title;

    switch (type) {
      case 'countries':
        items = _locationData.keys.toList();
        selectedItems = _selectedCountries;
        title = 'Select Countries';
        break;
      case 'regions':
        for (var country in _selectedCountries) {
          items.addAll(_locationData[country]!.keys.toList());
        }
        items = items.toSet().toList();
        selectedItems = _selectedRegions;
        title = 'Select Regions';
        break;
      case 'cities':
        for (var country in _selectedCountries) {
          for (var region in _selectedRegions) {
            if (_locationData[country]!.containsKey(region)) {
              items.addAll(_locationData[country]![region]!);
            }
          }
        }
        items = items.toSet().toList();
        selectedItems = _selectedCities;
        title = 'Select Cities';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelectedItems = List.from(selectedItems);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * (MediaQuery.of(context).size.width / 400),
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * (MediaQuery.of(context).size.width / 400),
                        ),
                      ),
                      value: tempSelectedItems.contains(item),
                      activeColor: Colors.amber,
                      checkColor: Colors.black,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempSelectedItems.add(item);
                          } else {
                            tempSelectedItems.remove(item);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16 * (MediaQuery.of(context).size.width / 400),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      switch (type) {
                        case 'countries':
                          _selectedCountries = tempSelectedItems;
                          _selectedRegions = _selectedRegions
                              .where((region) => _selectedCountries
                                  .any((country) => _locationData[country]!.containsKey(region)))
                              .toList();
                          _selectedCities = _selectedCities
                              .where((city) => _selectedCountries.any(
                                  (country) => _locationData[country]!.values.any((cities) => cities.contains(city))))
                              .toList();
                          break;
                        case 'regions':
                          _selectedRegions = tempSelectedItems;
                          _selectedCities = _selectedCities
                              .where((city) => _selectedCountries.any((country) =>
                                  _selectedRegions.any((region) => _locationData[country]![region]!.contains(city))))
                              .toList();
                          break;
                        case 'cities':
                          _selectedCities = tempSelectedItems;
                          break;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16 * (MediaQuery.of(context).size.width / 400),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _contributionController.dispose();
    _websiteController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = screenWidth * 0.04;
    final fontScale = screenWidth / 400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ad Submission',
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Promote Your Ad',
                      style: TextStyle(
                        fontSize: 28 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Submit your advertisement details and choose your contribution amount to reach your target audience!',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Media Upload
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: screenHeight * 0.2,
                        width: screenWidth * 0.92,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          border: Border.all(color: Colors.amber, width: 2 * fontScale),
                        ),
                        child: _mediaFile == null
                            ? Center(
                                child: Text(
                                  'Tap to upload Image/Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16 * fontScale,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10 * fontScale),
                                child: Image.file(
                                  _mediaFile!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      'Video selected',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16 * fontScale,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter your username' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Contact Number
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Enter your contact number' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter your address' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Company Website
                    TextFormField(
                      controller: _websiteController,
                      decoration: InputDecoration(
                        labelText: 'Company Website',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter your company website';
                        if (!RegExp(r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,4}(\/.*)?$').hasMatch(value)) {
                          return 'Enter a valid website URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Tutorial
                    TextFormField(
                      controller: _tutorialController,
                      decoration: InputDecoration(
                        labelText: 'Tutorial',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Contribution Amount
                    TextFormField(
                      controller: _contributionController,
                      decoration: InputDecoration(
                        labelText: 'Contribution Amount (€)',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter contribution amount';
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Targeted Audience
                    DropdownButtonFormField<String>(
                      value: _targetedAudience,
                      decoration: InputDecoration(
                        labelText: 'Targeted Audience',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      dropdownColor: Colors.grey[900],
                      items: ['General', 'Youth', 'Professionals', 'Families']
                          .map((audience) => DropdownMenuItem(
                                value: audience,
                                child: Text(
                                  audience,
                                  style: TextStyle(fontSize: 16 * fontScale),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _targetedAudience = value;
                        });
                      },
                      validator: (value) => value == null ? 'Select targeted audience' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Countries Selection
                    GestureDetector(
                      onTap: () => _showPicker('countries'),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Countries',
                          labelStyle: TextStyle(
                            color: Colors.amber,
                            fontSize: 16 * fontScale,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                        ),
                        child: Text(
                          _selectedCountries.isEmpty ? 'Select countries' : _selectedCountries.join(', '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Regions Selection
                    GestureDetector(
                      onTap: () => _showPicker('regions'),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Regions',
                          labelStyle: TextStyle(
                            color: Colors.amber,
                            fontSize: 16 * fontScale,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                        ),
                        child: Text(
                          _selectedRegions.isEmpty ? 'Select regions' : _selectedRegions.join(', '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Cities Selection
                    GestureDetector(
                      onTap: () => _showPicker('cities'),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Cities',
                          labelStyle: TextStyle(
                            color: Colors.amber,
                            fontSize: 16 * fontScale,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * fontScale),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2 * fontScale,
                            ),
                          ),
                        ),
                        child: Text(
                          _selectedCities.isEmpty ? 'Select cities' : _selectedCities.join(', '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Targeted Gender
                    DropdownButtonFormField<String>(
                      value: _targetedGender,
                      decoration: InputDecoration(
                        labelText: 'Targeted Gender',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          fontSize: 16 * fontScale,
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * fontScale),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            width: 2 * fontScale,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontScale,
                      ),
                      dropdownColor: Colors.grey[900],
                      items: ['All', 'Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: TextStyle(fontSize: 16 * fontScale),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _targetedGender = value;
                        });
                      },
                      validator: (value) => value == null ? 'Select targeted gender' : null,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // Note above Submit Button
                    Text(
                      'Note: After completing the payment, please return to this page and click the Submit button to finalize your ad submission.',
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: padding * 1.2,
                            horizontal: padding * 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16 * fontScale),
                          ),
                          elevation: 8 * fontScale,
                          minimumSize: Size(
                            screenWidth * 0.5,
                            screenHeight * 0.07,
                          ),
                        ),
                        child: Text(
                          'Submit Ad',
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }
}