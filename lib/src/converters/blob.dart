part of firestorex;

class BlobConv implements JsonConverter<Uint8List, Blob> {
  const BlobConv();

  @override
  Uint8List fromJson(Blob json) => json.bytes;

  @override
  Blob toJson(Uint8List object) => Blob(object);
}

class NullBlobConv implements JsonConverter<Uint8List?, Blob?> {
  const NullBlobConv();

  @override
  Uint8List? fromJson(Blob? json) => json?.bytes;

  @override
  Blob? toJson(Uint8List? object) => object == null ? null : Blob(object);
}
