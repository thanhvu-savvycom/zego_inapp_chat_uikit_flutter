import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:zego_imkit/utils/custom_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../zego_imkit.dart';

// featureList
class ZegoMessageListView extends StatefulWidget {
  const ZegoMessageListView({
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

  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onLongPress;
  final Widget Function(BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)? itemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)? loadingBuilder;

  // theme
  final ThemeData? theme;

  @override
  State<ZegoMessageListView> createState() => _ZegoMessageListViewState();
}

class _ZegoMessageListViewState extends State<ZegoMessageListView> {
  final ScrollController _defaultScrollController = ScrollController();

  ScrollController get _scrollController => widget.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;

  @override
  void initState() {
    initializeDateFormatting('vi_vn', "");
    ZegoIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    ZegoIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  void scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 == await ZegoIMKit().loadMoreMessage(widget.conversationID, widget.conversationType)) {
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
          future: ZegoIMKit().getMessageListNotifier(widget.conversationID, widget.conversationType),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ValueListenableBuilder(
                valueListenable: snapshot.data as ValueNotifier<List<ZegoIMKitMessage>>,
                builder: (BuildContext context, List<ZegoIMKitMessage> messageList, Widget? child) {
                  ZegoIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
                  return LayoutBuilder(builder: (context, BoxConstraints constraints) {
                    ZegoIMKitLogger.fine('messageList constraints: $constraints');
                    return listMessageWidget(messageList);
                    return ListView.separated(
                      reverse: true,
                      padding: EdgeInsets.all(20.h),
                      controller: _scrollController,
                      itemCount: messageList.length,
                      separatorBuilder: (context, index) {
                        return 24.verticalSpace;
                      },
                      itemBuilder: (context, index) {
                        int reversedIndex = messageList.length - index - 1;
                        ZegoIMKitMessage message = messageList[reversedIndex];
                        // defaultWidget
                        Widget defaultWidget = ZegoIMKitMessageWidget(
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
              Widget defaultWidget = Center(
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
                child: widget.errorBuilder?.call(context, defaultWidget) ?? defaultWidget,
              );
            } else {
              // defaultWidget
              Widget defaultWidget = const Center(child: CircularProgressIndicator());

              // customWidget
              return widget.loadingBuilder?.call(context, defaultWidget) ?? defaultWidget;
            }
          },
        ),
      ),
    );
  }

  Widget listMessageWidget(List<ZegoIMKitMessage> messageList) {
    return GroupedListView(
      shrinkWrap: true,
      elements: messageList,
      reverse: true,
      padding: EdgeInsets.all(20.h),
      controller: _scrollController,
      groupBy: (ZegoIMKitMessage element) {
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
      itemComparator: (ZegoIMKitMessage data1, ZegoIMKitMessage data2) {
        return data1.data.value.timestamp.compareTo(data2.data.value.timestamp);
      },
      order: GroupedListOrder.DESC,
      // optional
      separator: 24.verticalSpace,
      itemBuilder: (context, ZegoIMKitMessage item) {
        int reversedIndex = messageList.length -
            messageList.indexWhere((element) => element.data.value.messageID == item.data.value.messageID) -
            1;
        ZegoIMKitMessage message = messageList[reversedIndex];
        // defaultWidget
        Widget defaultWidget = ZegoIMKitMessageWidget(
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
      floatingHeader: false,
    );
  }
}
