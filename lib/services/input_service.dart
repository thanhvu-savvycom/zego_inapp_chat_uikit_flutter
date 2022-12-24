part of 'services.dart';

mixin ZegoInputService {
  Future<List<PlatformFile>> pickFiles({FileType type = FileType.any, bool allowMultiple = true}) async {
    try {
      zegoIMKitRequestPermission(Permission.storage);
      // see https://github.com/miguelpruivo/flutter_file_picker/wiki/API#-filepickerpickfiles
      return (await FilePicker.platform.pickFiles(type: type, allowMultiple: allowMultiple))?.files ?? [];
    } on PlatformException catch (e) {
      ZegoIMKitLogger.severe('Unsupported operation $e');
    } catch (e) {
      ZegoIMKitLogger.severe(e.toString());
    }
    return [];
  }

  ZIMMessageType getMessageTypeByFileExtension(PlatformFile file) {
    const List<String> supportImageList = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff']; // <10M
    const List<String> supportVideoList = ['mp4', 'mov']; // <100M
    const List<String> supportAudioList = ['mp3', 'm4a']; // <300s, <6M

    ZIMMessageType messageType = ZIMMessageType.file;

    if (supportImageList.contains(file.extension)) {
      messageType = ZIMMessageType.image;
    } else if (supportVideoList.contains(file.extension)) {
      messageType = ZIMMessageType.video;
    } else if (supportAudioList.contains(file.extension)) {
      messageType = ZIMMessageType.audio;
    }

    // TODO check file limit
    return messageType;
  }

  ZIMMessageType getMessageTypeByFileExtension2(XFile file) {
    const List<String> supportImageList = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff']; // <10M
    const List<String> supportVideoList = ['mp4', 'mov']; // <100M
    const List<String> supportAudioList = ['mp3', 'm4a']; // <300s, <6M

    ZIMMessageType messageType = ZIMMessageType.file;

    String? ext = extension(file.path);
    if (supportImageList.contains(ext)) {
      messageType = ZIMMessageType.image;
    } else if (supportVideoList.contains(ext)) {
      messageType = ZIMMessageType.video;
    } else if (supportAudioList.contains(ext)) {
      messageType = ZIMMessageType.audio;
    }

    // TODO check file limit
    return messageType;
  }

  String? extension(String path) => path.split('.').last;

}
