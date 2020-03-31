
import 'package:exif/src/exif_types.dart';
import 'package:exif/src/file_interface.dart';
import 'package:exif/src/read_exif.dart';

import 'data_utils.dart';

class JpegMetadataReader {

  final ImageData _imageData ;

  JpegMetadataReader(this._imageData);

  ImageMetadata read() {
    var fileReader = FileReader.fromBytes( _imageData.bytes );
    var table = readExifFromFileReader(fileReader) ;

    var document = <String, ImageMetadataValue>{} ;

    table.forEach( (k,t) => document[k] = _toImageMetadataValue(t) ) ;

    return ImageMetadata(ImageType.JPEG, document) ;
  }

  ImageMetadataValue _toImageMetadataValue(IfdTag tag) {
    return ImageMetadataValue(tag.tag, tag.tagType, tag.printable, tag.values) ;
  }

}
