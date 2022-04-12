import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/event.dart';
import '../screens/Chat_Screen/edit_chat_item_dialog.dart';
import '../screens/Chat_Screen/move_event_tile.dart';
import '../screens/chat_screen/cubit/event_cubit.dart';

class EditAction extends StatelessWidget {
  final Event event;
  final String eventKey;

  const EditAction({
    Key? key,
    required this.event,
    required this.eventKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      onPressed: (context) => chatTileEditDialog(
        isBookmarked: event.favorite,
        key: eventKey,
        title: event.title,
        context: context,
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).primaryColor,
      icon: Icons.edit,
    );
  }
}

class MoveAction extends StatelessWidget {
  final String eventKey;
  MoveAction({
    Key? key,
    required this.eventKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      autoClose: true,
      onPressed: (context) {
        moveTile(context: context, eventKey: eventKey);
      },
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).primaryColor,
      icon: Icons.move_down,
    );
  }
}

class RemoveAction extends StatelessWidget {
  final String eventKey;

  const RemoveAction({
    Key? key,
    required this.eventKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      onPressed: (context) =>
          context.read<EventCubit>().removeEventInCategory(key: eventKey),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).primaryColor,
      icon: Icons.delete,
    );
  }
}
