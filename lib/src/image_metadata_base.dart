
import 'data_utils.dart';
import 'jpeg_image_metadata.dart';

class ImageMetadataReader {

  final ImageData _imageData ;

  ImageMetadataReader(this._imageData);

  ImageMetadata read() {

    var type = _imageData.type ;

    if (type == ImageType.JPEG) {
      var jpegMetadataReader = JpegMetadataReader(_imageData);
      return jpegMetadataReader.read() ;
    }
    else if (type == ImageType.PNG) {
      return PNGMetadataReader(_imageData).read() ;
    }
    else {
      throw UnsupportedError("Can't handle type: $type") ;
    }

  }

}


class PNGMetadataReader {

  final ImageData _imageData ;

  PNGMetadataReader(this._imageData);

  ImageMetadata read() {
    return ImageMetadata(ImageType.PNG, {}) ;
  }

}

