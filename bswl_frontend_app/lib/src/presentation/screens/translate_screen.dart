import 'package:flutter/material.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/simple_camera_view.dart';
import 'package:bswl_frontend_app/src/presentation/widgets/sign_player.dart';
import 'package:bswl_frontend_app/src/presentation/theme/app_colors.dart';
import '../../../services/gemini_ai_service.dart';
import 'ai_assistant_screen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Gemini AI Translation variables
  final GeminiAIService _geminiService = GeminiAIService();
  String? _translatedText;
  bool _isTranslating = false;
  String _selectedSourceLanguage = 'en';
  String _selectedTargetLanguage = 'hi';
  final TextEditingController _textController = TextEditingController();

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

  Future<void> _performTranslation() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // Use Gemini for translation
      final translation = await _geminiService.translateText(
        _textController.text,
        _selectedSourceLanguage,
        _selectedTargetLanguage,
      );

      setState(() {
        _translatedText = translation;
        _isTranslating = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation completed using AI'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar with responsive sizing for 20:9 ratio
          Container(
            height: topPadding + (screenHeight * 0.12), // Reduced from 0.15
            padding: EdgeInsets.only(
              top: topPadding + 8,
              bottom: 8,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header content
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        iconSize: screenWidth * 0.06,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: screenWidth * 0.08,
                          minHeight: screenWidth * 0.08,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Real-time Translation',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Convert Sign, Voice & Text Instantly',
                              style: TextStyle(
                                fontSize: screenWidth * 0.028,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Bar with proper sizing
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: 4,
                      ),
                      indicatorPadding: EdgeInsets.symmetric(
                        horizontal: -screenWidth * 0.01,
                      ),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.032,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.029,
                      ),
                      tabs: const [
                        Tab(text: 'Sign to Text'),
                        Tab(text: 'Voice to Sign'),
                        Tab(text: 'AI Assistant'),
                        Tab(text: 'Translator'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar View - Takes remaining space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSignToTextTab(),
                _buildComingSoonTab("Voice to Sign"),
                _buildAIAssistantTab(),
                _buildTranslatorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignToTextTab() {
    return SimpleCameraView(onSignDetected: (text) {
      _handleTranslation(text);
    });
  }

  Widget _buildTranslatorTab() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          // Language Selection Row
          Row(
            children: [
              // Source Language Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSourceLanguage,
                      hint: Text('From',
                          style: TextStyle(fontSize: screenWidth * 0.035)),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                        DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                        DropdownMenuItem(value: 'ko', child: Text('Korean')),
                        DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSourceLanguage = newValue ?? 'en';
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Swap Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    final temp = _selectedSourceLanguage;
                    _selectedSourceLanguage = _selectedTargetLanguage;
                    _selectedTargetLanguage = temp;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Target Language Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTargetLanguage,
                      hint: Text('To',
                          style: TextStyle(fontSize: screenWidth * 0.035)),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                        DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                        DropdownMenuItem(value: 'ko', child: Text('Korean')),
                        DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTargetLanguage = newValue ?? 'hi';
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),

          // Input Text Field
          Container(
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.12,
            ),
            child: TextField(
              controller: _textController,
              style: TextStyle(fontSize: screenWidth * 0.038),
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Enter text to translate',
                labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, size: screenWidth * 0.05),
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _translatedText = null;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Translate Button
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.055,
            child: ElevatedButton.icon(
              icon: _isTranslating
                  ? SizedBox(
                      width: screenWidth * 0.03,
                      height: screenWidth * 0.03,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.translate, size: screenWidth * 0.04),
              label: Text(
                _isTranslating ? "Translating..." : "Translate with AI",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isTranslating ? null : _performTranslation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Translation Result
          if (_translatedText != null)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'AI Translation Result',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.copy, size: screenWidth * 0.05),
                          onPressed: () {
                            // TODO: Implement copy to clipboard
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _textController.text,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _translatedText!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String label) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction,
            size: screenWidth * 0.15,
            color: Colors.grey,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            '$label Coming Soon!',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantTab() {
    return const AIAssistantScreen();
  }
}
