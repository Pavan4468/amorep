import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Upcoming Events",
          style: TextStyle(color: Colors.black,),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = eventSnapshot.data!.docs;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ads').snapshots(),
            builder: (context, adSnapshot) {
              if (adSnapshot.hasError) {
                return const Center(child: Text('Error fetching ads'));
              }
              if (adSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final ads = adSnapshot.data!.docs;
              List<dynamic> combinedItems = [];
              int adIndex = 0;
              for (int i = 0; i < events.length; i++) {
                combinedItems.add(events[i]);
                if ((i + 1) % 2 == 0 && ads.isNotEmpty) {
                  combinedItems.add(ads[adIndex % ads.length]);
                  adIndex++;
                }
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: combinedItems.length,
                itemBuilder: (context, index) {
                  final item = combinedItems[index];
                  if (item is QueryDocumentSnapshot && item.reference.parent.id == 'ads') {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      child: AdWidget(ad: item.data() as Map<String, dynamic>),
                    );
                  }
                  final event = item.data() as Map<String, dynamic>;
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    child: OpenContainer(
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedElevation: 5,
                      closedColor: Colors.black,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      closedBuilder: (context, action) => GestureDetector(
                        onTap: action,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: event["image"],
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        event["image"],
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: double.infinity,
                                      ),
                                      Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.2),
                                              Colors.black.withOpacity(0.5),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event["name"],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${event["date"]} | ${event["time"]}",
                                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          event["location"],
                                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      openBuilder: (context, action) => EventDetailsPage(event: event),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AdWidget extends StatelessWidget {
  final Map<String, dynamic> ad;

  const AdWidget({Key? key, required this.ad}) : super(key: key);

  void _launchURL(BuildContext context) async {
    final url = ad['url'] as String;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)], // Vibrant blue gradient for ads
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              children: [
                Image.network(
                  ad['image'] as String,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'] as String? ?? 'Ad',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ad['description'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[200],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedScaleButton(
                    child: ElevatedButton(
                      onPressed: () => _launchURL(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0288D1),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  void _launchURL() async {
    final Uri url = Uri.parse(event["link"]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch ${event["link"]}";
    }
  }

  void _addToGoogleCalendar(BuildContext context) async {
    final String title = event["name"];
    final String description = event["description"];
    final String location = event["location"];
    final String date = event["date"];
    final String time = event["time"];

    final DateTime startDateTime =
        DateTime.parse("$date ${time.replaceAll(":00", "")}:00");
    final DateTime endDateTime = startDateTime.add(const Duration(hours: 2));

    final String formattedStart = startDateTime
            .toUtc()
            .toIso8601String()
            .replaceAll("-", "")
            .replaceAll(":", "")
            .split(".")[0] +
        "Z";
    final String formattedEnd = endDateTime
            .toUtc()
            .toIso8601String()
            .replaceAll("-", "")
            .replaceAll(":", "")
            .split(".")[0] +
        "Z";

    final Uri calendarUrl = Uri.parse(
      "https://www.google.com/calendar/render?action=TEMPLATE"
      "&text=${Uri.encodeComponent(title)}"
      "&details=${Uri.encodeComponent(description)}"
      "&location=${Uri.encodeComponent(location)}"
      "&dates=$formattedStart/$formattedEnd",
    );

    if (await canLaunchUrl(calendarUrl)) {
      await launchUrl(calendarUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Calendar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          event["name"],
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: event["image"],
              child: Stack(
                children: [
                  Image.network(
                    event["image"],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["name"],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${event["date"]} | ${event["time"]}",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        event["location"],
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event["description"],
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedScaleButton(
                          child: ElevatedButton.icon(
                            onPressed: _launchURL,
                            icon: const Icon(Icons.link, color: Colors.white),
                            label: const Text(
                              "Event Location",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedScaleButton(
                          child: ElevatedButton.icon(
                            onPressed: () => _addToGoogleCalendar(context),
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                            label: const Text(
                              "Add to Calendar",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final Widget child;

  const AnimatedScaleButton({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.95;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}