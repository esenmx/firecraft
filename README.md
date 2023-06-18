# WORK IN PROGRESS

# firecraft

A comprehensive companion package for `Cloud Firestore` apps.

## Features

- Full Text Search support(with limitations, please read below)§
- Pagination scrollables for both `Live` and `Static` Query's
- [JsonConverter][JsonConverter]'s for [Blob][Blob], [Timestamp][Timestamp], [Duration][Duration] types, additionally optimizers like [NestedArray]
- [Unmodifiable Collection] methods like `copyAdd`, `copyRemove` and much more...
- Many helpers

## Full Text Search

Two types of text searches are supported:

### textSearchMap / containsAll

`textSearchMap`

### textSearchMap / containsAny

[JsonConverter]:https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonConverter-class.html
[Blob]:https://pub.dev/documentation/cloud_firestore_platform_interface/latest/cloud_firestore_platform_interface/Blob-class.html
[Duration]:https://api.dart.dev/be/180361/dart-core/Duration-class.html
[Timestamp]:https://pub.dev/documentation/cloud_firestore_platform_interface/latest/cloud_firestore_platform_interface/Timestamp-class.html
