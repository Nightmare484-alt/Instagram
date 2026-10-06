import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const InstaApp());

class InstaApp extends StatelessWidget {
  const InstaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagr@m',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

// ---------------- DATA MODELS ----------------
class Comment {
  String user;
  String text;
  Comment({required this.user, required this.text});
  Map<String, dynamic> toJson() => {'u': user, 't': text};
  factory Comment.fromJson(Map<String, dynamic> j) =>
      Comment(user: j['u'], text: j['t']);
}

class Post {
  String user;
  String caption;
  String location;
  int likes;
  int colorIndex;
  List<Comment> comments;
  Post({
    required this.user,
    required this.caption,
    required this.location,
    required this.likes,
    required this.colorIndex,
    required this.comments,
  });
  Map<String, dynamic> toJson() => {
        'user': user,
        'caption': caption,
        'location': location,
        'likes': likes,
        'colorIndex': colorIndex,
        'comments': comments.map((c) => c.toJson()).toList(),
      };
  factory Post.fromJson(Map<String, dynamic> j) => Post(
        user: j['user'],
        caption: j['caption'],
        location: j['location'],
        likes: j['likes'],
        colorIndex: j['colorIndex'],
        comments: (j['comments'] as List)
            .map((c) => Comment.fromJson(c))
            .toList(),
      );
}

// ---------------- GLOBAL STATE ----------------
List<Post> posts = [];
bool editMode = false;
int logoPressCount = 0;

List<Color> palette = [
  const Color(0xFF2C3E50),
  const Color(0xFF8E44AD),
  const Color(0xFF16A085),
  const Color(0xFFE67E22),
  const Color(0xFFC0392B),
  const Color(0xFF2980B9),
  const Color(0xFF27AE60),
  const Color(0xFF8E44AD),
  const Color(0xFFD35400),
  const Color(0xFF34495E),
];

List<String> usernames = [
  'john_doe', 'sara.k', 'mike_92', 'emma_w', 'alex.river',
  'ninja_dev', 'luna.art', 'max_vibes', 'zara_shot', 'kev_official',
  'mia_fit', 'ryan.codes', 'leo_world', 'ivy_style', 'noah_travel',
];

List<String> locations = [
  'New York, USA', 'Paris, France', 'Tokyo, Japan', 'Dubai, UAE',
  'London, UK', 'Bali, Indonesia', 'Rome, Italy', 'Sydney, Australia',
];

List<String> captions = [
  'Living my best life ✨',
  'Weekend vibes 🌴',
  'New day, new adventure',
  'Coffee and code ☕',
  'Golden hour 🌅',
  'Chasing dreams',
  'Sunset state of mind',
  'Making memories',
  'Just another day in paradise',
  'Stay wild 🌊',
];

List<String> commentPool = [
  'Love this! 😍', 'So cool', 'Amazing shot 🔥', 'Goals!',
  'Where is this?', 'Beautiful 💕', 'Nice one', 'Incredible',
];

Future<void> loadPosts() async {
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString('posts');
  if (s != null) {
    final list = jsonDecode(s) as List;
    posts = list.map((e) => Post.fromJson(e)).toList();
  } else {
    posts = List.generate(59, (i) {
      return Post(
        user: usernames[i % usernames.length],
        caption: captions[i % captions.length],
        location: locations[i % locations.length],
        likes: 100 + (i * 37) % 9000,
        colorIndex: i % palette.length,
        comments: List.generate(
          2 + (i % 3),
          (j) => Comment(
            user: usernames[(i + j + 1) % usernames.length],
            text: commentPool[(i + j) % commentPool.length],
          ),
        ),
      );
    });
    await savePosts();
  }
}

Future<void> savePosts() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('posts', jsonEncode(posts.map((p) => p.toJson()).toList()));
}

// ---------------- ROOT ----------------
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int index = 0;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    loadPosts().then((_) => setState(() => ready = true));
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final screens = [
      HomeScreen(onUpdate: () => setState(() {})),
      const SearchScreen(),
      const ReelsScreen(),
      const NotificationsScreen(),
      ProfileScreen(onUpdate: () => setState(() {})),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      body: screens[index],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navIcon(Icons.home_filled, 0),
                navIcon(Icons.search, 1),
                navIcon(Icons.smart_display_outlined, 2),
                navIcon(Icons.favorite_border, 3),
                navAvatar(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navIcon(IconData icon, int i) {
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Icon(
        icon,
        size: 28,
        color: index == i ? Colors.white : Colors.white54,
      ),
    );
  }

  Widget navAvatar(int i) {
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: index == i ? Colors.white : Colors.white54,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.purple],
          ),
        ),
      ),
    );
  }
}

// ---------------- HOME ----------------
class HomeScreen extends StatelessWidget {
  final VoidCallback onUpdate;
  const HomeScreen({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    logoPressCount++;
                    if (logoPressCount >= 3) {
                      logoPressCount = 0;
                      editMode = !editMode;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(editMode
                              ? '✏️ EDIT MODE ON — tap any post to edit'
                              : '🔒 Edit mode OFF'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      onUpdate();
                    }
                  },
                  child: const Text(
                    'Instagr@m',
                    style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.favorite_border,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DMScreen()),
                      ),
                      child: const Icon(Icons.send_outlined,
                          color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // STORIES
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (_, i) {
                final has = i != 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: has
                              ? const LinearGradient(colors: [
                                  Color(0xFFFEDA75),
                                  Color(0xFFFA7E1E),
                                  Color(0xFFD62976),
                                  Color(0xFF962FBF),
                                ])
                              : null,
                          border: has
                              ? null
                              : Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette[i % palette.length],
                            ),
                            child: i == 0
                                ? const Icon(Icons.add,
                                    color: Colors.white, size: 28)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i == 0 ? 'You' : usernames[i % usernames.length],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // FEED
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => PostCard(
                post: posts[i],
                index: i,
                onUpdate: onUpdate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- POST CARD ----------------
class PostCard extends StatefulWidget {
  final Post post;
  final int index;
  final VoidCallback onUpdate;
  const PostCard({
    super.key,
    required this.post,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      onTap: () {
        if (editMode) showEditDialog(context, widget.index, widget.onUpdate);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        color: editMode ? Colors.white.withOpacity(0.03) : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          palette[p.colorIndex],
                          palette[(p.colorIndex + 3) % palette.length],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          p.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
            // IMAGE PLACEHOLDER
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      palette[p.colorIndex],
                      palette[(p.colorIndex + 5) % palette.length],
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ),
            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => liked = !liked),
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.chat_bubble_outline,
                      color: Colors.white, size: 25),
                  const SizedBox(width: 14),
                  const Icon(Icons.send_outlined,
                      color: Colors.white, size: 25),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => saved = !saved),
                    child: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '${(p.likes + (liked ? 1 : 0)).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} likes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${p.user} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: p.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...p.comments.map(
              (c) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${c.user} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: c.text,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                '2 hours ago',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- EDIT DIALOG ----------------
void showEditDialog(BuildContext context, int index, VoidCallback onUpdate) {
  final p = posts[index];
  final userC = TextEditingController(text: p.user);
  final capC = TextEditingController(text: p.caption);
  final locC = TextEditingController(text: p.location);
  final likeC = TextEditingController(text: p.likes.toString());

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      title: const Text('✏️ Edit Post',
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field('Username', userC),
            field('Caption', capC),
            field('Location', locC),
            field('Likes', likeC),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            posts.removeAt(index);
            savePosts();
            Navigator.pop(context);
            onUpdate();
          },
          child: const Text('DELETE', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () {
            p.user = userC.text;
            p.caption = capC.text;
            p.location = locC.text;
            p.likes = int.tryParse(likeC.text) ?? p.likes;
            savePosts();
            Navigator.pop(context);
            onUpdate();
          },
          child: const Text('SAVE',
              style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    ),
  );
}

Widget field(String label, TextEditingController c) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    ),
  );
}

// ---------------- SEARCH ----------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.white54, size: 20),
                  SizedBox(width: 8),
                  Text('Search',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: posts.length,
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette[posts[i].colorIndex],
                      palette[(posts[i].colorIndex + 4) % palette.length],
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white24, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- REELS ----------------
class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (_, i) {
          final p = posts[i];
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      palette[p.colorIndex],
                      palette[(p.colorIndex + 7) % palette.length],
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline,
                      size: 80, color: Colors.white24),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 30,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              palette[p.colorIndex],
                              palette[(p.colorIndex + 3) % palette.length],
                            ]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(p.user,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(p.caption,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const Positioned(
                right: 16,
                bottom: 40,
                child: Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 30),
                    SizedBox(height: 4),
                    Text('12K', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    Icon(Icons.chat_bubble_outline,
                        color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text('340', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    Icon(Icons.send_outlined, color: Colors.white, size: 28),
                    SizedBox(height: 20),
                    Icon(Icons.more_vert, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------- NOTIFICATIONS ----------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Notifications',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (_, i) => ListTile(
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      palette[i % palette.length],
                      palette[(i + 3) % palette.length],
                    ]),
                  ),
                ),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: usernames[i % usernames.length],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: i % 3 == 0
                            ? ' liked your post.'
                            : i % 3 == 1
                                ? ' started following you.'
                                : ' commented: "Nice!"',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  '${i + 1}h',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                trailing: i % 3 == 1
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Follow'),
                      )
                    : Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            palette[(i + 2) % palette.length],
                            palette[(i + 5) % palette.length],
                          ]),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- PROFILE ----------------
class ProfileScreen extends StatelessWidget {
  final VoidCallback onUpdate;
  const ProfileScreen({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('my_profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.add_box_outlined,
                    color: Colors.white, size: 26),
                const SizedBox(width: 14),
                const Icon(Icons.menu, color: Colors.white, size: 26),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.purple, Colors.pink],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      stat('59', 'posts'),
                      stat('12.4K', 'followers'),
                      stat('340', 'following'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text('Welcome to my page ✨',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF262626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Edit profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF262626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Share profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                        gradient: LinearGradient(colors: [
                          palette[i % palette.length],
                          palette[(i + 4) % palette.length],
                        ]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Story ${i + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: posts.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                if (editMode) showEditDialog(context, i, onUpdate);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette[posts[i].colorIndex],
                      palette[(posts[i].colorIndex + 4) % palette.length],
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image,
                      color: Colors.white24, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget stat(String n, String label) {
    return Column(
      children: [
        Text(n,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// ---------------- DMS ----------------
class DMScreen extends StatelessWidget {
  const DMScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('my_profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 10,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          palette[i % palette.length],
                          palette[(i + 3) % palette.length],
                        ]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usernames[i % usernames.length].length > 8
                          ? usernames[i % usernames.length].substring(0, 8)
                          : usernames[i % usernames.length],
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.builder(
              itemCount: usernames.length,
              itemBuilder: (_, i) => ListTile(
                leading: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      palette[i % palette.length],
                      palette[(i + 4) % palette.length],
                    ]),
                  ),
                ),
                title: Text(usernames[i],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Sent a message · ${i + 1}h',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13),
                ),
                trailing: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white54, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
