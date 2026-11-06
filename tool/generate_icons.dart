import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> main() async {
  // Load the SVG bytes
  final svgBytes = await File('assets/icon/logo.svg').readAsBytes();
  
  // Sizes needed for different platforms
  final sizes = <int, String>{
    48: 'assets/icon/logo_48.png',
    72: 'assets/icon/logo_72.png',
    96: 'assets/icon/logo_96.png',
    144: 'assets/icon/logo_144.png',
    192: 'assets/icon/logo_192.png',
    512: 'assets/icon/logo_512.png',
    1024: 'assets/icon/logo_1024.png',
  };

  for (final entry in sizes.entries) {
    final size = entry.key.toDouble();
    final outputPath = entry.value;
    
    // Parse SVG and draw to canvas at target size
    final pictureInfo = await vg.loadPicture(SvgBytesLoader(svgBytes), null);
    final picture = pictureInfo.picture;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(size / pictureInfo.size.width, size / pictureInfo.size.height);
    canvas.drawPicture(picture);
    final scaledPicture = recorder.endRecording();
    
    // Convert to image
    final image = await scaledPicture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Write to file
    await File(outputPath).writeAsBytes(bytes);
    print('Generated: $outputPath (${size.toInt()}x${size.toInt()})');
    
    // Also save as main logo.png (512x512)
    if (size == 512) {
      await File('assets/icon/logo.png').writeAsBytes(bytes);
      print('Generated main logo.png');
    }
  }
}