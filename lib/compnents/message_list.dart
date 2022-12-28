import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:zego_zimkit/utils/custom_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zego_zimkit/services/defines.dart';
import '../zego_zimkit.dart';

// featureList
class ZIMKitMessageListView extends StatefulWidget {
  const ZIMKitMessageListView({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onPressed,
    this.itemBuilder,
    this.loadingBuilder,
    this.onLongPress,
    this.errorBuilder,
    this.scrollController,
    this.theme,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  final ScrollController? scrollController;

  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onLongPress;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      itemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      loadingBuilder;

  // theme
  final ThemeData? theme;

  @override
  State<ZIMKitMessageListView> createState() => _ZIMKitMessageListViewState();
}

class _ZIMKitMessageListViewState extends State<ZIMKitMessageListView> {
  final ScrollController _defaultScrollController = ScrollController();
  ScrollController get _scrollController =>
      widget.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;

  @override
  void initState() {
    initializeDateFormatting('vi_vn', "");
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  void scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >=
          0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 ==
            await ZIMKit().loadMoreMessage(
                widget.conversationID, widget.conversationType)) {
          _scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context).copyWith(backgroundColor: white),
      child: Expanded(
        child: FutureBuilder(
          future: ZIMKit().getMessageListNotifier(
              widget.conversationID, widget.conversationType),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ValueListenableBuilder(
                valueListenable:
                    snapshot.data! as ValueNotifier<List<ZIMKitMessage>>,
                builder: (BuildContext context, List<ZIMKitMessage> messageList,
                    Widget? child) {
                  ZIMKit().clearUnreadCount(
                      widget.conversationID, widget.conversationType);
                  if (messageList.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 50.w),
                      child: Text(
                        "Gửi tin nhắn đến chuyên gia của chúng tôi để nhận tư vấn nhé!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.body1.copyWith(color: dark6),
                      ),
                    );
                  } else {
                    return listMessageWidget(messageList);
                  }
                  return LayoutBuilder(
                      builder: (context, BoxConstraints constraints) {
                    return ListView.separated(
                      cacheExtent: constraints.maxHeight * 3,
                      reverse: true,
                      padding: EdgeInsets.all(20.h),
                      controller: _scrollController,
                      itemCount: messageList.length,
                      separatorBuilder: (context, index) {
                        return 24.verticalSpace;
                      },
                      itemBuilder: (context, index) {
                        int reversedIndex = messageList.length - index - 1;
                        ZIMKitMessage message = messageList[reversedIndex];
                        // defaultWidget
                        Widget defaultWidget = ZIMKitMessageWidget(
                          key: ValueKey(message.hashCode),
                          message: message,
                          onPressed: widget.onPressed,
                          onLongPress: widget.onLongPress,
                        );
                        // TODO spacing
                        // TODO 时间间隔
                        // customWidget
                        return widget.itemBuilder?.call(context, message, defaultWidget) ?? defaultWidget;
                      },
                    );
                  });
                },
              );
            } else if (snapshot.hasError) {
              // TODO 未实现加载失败
              // defaultWidget
              final Widget defaultWidget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    Text(snapshot.error.toString()),
                    const Text('Không thể tải. Vui lòng thử lại.'),
                  ],
                ),
              );

              // customWidget
              return GestureDetector(
                onTap: () => setState(() {}),
                child: widget.errorBuilder?.call(context, defaultWidget) ??
                    defaultWidget,
              );
            } else {
              // defaultWidget
              const Widget defaultWidget =
                  Center(child: CircularProgressIndicator());

              // customWidget
              return widget.loadingBuilder?.call(context, defaultWidget) ??
                  defaultWidget;
            }
          },
        ),
      ),
    );
  }

  bool isSameUserPreviousMsg(List<ZIMKitMessage> messageList, int index) {
    if (index == 0 || messageList.length < 2) {
      return false;
    } else {
      ZIMKitMessage currentMsg = messageList[index];
      ZIMKitMessage previousMsg = messageList[index - 1];
      return currentMsg.isSender == previousMsg.isSender && currentMsg.senderUserID == previousMsg.senderUserID;
    }
  }

  bool isSameUserNextMsg(List<ZIMKitMessage> messageList, int index) {
    if (index == messageList.length - 1) {
      return false;
    } else {
      ZIMKitMessage currentMsg = messageList[index];
      ZIMKitMessage nextMsg = messageList[index + 1];
      return currentMsg.isSender == nextMsg.isSender && currentMsg.senderUserID == nextMsg.senderUserID;
    }
  }

  Widget listMessageWidget(List<ZIMKitMessage> messageList) {
    return GroupedListView(
      shrinkWrap: true,
      elements: messageList,
      reverse: true,
      padding: EdgeInsets.all(20.h),
      controller: _scrollController,
      groupBy: (ZIMKitMessage element) {
        DateTime time = DateTime.fromMillisecondsSinceEpoch(element.data.value.timestamp);
        return DateTime(time.year, time.month, time.day);
      },
      groupSeparatorBuilder: (DateTime element) {
        return Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
          child: Text(
            (DateTime.now().difference(element).inDays > 365 ? DateFormat.yMMMMd('vi_VN') : DateFormat.MMMMd('vi_VN'))
                .format(element),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLargeText.copyWith(color: dark9),
          ),
        );
      },
      itemComparator: (ZIMKitMessage data1, ZIMKitMessage data2) {
        return data1.data.value.timestamp.compareTo(data2.data.value.timestamp);
      },
      order: GroupedListOrder.ASC,
      // optional
      separator: 0.verticalSpace,
      itemBuilder: (context, ZIMKitMessage item) {
        int reversedIndex = messageList.length -
            messageList.indexWhere((element) => element.data.value.messageID == item.data.value.messageID) -
            1;
        ZIMKitMessage message = messageList[reversedIndex];
        // defaultWidget
        Widget defaultWidget = ZIMKitMessageWidget(
          key: ValueKey(message.hashCode),
          message: message,
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          isSameUserNextMsg: isSameUserNextMsg(messageList, reversedIndex),
          isSameUserPreviousMsg: isSameUserPreviousMsg(messageList, reversedIndex),
        );
        // TODO spacing
        // TODO 时间间隔
        // customWidget
        return Container(
          margin: EdgeInsets.only(top: (isSameUserPreviousMsg(messageList, reversedIndex) ? 5 : 24).h),
            child: widget.itemBuilder?.call(context, message, defaultWidget) ?? defaultWidget);
      },
      floatingHeader: false,
    );
  }
}
