part of '../../firecraft.dart';

class BlobConv implements JsonConverter<Uint8List, Blob> {
  const BlobConv();

  @override
  Uint8List fromJson(Blob json) => json.bytes;

  @override
  Blob toJson(Uint8List object) => Blob(object);
}

class BlobNConv implements JsonConverter<Uint8List?, Blob?> {
  const BlobNConv();

  @override
  Uint8List? fromJson(Blob? json) => json?.bytes;

  @override
  Blob? toJson(Uint8List? object) => object == null ? null : Blob(object);
}
