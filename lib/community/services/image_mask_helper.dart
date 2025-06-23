import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageMaskHelper {
  /// 투명 배경제거 이미지에서 흰/검 마스크 이미지 생성
  /// 투명 영역은 검정색, 불투명 영역은 흰색으로 1x1 사각형 칠함
  static Future<File?> createMaskFromTransparentImage(
    File transparentImageFile,
  ) async {
    try {
      final bytes = await transparentImageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paintWhite = Paint()..color = Colors.white;
      final paintBlack = Paint()..color = Colors.black;

      final width = image.width;
      final height = image.height;

      final pixelData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (pixelData == null) return null;

      // 캔버스 배경 검정색 채우기
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        paintBlack,
      );

      final pixels = pixelData.buffer.asUint8List();

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final offset = (y * width + x) * 4;
          final alpha = pixels[offset + 3];
          if (alpha > 128) {
            // 불투명 영역 1x1 사각형으로 칠하기
            canvas.drawRect(
              Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
              paintWhite,
            );
          }
          // 투명 영역은 검정색 그대로 유지
        }
      }

      final picture = recorder.endRecording();
      final maskImage = await picture.toImage(width, height);
      final byteData2 = await maskImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData2 == null) return null;

      final pngBytes = byteData2.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final maskFile = File('${dir.path}/mask_from_transparent.png');
      await maskFile.writeAsBytes(pngBytes);

      return maskFile;
    } catch (e) {
      debugPrint('Error creating mask image: $e');
      return null;
    }
  }

  /// 마스크 이미지를 원본 이미지 크기에 맞게 리사이징
  static Future<File?> resizeMaskToMatch(
    File maskFile,
    File originalFile,
  ) async {
    try {
      final originalBytes = await originalFile.readAsBytes();
      final originalCodec = await ui.instantiateImageCodec(originalBytes);
      final originalFrame = await originalCodec.getNextFrame();
      final originalImage = originalFrame.image;

      final maskBytes = await maskFile.readAsBytes();
      final maskCodec = await ui.instantiateImageCodec(
        maskBytes,
        targetWidth: originalImage.width,
        targetHeight: originalImage.height,
      );
      final maskFrame = await maskCodec.getNextFrame();
      final resizedMaskImage = maskFrame.image;

      final byteData = await resizedMaskImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final resizedMaskFile = File('${dir.path}/resized_mask.png');
      await resizedMaskFile.writeAsBytes(pngBytes);

      return resizedMaskFile;
    } catch (e) {
      debugPrint('Error resizing mask image: $e');
      return null;
    }
  }
}
