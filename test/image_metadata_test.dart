
import 'dart:convert';
import 'dart:io';

import 'package:image_metadata/image_metadata.dart';
import 'package:test/test.dart';



void main() {
  group('test-exiforientation', () {

    setUp(() {

    });

    test('Test Images Orientations', () async {

      var dir = Directory('./test/test-exiforientation') ;

      var dirList = await dir.list().toList() ;

      var files = dirList.where( (f) => f.path.endsWith('.jpg') ).map( (f) => File(f.path) ).toList() ;

      expect( files.length , equals(8) );

      for (var file in files) {
        print(file) ;

        var idx = file.path.length-6;
        var fileOrientationID = int.parse( file.path.substring( idx , idx+1 ) ) ;

        expect( fileOrientationID , greaterThanOrEqualTo(0) );

        var fileData = file.readAsBytesSync() ;

        expect( fileData.length , greaterThanOrEqualTo(10) );

        var fileBase64 = base64.encode(fileData) ;

        expect( fileBase64.length , greaterThan( fileData.length ) );

        var imageData = ImageData.fromBase64(ImageType.JPEG, fileBase64) ;
        var metadataReader = ImageMetadataReader(imageData) ;

        var imageMetadata = metadataReader.read() ;

        var orientationID = imageMetadata.getImageOrientationID() ;

        expect( orientationID , equals(fileOrientationID) );

        var orientation = imageMetadata.getImageOrientation() ;

        expect( orientation.index , equals(fileOrientationID-1) );

      }

    });

  });
}

