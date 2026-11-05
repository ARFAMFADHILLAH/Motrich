import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  // Create a simple icon based on the logo design
  // Blue gradient background with wallet icon
  final sizes = [48, 72, 96, 144, 192, 512, 1024];
  
  for (final size in sizes) {
    final image = img.Image(width: size, height: size);
    
    // Draw rounded rectangle background with gradient
    final radius = (size * 0.215).round(); // ~110/512 ratio
    final centerX = size / 2.0;
    final centerY = size / 2.0;
    final rectSize = (size * 0.625).round(); // ~320/512 ratio
    final rectX = ((size - rectSize) / 2).round();
    final rectY = (size * 0.3125).round(); // ~160/512 ratio
    final rectHeight = (size * 0.43).round(); // ~220/512 ratio
    
    // Fill background with rounded corners
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        // Check if point is inside rounded rect
        double dx = x - centerX;
        double dy = y - centerY;
        double dist = math.sqrt(dx * dx + dy * dy);
        
        if (dist < size / 2 - 2) {
          // Gradient from #1976D2 to #0D47A1
          double t = y / size;
          int r = (25 * (1 - t) + 13 * t).round();
          int g = (118 * (1 - t) + 71 * t).round();
          int b = (210 * (1 - t) + 161 * t).round();
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
    }
    
    // Draw wallet body (white rounded rect)
    final walletW = (size * 0.625).round();
    final walletH = (size * 0.43).round();
    final walletX = ((size - walletW) / 2).round();
    final walletY = (size * 0.273).round(); // ~140/512 ratio
    final walletRadius = (size * 0.0586).round(); // ~30/512 ratio
    
    for (int y = walletY; y < walletY + walletH; y++) {
      for (int x = walletX; x < walletX + walletW; x++) {
        // Rounded rect check
        double dx = x - (walletX + walletW / 2);
        double dy = y - (walletY + walletH / 2);
        if (dx.abs() < walletW / 2 - walletRadius && dy.abs() < walletH / 2 - walletRadius) {
          image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
        } else if (dx.abs() < walletW / 2 && dy.abs() < walletH / 2) {
          // Corner rounding
          double cornerX = dx.abs() - (walletW / 2 - walletRadius);
          double cornerY = dy.abs() - (walletH / 2 - walletRadius);
          if (cornerX > 0 && cornerY > 0 && (cornerX * cornerX + cornerY * cornerY) < walletRadius * walletRadius) {
            image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
          }
        }
      }
    }
    
    // Draw wallet flap (blue rect at top)
    final flapW = (size * 0.273).round(); // ~140/512 ratio
    final flapH = (size * 0.117).round(); // ~60/512 ratio
    final flapX = (size + walletW / 2 - flapW).round(); // Right side
    final flapY = walletY - flapH;
    final flapRadius = (size * 0.0234).round(); // ~12/512 ratio
    
    for (int y = flapY; y < flapY + flapH; y++) {
      for (int x = flapX; x < flapX + flapW; x++) {
        double dx = x - (flapX + flapW / 2);
        double dy = y - (flapY + flapH / 2);
        if (dx.abs() < flapW / 2 - flapRadius && dy.abs() < flapH / 2 - flapRadius) {
          image.setPixel(x, y, img.ColorRgb8(25, 118, 210));
        } else if (dx.abs() < flapW / 2 && dy.abs() < flapH / 2) {
          double cornerX = dx.abs() - (flapW / 2 - flapRadius);
          double cornerY = dy.abs() - (flapH / 2 - flapRadius);
          if (cornerX > 0 && cornerY > 0 && (cornerX * cornerX + cornerY * cornerY) < flapRadius * flapRadius) {
            image.setPixel(x, y, img.ColorRgb8(25, 118, 210));
          }
        }
      }
    }
    
    // Draw button on flap (white circle)
    final btnCx = flapX + (flapW / 2).round();
    final btnCy = flapY + (flapH * 0.5).round();
    final btnR = (size * 0.0234).round(); // ~12/512 ratio
    for (int y = btnCy - btnR; y <= btnCy + btnR; y++) {
      for (int x = btnCx - btnR; x <= btnCx + btnR; x++) {
        if ((x - btnCx) * (x - btnCx) + (y - btnCy) * (y - btnCy) <= btnR * btnR) {
          image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
        }
      }
    }
    
    // Draw chart line (blue path)
    final chartX1 = (size * 0.273).round(); // ~140/512
    final chartY1 = (size * 0.546).round(); // ~280/512
    final chartX2 = chartX1 + (size * 0.097).round(); // +50/512
    final chartY2 = chartY1 - (size * 0.097).round(); // -50/512
    final chartX3 = chartX2 + (size * 0.078).round(); // +40/512
    final chartY3 = chartY2 + (size * 0.0586).round(); // +30/512
    final chartX4 = chartX3 + (size * 0.136).round(); // +70/512
    final chartY4 = chartY3 - (size * 0.136).round(); // -70/512
    
    final strokeW = (size * 0.027).round(); // ~14/512
    
    // Draw line segments
    _drawLine(image, chartX1, chartY1, chartX2, chartY2, strokeW, img.ColorRgb8(25, 118, 210));
    _drawLine(image, chartX2, chartY2, chartX3, chartY3, strokeW, img.ColorRgb8(25, 118, 210));
    _drawLine(image, chartX3, chartY3, chartX4, chartY4, strokeW, img.ColorRgb8(25, 118, 210));
    
    // Save
    final outputPath = 'assets/icon/logo_${size}.png';
    File(outputPath).writeAsBytesSync(img.encodePng(image));
    print('Generated: $outputPath (${size}x${size})');
    
    if (size == 512) {
      File('assets/icon/logo.png').writeAsBytesSync(img.encodePng(image));
      print('Generated main logo.png');
    }
  }
}

void _drawLine(img.Image image, int x1, int y1, int x2, int y2, int strokeW, img.Color color) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final steps = (dx.abs() > dy.abs() ? dx.abs() : dy.abs()).toInt();
  if (steps == 0) return;
  for (int i = 0; i <= steps; i++) {
    final t = i / steps;
    final x = (x1 + dx * t).round();
    final y = (y1 + dy * t).round();
    for (int sy = -strokeW ~/ 2; sy <= strokeW ~/ 2; sy++) {
      for (int sx = -strokeW ~/ 2; sx <= strokeW ~/ 2; sx++) {
        if (x + sx >= 0 && x + sx < image.width && y + sy >= 0 && y + sy < image.height) {
          image.setPixel(x + sx, y + sy, color);
        }
      }
    }
  }
}
