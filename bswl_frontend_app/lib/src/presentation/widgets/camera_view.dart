// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../theme/app_colors.dart';

// class CameraView extends StatefulWidget {
//   final Function(String) onSignDetected;

//   const CameraView({super.key, required this.onSignDetected});

//   @override
//   State<CameraView> createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> with TickerProviderStateMixin {
//   CameraController? _controller;
//   bool _isDetecting = false;
//   bool _cameraInitialized = false;
//   bool _permissionGranted = false;
//   String _errorMessage = '';

//   // Detection state
//   String _detectedSign = '';
//   double _confidence = 0.0;
//   bool _handDetected = false;
//   Rect? _handBoundingBox;

//   // Animation controllers
//   late AnimationController _pulseController;
//   late AnimationController _fadeController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _fadeAnimation;

//   // Detection simulation
//   final List<String> _sampleSigns = [
//     'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
//     'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
//   ];
//   int _currentSignIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _checkPermissionsAndInitialize();
//   }

//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _pulseAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   Future<void> _checkPermissionsAndInitialize() async {
//     try {
//       final cameraStatus = await Permission.camera.status;

//       if (cameraStatus.isDenied) {
//         final result = await Permission.camera.request();
//         if (result.isDenied) {
//           setState(() {
//             _errorMessage = 'Camera permission required for sign detection';
//           });
//           return;
//         }
//       }

//       if (cameraStatus.isPermanentlyDenied) {
//         setState(() {
//           _errorMessage = 'Camera permission denied. Enable in settings.';
//         });
//         return;
//       }

//       setState(() => _permissionGranted = true);
//       await _initializeCamera();
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to check permissions: $e';
//       });
//     }
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();

//       if (cameras.isEmpty) {
//         setState(() {
//           _errorMessage = 'No cameras found on this device';
//         });
//         return;
//       }

//       // Try to find front camera, fallback to any available camera
//       CameraDescription selectedCamera;
//       try {
//         selectedCamera = cameras.firstWhere(
//           (camera) => camera.lensDirection == CameraLensDirection.front,
//         );
//       } catch (e) {
//         selectedCamera = cameras.first;
//       }

//       _controller = CameraController(
//         selectedCamera,
//         ResolutionPreset.high,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.yuv420,
//       );

//       await _controller!.initialize();

//       if (!mounted) return;

//       setState(() => _cameraInitialized = true);

//       // Start image stream with error handling
//       try {
//         await _controller!.startImageStream(_processCameraImage);
//       } catch (e) {
//         // Try with different settings for emulator compatibility
//         try {
//           await _controller!.dispose();
//           _controller = CameraController(
//             selectedCamera,
//             ResolutionPreset.medium,
//             enableAudio: false,
//             imageFormatGroup: ImageFormatGroup.yuv420,
//           );
//           await _controller!.initialize();
//           await _controller!.startImageStream(_processCameraImage);
//           setState(() => _cameraInitialized = true);
//         } catch (e2) {
//           setState(() {
//             _errorMessage = 'Camera not available on emulator. Use real device.';
//           });
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize camera: $e';
//       });
//     }
//   }

//   Future<void> _processCameraImage(CameraImage image) async {
//     if (_isDetecting || !mounted) return;

//     setState(() {
//       _isDetecting = true;
//     });

//     try {
//       // Simulate ML processing
//       await Future.delayed(const Duration(milliseconds: 800));

//       if (mounted) {
//         // Get screen dimensions for proper positioning
//         final screenSize = MediaQuery.of(context).size;
//         final centerX = screenSize.width * 0.5;
//         final centerY = screenSize.height * 0.45; // Adjusted for better positioning
//         final boxSize = screenSize.width * 0.3; // Responsive box size

//         setState(() {
//           _handDetected = true;
//           _handBoundingBox = Rect.fromCenter(
//             center: Offset(centerX, centerY),
//             width: boxSize,
//             height: boxSize,
//           );

//           // Simulate sign detection
//           _detectedSign = _sampleSigns[_currentSignIndex % _sampleSigns.length];
//           _confidence = 0.85 + (0.15 * (_currentSignIndex % 10) / 10);
//           _currentSignIndex++;
//         });

//         // Start animations
//         _pulseController.repeat(reverse: true);
//         _fadeController.forward();

//         // Call the callback
//         widget.onSignDetected(_detectedSign);

//         // Reset after delay
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) {
//           setState(() {
//             _handDetected = false;
//             _handBoundingBox = null;
//             _detectedSign = '';
//             _confidence = 0.0;
//           });
//           _pulseController.stop();
//           _fadeController.reverse();
//         }
//       }
//     } catch (e) {
//       debugPrint('Detection error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDetecting = false;
//         });
//       }
//     }
//   }

//   Future<void> _retryInitialization() async {
//     await _controller?.stopImageStream();
//     setState(() {
//       _errorMessage = '';
//       _cameraInitialized = false;
//       _handDetected = false;
//       _handBoundingBox = null;
//       _detectedSign = '';
//       _confidence = 0.0;
//     });
//     await _checkPermissionsAndInitialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     if (!_permissionGranted) {
//       return _buildErrorWidget(
//         'Camera Permission Required',
//         _errorMessage,
//         Icons.camera_alt,
//         AppColors.warning,
//         () => _checkPermissionsAndInitialize(),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget(
//         'Camera Error',
//         _errorMessage,
//         Icons.error,
//         AppColors.error,
//         () => _retryInitialization(),
//       );
//     }

//     if (!_cameraInitialized) {
//       return _buildLoadingWidget();
//     }

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Full-screen camera preview
//           _buildCameraPreview(),
          
//           // Detection overlay
//           if (_handDetected && _handBoundingBox != null) 
//             _buildDetectionOverlay(),

//           // Top status overlay
//           if (_isDetecting || _handDetected) 
//             _buildTopStatusOverlay(),

//           // Bottom controls
//           _buildBottomControls(),

//           // Detection processing indicator
//           if (_isDetecting) 
//             _buildDetectionIndicator(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCameraPreview() {
//     if (_controller?.value.isInitialized == true) {
//       // Get camera aspect ratio
//       final cameraAspectRatio = _controller!.value.aspectRatio;
//       final screenSize = MediaQuery.of(context).size;
//       final screenAspectRatio = screenSize.width / screenSize.height;
      
//       return Transform.scale(
//         scale: cameraAspectRatio / screenAspectRatio,
//         child: Center(
//           child: AspectRatio(
//             aspectRatio: cameraAspectRatio,
//             child: CameraPreview(_controller!),
//           ),
//         ),
//       );
//     } else {
//       return _buildSimulatedCameraPreview();
//     }
//   }

//   Widget _buildSimulatedCameraPreview() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.withOpacity(0.3),
//             Colors.green.withOpacity(0.2),
//             Colors.purple.withOpacity(0.3),
//           ],
//         ),
//       ),
//       child: CustomPaint(
//         painter: SimulatedCameraPainter(),
//         size: Size.infinite,
//       ),
//     );
//   }

//   Widget _buildDetectionOverlay() {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: DetectionOverlayPainter(
//             boundingBox: _handBoundingBox!,
//             pulseScale: _pulseAnimation.value,
//             detectedSign: _detectedSign,
//             confidence: _confidence,
//           ),
//           size: Size.infinite,
//         );
//       },
//     );
//   }

//   Widget _buildTopStatusOverlay() {
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: EdgeInsets.fromLTRB(
//           screenWidth * 0.04,
//           MediaQuery.of(context).padding.top + 8,
//           screenWidth * 0.04,
//           8,
//         ),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.black.withOpacity(0.6),
//               Colors.transparent,
//             ],
//           ),
//         ),
//         child: Row(
//           children: [
//             if (_handDetected)
//               AnimatedBuilder(
//                 animation: _fadeAnimation,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: _fadeAnimation.value,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: AppColors.success.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.pan_tool, color: Colors.white, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             'HAND DETECTED',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             const Spacer(),
//             if (_handDetected && _confidence > 0)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${(_confidence * 100).toInt()}%',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomControls() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bottomPadding = MediaQuery.of(context).padding.bottom;
    
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: EdgeInsets.fromLTRB(
//           screenWidth * 0.04,
//           8,
//           screenWidth * 0.04,
//           bottomPadding + 16,
//         ),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.black.withOpacity(0.4),
//             ],
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildControlButton(
//               icon: Icons.flip_camera_ios,
//               onTap: () {
//                 // TODO: Implement camera flip
//               },
//             ),
//             _buildControlButton(
//               icon: Icons.settings,
//               onTap: () {
//                 // TODO: Open settings
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.6),
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }

//   Widget _buildDetectionIndicator() {
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 80,
//       left: screenWidth * 0.04,
//       right: screenWidth * 0.04,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Processing sign detection...',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Icon(
//                 Icons.camera_alt,
//                 size: 48,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Initializing Camera...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height, 8),
//             Text(
//               'Setting up sign language detection',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(
//     String title,
//     String message,
//     IconData icon,
//     Color color,
//     VoidCallback onRetry,
//   ) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 48,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton.icon(
//                 onPressed: onRetry,
//                 icon: Icon(Icons.refresh),
//                 label: Text('Retry'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: color,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _fadeController.dispose();
//     _controller?.stopImageStream();
//     _controller?.dispose();
//     super.dispose();
//   }
// }

// class DetectionOverlayPainter extends CustomPainter {
//   final Rect boundingBox;
//   final double pulseScale;
//   final String detectedSign;
//   final double confidence;

//   DetectionOverlayPainter({
//     required this.boundingBox,
//     required this.pulseScale,
//     required this.detectedSign,
//     required this.confidence,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppColors.success
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;

//     // Draw bounding box with pulse effect
//     final scaledBox = Rect.fromCenter(
//       center: boundingBox.center,
//       width: boundingBox.width * pulseScale,
//       height: boundingBox.height * pulseScale,
//     );

//     // Draw main bounding box
//     canvas.drawRect(scaledBox, paint);

//     // Draw corner indicators
//     final cornerLength = 20.0;
//     final cornerPaint = Paint()
//       ..color = AppColors.success
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0;

//     // Draw all four corners
//     _drawCorners(canvas, scaledBox, cornerPaint, cornerLength);

//     // Draw detection label
//     _drawDetectionLabel(canvas, scaledBox);
//   }

//   void _drawCorners(Canvas canvas, Rect box, Paint paint, double length) {
//     // Top-left corner
//     canvas.drawLine(
//       Offset(box.left, box.top + length),
//       Offset(box.left, box.top),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(box.left, box.top),
//       Offset(box.left + length, box.top),
//       paint,
//     );

//     // Top-right corner
//     canvas.drawLine(
//       Offset(box.right - length, box.top),
//       Offset(box.right, box.top),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(box.right, box.top),
//       Offset(box.right, box.top + length),
//       paint,
//     );

//     // Bottom-left corner
//     canvas.drawLine(
//       Offset(box.left, box.bottom - length),
//       Offset(box.left, box.bottom),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(box.left, box.bottom),
//       Offset(box.left + length, box.bottom),
//       paint,
//     );

//     // Bottom-right corner
//     canvas.drawLine(
//       Offset(box.right - length, box.bottom),
//       Offset(box.right, box.bottom),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(box.right, box.bottom - length),
//       Offset(box.right, box.bottom),
//       paint,
//     );
//   }

//   void _drawDetectionLabel(Canvas canvas, Rect box) {
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: detectedSign,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           shadows: [
//             Shadow(
//               color: Colors.black.withOpacity(0.8),
//               blurRadius: 4,
//               offset: const Offset(1, 1),
//             ),
//           ],
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();

//     final labelRect = Rect.fromCenter(
//       center: Offset(box.center.dx, box.top - 20),
//       width: textPainter.width + 16,
//       height: textPainter.height + 8,
//     );

//     // Draw label background
//     final labelPaint = Paint()
//       ..color = AppColors.success.withOpacity(0.9)
//       ..style = PaintingStyle.fill;
    
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
//       labelPaint,
//     );

//     // Draw label border
//     final borderPaint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
    
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
//       borderPaint,
//     );

//     // Draw label text
//     textPainter.paint(
//       canvas,
//       Offset(
//         labelRect.left + 8,
//         labelRect.top + 4,
//       ),
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
// }

// class SimulatedCameraPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..style = PaintingStyle.fill;

//     // Draw animated grid pattern
//     final gridPaint = Paint()
//       ..color = Colors.white.withOpacity(0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;

//     // Vertical lines
//     for (int i = 0; i < size.width; i += 50) {
//       canvas.drawLine(
//         Offset(i.toDouble(), 0),
//         Offset(i.toDouble(), size.height),
//         gridPaint,
//       );
//     }

//     // Horizontal lines
//     for (int i = 0; i < size.height; i += 50) {
//       canvas.drawLine(
//         Offset(0, i.toDouble()),
//         Offset(size.width, i.toDouble()),
//         gridPaint,
//       );
//     }

//     // Draw some dynamic elements
//     final centerPaint = Paint()
//       ..color = Colors.white.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     // Draw center crosshair
//     final centerX = size.width / 2;
//     final centerY = size.height / 2;
//     final crossSize = 30.0;

//     canvas.drawLine(
//       Offset(centerX - crossSize, centerY),
//       Offset(centerX + crossSize, centerY),
//       centerPaint,
//     );
//     canvas.drawLine(
//       Offset(centerX, centerY - crossSize),
//       Offset(centerX, centerY + crossSize),
//       centerPaint,
//     );

//     // Draw corner frame indicators
//     final framePaint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3;

//     final frameSize = 40.0;
//     final margin = 20.0;

//     // Draw frame corners
//     _drawFrameCorner(canvas, Offset(margin, margin), frameSize, framePaint);
//     _drawFrameCorner(canvas, Offset(size.width - margin - frameSize, margin), frameSize, framePaint);
//     _drawFrameCorner(canvas, Offset(margin, size.height - margin - frameSize), frameSize, framePaint);
//     _drawFrameCorner(canvas, Offset(size.width - margin - frameSize, size.height - margin - frameSize), frameSize, framePaint);
//   }

//   void _drawFrameCorner(Canvas canvas, Offset position, double size, Paint paint) {
//     final cornerLength = size * 0.4;
    
//     // Top-left style corner
//     canvas.drawLine(
//       position,
//       Offset(position.dx + cornerLength, position.dy),
//       paint,
//     );
//     canvas.drawLine(
//       position,
//       Offset(position.dx, position.dy + cornerLength),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }