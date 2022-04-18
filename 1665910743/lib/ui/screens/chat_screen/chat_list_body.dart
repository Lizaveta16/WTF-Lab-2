import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../widgets/event_tile.dart';
import '../../widgets/event_tile_actions.dart';
import '../settings/cubit/settings_cubit.dart';
import 'cubit/event_cubit.dart';

class ChatListBody extends StatefulWidget {
  final String categoryTitle;

  const ChatListBody({Key? key, required this.categoryTitle}) : super(key: key);

  @override
  State<ChatListBody> createState() => _ChatListBodyState();
}

class _ChatListBodyState extends State<ChatListBody> {
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var _eventCubit = context.read<EventCubit>();
    return Expanded(
      child: BlocBuilder<EventCubit, EventState>(
        bloc: _eventCubit,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              for (var element in _eventCubit.state.eventList) {
                _eventCubit.eventNotSelect(element.id!);
              }
            },
            child: ListView.builder(
              itemCount: state.eventList.length,
              itemBuilder: ((context, index) {
                if (widget.categoryTitle ==
                    state.eventList[index].categoryTitle) {
                  return Slidable(
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        EditAction(
                          event: state.eventList[index],
                          eventKey: state.eventList[index].id!,
                        ),
                        RemoveAction(eventKey: state.eventList[index].id!),
                        MoveAction(eventKey: state.eventList[index].id!),
                      ],
                    ),
                    child: Align(
                      alignment: BlocProvider.of<SettingsCubit>(context)
                          .state
                          .chatTileAlignment,
                      child: GestureDetector(
                        onDoubleTap: () =>
                            _copyToClipboard(state.eventList[index].title),
                        onLongPress: () {
                          if (state.eventList[index].isSelected == false) {
                            _eventCubit.eventSelect(state.eventList[index].id!);
                          } else {
                            _eventCubit
                                .eventNotSelect(state.eventList[index].id!);
                          }
                          HapticFeedback.heavyImpact();
                        },
                        child: EventTile(
                            iconCode: state.eventList[index].iconCode,
                            isSelected: state.eventList[index].isSelected,
                            title: state.eventList[index].title,
                            date: state.eventList[index].date,
                            favorite: state.eventList[index].favorite,
                            tag: state.eventList[index].tag,
                            image: (state.eventList[index].imageUrl != null)
                                ? Image(
                                    image: CachedNetworkImageProvider(
                                        state.eventList[index].imageUrl!),
                                    width: 90,
                                    height: 90,
                                  )
                                : null),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ),
          );
        },
      ),
    );
  }
}
