import 'package:flutter/material.dart'; 
import 'package:bswl_frontend_app/src/presentation/widgets/camera_view.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/translation_result.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/sign_player.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with SingleTickerProviderStateMixin {
  String? _translatedText;
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleTranslation(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _translatedText = text;
      });
    }
  }

  void _resetTranslation() {
    setState(() {
      _translatedText = null;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(200),
  child: Container(
    padding: const EdgeInsets.only(top: 10, bottom: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // ✅ Removed boxShadow to avoid black line under TabBar
      // If needed, use subtle white shadow above instead for depth
    ),
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.translate_rounded,
                      color: Color.fromARGB(255, 254, 253, 253), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Real-time Translation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 600),
                child: Text(
                  'Convert Sign, Voice & Text Instantly',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              elevation: 0,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: -9),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Sign to Text'),
                  Tab(text: 'Voice to Sign'),
                  Tab(text: 'Text to Speech'),
                  Tab(text: 'Translator'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSignToTextTab(),
          _buildComingSoonTab("Voice to Sign"),
          _buildComingSoonTab("Text to Speech"),
          _buildTranslatorTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetTranslation,
        backgroundColor: AppColors.primary,
        tooltip: "Reset Translation",
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSignToTextTab() {
    return Column(
      children: [
        Expanded(
          child: CameraView(onSignDetected: (text) {
            _handleTranslation(text);
          }),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _translatedText != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TranslationResult(
                            hindiText: _translatedText!,
                            englishText: _translatedText!.toLowerCase(),
                          ),
                          const SizedBox(height: 16),
                          SignPlayer(
                            signLabel: _translatedText!,
                            autoplay: true,
                            size: 160,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTranslatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Enter text to translate',
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _textController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.translate),
              label: const Text("Translate"),
              onPressed: () => _handleTranslation(_textController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_translatedText != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TranslationResult(
                  hindiText: _translatedText!,
                  englishText: _translatedText!.toLowerCase(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '$label Coming Soon!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
