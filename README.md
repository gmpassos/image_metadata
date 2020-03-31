# image_metadata

Reads image metadata (Exif), including width, height and orientation.

## Usage

A simple usage example:

```dart
import 'package:image_metadata/image_metadata.dart';

main() {

  var imageBase64 = '...' ;
  var imageData = ImageData.fromBase64(ImageType.JPEG, imageBase64) ;

  var metadataReader = new ImageMetadataReader(imageData) ;
  
  var imageMetadata = metadataReader.read() ;

  var w = imageMetadata.getImageWidth() ;
  var h = imageMetadata.getImageHeight() ;
  var orientation = imageMetadata.getImageOrientation() ;

}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/image_metadata/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
