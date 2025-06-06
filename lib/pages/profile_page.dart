import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> videoAssets = [
    'assets/videos/BOOST.mp4',
    'assets/videos/flipkart.mp4',
    'assets/videos/glance.mp4',
    'assets/videos/yt-shorts.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header with Unsplash image
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250, // Increased height
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[900],
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -40, // Overlap the profile picture
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 50, // Increased size
                        backgroundImage: AssetImage('assets/2.png'),
                      ),
                    ),
                  ),
                ],
              ),

              // Added spacing to account for overlapped profile picture
              SizedBox(height: 50),

              // Profile Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suuryaprabhat.in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Food Vlogger',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    Text(
                      'India',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Award-winning influencer, reshaping digital trends with creativity, impact, and authenticity.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Featured in 40 Under 40 for redefining influence.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Social Stats
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialStat('Instagram', '9.5M'),
                    _buildSocialStat('Facebook', '8.3M'),
                    _buildSocialStat('YouTube', '10.4M'),
                    _buildSocialStat('LinkedIn', '10M'),
                    _buildSocialStat('Twitter', '10M'),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'About'),
                  Tab(text: 'Rate Card'),
                  Tab(text: 'Collabs'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),

              // Tab Bar View
              SizedBox(
                height: 500, // Adjust based on content
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVideoGrid(),
                    _buildRateCard(),
                    _buildCollabs(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStat(String platform, String count) {
    return Column(
      children: [
        Icon(_getSocialIcon(platform), color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return Icons.camera_alt;
      case 'Facebook':
        return Icons.facebook;
      case 'YouTube':
        return Icons.play_circle_filled;
      case 'LinkedIn':
        return Icons.work;
      case 'Twitter':
        return Icons.chat_bubble;
      default:
        return Icons.public;
    }
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: videoAssets.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '2.8M',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRateCard() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Perfect for brands looking to make a bold impact in under 60 seconds.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          SizedBox(height: 16),
          _buildRateDetail('Duration:', '45 Sec'),
          _buildRateDetail('Time to deliver:', '1 Day'),
          _buildRateDetail('Place of shoot:', 'On-Site'),
          SizedBox(height: 16),
          Text(
            '₹ 5,000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          SizedBox(width: 8),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCollabs() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildCollabItem('Nike', 'Begumpet', '₹ 5,000'),
        _buildCollabItem('Audi', 'Banjara Hills', '₹ 5,000'),
      ],
    );
  }

  Widget _buildCollabItem(String brand, String location, String amount) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(amount, style: TextStyle(color: Colors.green, fontSize: 18)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            location,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Chosen',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  Text(
                    '45 Sec Reel',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Get Directions'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Looking For',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  Text(
                    'Promote Restaurant',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Text(
                'Commission on sale: 2%',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
