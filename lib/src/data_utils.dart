
import 'dart:convert';

import 'dart:typed_data';

enum ImageType {
  JPEG,
  PNG
}

class ImageData extends BytesData {

  final ImageType _type ;

  ImageType get type => _type ;

  ImageData(this._type, Uint8List document) : super(document) ;

  ImageData.fromBase64(this._type, String dataBase64) : super.fromBase64(dataBase64) ;

}

class BytesData {

  static bool isDataURL(String base64) {
    if ( !base64.startsWith('data:') || !base64.contains(';base64,') ) return false ;
    return true ;
  }

  bool _bigEndian = true ;

  Uint8List _bytes ;

  BytesData(this._bytes) ;

  BytesData.fromBase64(String dataBase64) {
    if ( isDataURL(dataBase64) ) {
      var idx = dataBase64.indexOf(',');
      dataBase64 = dataBase64.substring( idx+1 ) ;
    }
    
    _bytes = Base64Decoder().convert(dataBase64);
  }

  List<int> get bytes => _bytes;

  bool get isBigEndian => _bigEndian ;

  void setBigEndian(bool bigEndian) {
    _bigEndian = bigEndian ;
  }

  int get(int i) {
    return _bytes[i] ;
  }

  int _pos = 0 ;

  int get position => _pos ;

  void reset() {
    _pos = 0 ;
  }

  int remaining() {
    return _bytes.length - _pos ;
  }

  int next() {
    var byte = _bytes[_pos] ;
    _pos++ ;
    return byte ;
  }

  int next16() {
    var v1 = next() ;
    var v2 = next() ;

    int v ;
    if (_bigEndian) {
      v = (v1 << 8) | v2 ;
    }
    else {
      v = (v2 << 8) | v1 ;
    }

    return v ;
  }

  int next32() {
    var v1 = next() ;
    var v2 = next() ;
    var v3 = next() ;
    var v4 = next() ;

    int v ;
    if (_bigEndian) {
      v = (v1 << 24) | (v2 << 16) | (v3 << 8) | v4 ;
    }
    else {
      v = (v4 << 24) | (v3 << 16) | (v2 << 8) | v1 ;
    }

    return v ;
  }

  List<int> nextBlock(int size) {
    var block = _bytes.sublist(_pos, _pos+size) ;
    _pos += size ;
    return block ;
  }

  bool equals(Uint8List document) {
    var lng = _bytes.length ;
    if ( document.length < lng ) lng = document.length ;

    for (var i = 0; i < lng; ++i) {
      var b1 = _bytes[i];
      var b2 = document[i];

      if (b1 != b2) return false ;
    }

    return true ;
  }

  void skip(int skip) {
    if (skip > 0) {
      _pos += skip ;
    }
  }

}

enum ImageOrientation {
  ORIENTATION_0 ,
  ORIENTATION_0_FLIP ,

  ORIENTATION_180 ,
  ORIENTATION_180_FLIP ,

  ORIENTATION_270_FLIP ,
  ORIENTATION_270 ,

  ORIENTATION_90_FLIP ,
  ORIENTATION_90 ,
}

class ImageMetadata {

  final ImageType imageType ;
  final Map<String, ImageMetadataValue> _entries ;

  ImageMetadata(this.imageType, this._entries) ;

  Map<String, ImageMetadataValue> asMap() => Map.from(_entries) ;

  ImageMetadataValue get(String key) {
    return _entries[key] ;
  }

  int get size => _entries.length ;

  List<String> get keys => List.from(_entries.keys) ;

  int getInt(String key) {
    var imageMetadataValue = get(key) ;
    if (imageMetadataValue == null) return null ;
    int val = imageMetadataValue.values[0] ;
    return val ;
  }

  int getImageWidth() {
    if ( imageType == ImageType.JPEG ) {
      return getInt('EXIF ExifImageWidth') ;
    }
    else {
      return null ;
    }
  }

  int getImageHeight() {
    if ( imageType == ImageType.JPEG ) {
      return getInt('EXIF ExifImageLength') ;
    }
    else {
      return null ;
    }
  }

  int getImageOrientationID() {
    if ( imageType == ImageType.JPEG ) {
      var imageMetadataValue = get('Image Orientation') ;
      if (imageMetadataValue == null) return null ;
      int orientation = imageMetadataValue.values[0] ;
      return orientation ;
    }
    else {
      return null ;
    }
  }

  ImageOrientation getImageOrientation() {
    var orientation = getImageOrientationID() ;
    if (orientation == null) return null ;

    if ( orientation == null || orientation <= 1 ) {
      return ImageOrientation.ORIENTATION_0 ;
    }
    else if (orientation == 8) {
      return ImageOrientation.ORIENTATION_90 ;
    }
    else if (orientation == 3) {
      return ImageOrientation.ORIENTATION_180 ;
    }
    else if (orientation == 6) {
      return ImageOrientation.ORIENTATION_270 ;
    }

    else if (orientation == 2) {
      return ImageOrientation.ORIENTATION_0_FLIP ;
    }
    else if (orientation == 7) {
      return ImageOrientation.ORIENTATION_90_FLIP ;
    }
    else if (orientation == 4) {
      return ImageOrientation.ORIENTATION_180_FLIP ;
    }
    else if (orientation == 5) {
      return ImageOrientation.ORIENTATION_270_FLIP ;
    }

    throw UnsupportedError("Can't handle orientation: $orientation") ;
  }

}

class ImageMetadataValue {
  // tag ID number
  final int tag;

  final String tagType;

  // printable version of document
  final String printable;

  // list of document items (int(char or number) or Ratio)
  final List values;

  ImageMetadataValue(this.tag, this.tagType, this.printable, this.values);

  @override
  String toString() {
    if (values == null || values.isEmpty) return '' ;

    if (values.length > 2) {
      var iterable = Iterable.generate(values.length , (i) => values[i]) ;
      return String.fromCharCodes(iterable);
    }

    return '$values' ;
  }

}

class ImageTransform {

  final ImageOrientation orientation ;
  final int width ;
  final int height ;

  final int m00;
  final int m10;
  final int m01;
  final int m11;
  final int m02;
  final int m12;

  ImageTransform(this.m00, this.m10, this.m01, this.m11, this.m02, this.m12, [this.width, this.height, this.orientation]) ;

  int get v0 => m00 ;
  int get v1 => m10 ;
  int get v2 => m01 ;
  int get v3 => m11 ;
  int get v4 => m02 ;
  int get v5 => m12 ;

  factory ImageTransform.fromOrientation(ImageOrientation orientation, int width, int height) {
    if (orientation == null) return ImageTransform(1, 0, 0, 1, 0, 0) ;

    switch (orientation.index+1) {
      case 1: return ImageTransform(1, 0, 0, 1, 0, 0, width,height, orientation);
      case 2: return ImageTransform(-1, 0, 0, 1, width, 0, width,height, orientation);
      case 3: return ImageTransform(-1, 0, 0, -1, width, height, width,height, orientation);
      case 4: return ImageTransform(1, 0, 0, -1, 0, height, width,height, orientation);
      case 5: return ImageTransform(0, 1, 1, 0, 0, 0, width,height, orientation);
      case 6: return ImageTransform(0, 1, -1, 0, height, 0, width,height, orientation);
      case 7: return ImageTransform(0, -1, -1, 0, height, width, width,height, orientation);
      case 8: return ImageTransform(0, -1, 1, 0, 0, width, width,height, orientation);
      default: return ImageTransform(1, 0, 0, 1, 0, 0, width,height, orientation);
    }
  }

  bool get isWidthHeightSwappedOnTransform {
    return
      orientation == ImageOrientation.ORIENTATION_180 || orientation == ImageOrientation.ORIENTATION_180_FLIP ||
      orientation == ImageOrientation.ORIENTATION_270 || orientation == ImageOrientation.ORIENTATION_270_FLIP
    ;
  }

  int getTransformedWidth() {
    if ( isWidthHeightSwappedOnTransform ) {
      return height ;
    }
    return width ;
  }

  int getTransformedHeight() {
    if ( isWidthHeightSwappedOnTransform ) {
      return width ;
    }
    return height ;
  }

  bool get isLandscape => width > height ;
  bool get isLandscapeOnTransform => getTransformedWidth() > getTransformedHeight() ;

  @override
  String toString() {
    return 'ImageTransform{orientation: $orientation, dimension: $width x $height ; m00: $m00, m10: $m10, m01: $m01, m11: $m11, m02: $m02, m12: $m12 ; LandscapeOnTransform: ${ isLandscapeOnTransform } ; WidthHeightSwappedOnTransform: ${ isWidthHeightSwappedOnTransform }';
  }

}

