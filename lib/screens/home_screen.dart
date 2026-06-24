import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> openEditor(BuildContext context) async {
    final picker = ImagePicker();

    final img = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (img == null) return;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          imageFile: File(img.path),
        ),
      ),
    );
  }

  Future<void> openCamera(BuildContext context) async {
  final picker = ImagePicker();

  final img = await picker.pickImage(
    source: ImageSource.camera,
  );

  if (img == null) return;

  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditorScreen(
        imageFile: File(img.path),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

  width: double.infinity,

  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF050008),
        Color(0xFF120022),
        Color(0xFF000000),
      ],
    ),
  ),

  child: SafeArea(

    child: Column(

      children: [

        const SizedBox(height: 20),

        const Icon(
  Icons.dark_mode,
  size: 90,
  color: Colors.deepPurpleAccent,
),

        const SizedBox(height: 10),

        Text(
  "SHADOW EDITOR",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 3,
    shadows: [
      Shadow(
        color: Colors.purple,
        blurRadius: 25,
        ),
    ],
  ),
),

        const SizedBox(height: 5),

        const Text(
          "Arise. Create. Conquer.",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 25),

        Expanded(

          child: GridView.count(

            padding: const EdgeInsets.all(20),

            crossAxisCount: 2,

            crossAxisSpacing: 15,

            mainAxisSpacing: 15,

            children: [

              homeCard(
                icon: Icons.layers,
                title: "Layer Editor",
                onTap: () {
                  openEditor(context);
                },
              ),

              homeCard(
  icon: Icons.content_cut,
  title: "BG Remover",
  onTap: () {
    openEditor(context);
  },
),

homeCard(
  icon: Icons.auto_awesome,
  title: "AI Generator",
  onTap: () {
    openEditor(context);
  },
),

homeCard(
  icon: Icons.emoji_emotions,
  title: "AI Sticker",
  onTap: () {
    openEditor(context);
  },
),

              homeCard(
  icon: Icons.edit,
  title: "Edit Image",
  onTap: () {

    openEditor(context);
  },
),

homeCard(
  icon: Icons.camera_alt,
  title: "Open Camera",
  onTap: () {

    openCamera(context);
  },
),
            ],
          ),
        ),
      ],
    ),
  ),
),
    );
  }
}

Widget homeCard({

  required IconData icon,

  required String title,

  required VoidCallback onTap,

}) {

  return InkWell(

    onTap: onTap,

    borderRadius:
        BorderRadius.circular(25),

    child: Container(

      decoration: BoxDecoration(

        color: const Color(0xFF1A1025),

        borderRadius:
            BorderRadius.circular(25),

        border: Border.all(
          color: const Color.fromARGB(255, 32, 2, 37),
        ),

        boxShadow: const [

          BoxShadow(
            color: Color.fromARGB(255, 10, 1, 11),
            blurRadius: 12,
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 45,
            color: const Color.fromARGB(255, 240, 224, 245),
          ),

          const SizedBox(height: 12),

          Text(

            title,

            textAlign: TextAlign.center,

            style: const TextStyle(

              color: Colors.white,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> openImageEditor(
  BuildContext context,
) async {

  final picker = ImagePicker();

  final img = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (img == null) return;

  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditorScreen(
        imageFile: File(img.path),
      ),
    ),
  );
}

Future<void> openBGRemover(
  BuildContext context,
) async {

  final picker = ImagePicker();

  final img = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (img == null) return;

  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditorScreen(
        imageFile: File(img.path),
      ),
    ),
  );
}
