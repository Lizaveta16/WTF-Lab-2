import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/icons.dart';
import '../../models/event.dart';
import 'event_page_cubit.dart';
import 'event_page_state.dart';

class EventPage extends StatefulWidget {
  final String title;
  final List<Event> events;

  const EventPage({
    Key? key,
    required this.title,
    required this.events,
  }) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  EventPageCubit? _cubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cubit = BlocProvider.of<EventPageCubit>(context);
    _cubit?.initValues(widget.title);
    return BlocBuilder<EventPageCubit, EventPageState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: state.editMode
              ? _editAppBar(context, state, _cubit!)
              : state.searchMode
                  ? _searchAppBar(_cubit!)
                  : _appBar(state, _cubit!),
          body: Column(
            children: [
              state.events.isEmpty
                  ? _bodyWithoutEvents()
                  : state.favoriteMode
                      ? _bodyFavorite(state, _cubit!)
                      : _bodyWithEvents(state, _cubit!),
              Align(
                child: _inputTextField(state, _cubit!),
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bodyWithoutEvents() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(18.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text(
                'This is the page where you can track everything about ${widget.title}!\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).bottomAppBarColor,
                ),
              ),
              Text(
                'Add your first event to ${widget.title} page by entering some text in the text below and hitting the send button. Long tap the send button to allign the event in the opposite direction. Tap on the bookmark icon on the top right corner to show the bookbark events only.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputTextField(EventPageState state, EventPageCubit cubit) {
    return Column(
      children: [
        Visibility(
          visible: state.isScrollbarVisible,
          child: Scrollbar(
            controller: _scrollController,
            child: Container(
              height: 100,
              child: ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: IconButton(
                          icon: icons.elementAt(state.chats[index].icon),
                          onPressed: () => _cubit!.selectCategory(index),
                          iconSize: 45,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          state.chats[index].category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  );
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
            isAlwaysShown: false,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _cubit!.changeVisibility,
              icon: const Icon(Icons.bubble_chart),
            ),
            Expanded(
              child: TextField(
                onChanged: _cubit!.changeWritingMode,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Enter event',
                  filled: true,
                ),
                controller: _controller,
              ),
            ),
            state.writingMode
                ? _sendIconButton(state)
                : IconButton(
                    onPressed: _cubit!.attachImage,
                    icon: const Icon(
                      Icons.image,
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  Widget _sendIconButton(EventPageState state) {
    return IconButton(
      onPressed: () {
        _cubit!.addNewEvent(_controller.text, widget.title);
        _controller.text = '';
      },
      icon: const Icon(
        Icons.send,
      ),
    );
  }

  AppBar _appBar(EventPageState state, EventPageCubit cubit) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(widget.title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: _cubit!.changeSearchMode,
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: _cubit!.changeFavoriteMode,
          icon: const Icon(Icons.bookmark_border),
        ),
      ],
    );
  }

  AppBar _searchAppBar(EventPageCubit cubit) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
        ),
        Expanded(
          child: TextField(
            textAlignVertical: TextAlignVertical.bottom,
            decoration: const InputDecoration(
              hintText: 'Enter event',
              filled: true,
            ),
            controller: _searchController,
            onChanged: (text) {
              _cubit!.setSearchMode(true);
              _cubit!.search(text);
            },
          ),
        ),
        IconButton(
            onPressed: () {
              _cubit!.changeSearchMode();
              _searchController.text = '';
            },
            icon: const Icon(Icons.close))
      ],
    );
  }

  AppBar _editAppBar(
      BuildContext context, EventPageState state, EventPageCubit cubit) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        onPressed: () {
          _cubit!.changeEditMode();
          _cubit!.cancelSelection();
        },
        icon: const Icon(Icons.close),
      ),
      title: const Center(
        child: Text('Edit mode'),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _migrateDialog(context, state, _cubit!);
          },
          icon: Icon(
            Icons.reply,
            color: Theme.of(context).highlightColor,
          ),
        ),
        if (state.events
                .where((element) => element.isSelected == true)
                .length ==
            1)
          IconButton(
            onPressed: () => _cubit!.copyEventText(_controller),
            icon: const Icon(Icons.edit),
          ),
        IconButton(
          onPressed: () {
            var text = '';
            var it = state.events
                .where((element) => element.isSelected == true)
                .iterator;
            while (it.moveNext()) {
              text += '${it.current.description}' '\n';
            }

            Clipboard.setData(ClipboardData(text: text));
            for (var element in state.events) {
              element = element.copyWith(
                isSelected: false,
              );
            }
          },
          icon: const Icon(Icons.copy),
        ),
        IconButton(
          onPressed: _cubit!.copy,
          icon: const Icon(Icons.bookmark_outline),
        ),
        IconButton(
          onPressed: () => _dialog(state, context, _cubit!),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _bodyFavorite(EventPageState state, EventPageCubit cubit) {
    return Expanded(
      child: ListView.builder(
        itemCount:
            state.events.where((element) => element.isFavorite == true).length,
        itemBuilder: (context, index) => Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              _cubit!.setSelectedIndex(index, _searchController);
            },
            onLongPress: () {
              _cubit!.selectEvent(index);
            },
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: state.events[index].isFavorite
                      ? Colors.green[300]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.image != null)
                      Image.file(
                        File(state.image!),
                        width: 100,
                        height: 100,
                      ),
                    Text(
                      state.events[index].description,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    Text(
                      state.events[index].timeOfCreation,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF616161),
                      ),
                    ),
                    if (state.events[index].isFavorite)
                      const Icon(Icons.bookmark_add, size: 12)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyWithEvents(EventPageState state, EventPageCubit cubit) {
    return Expanded(
      child: ListView.builder(
        itemCount: state.searchMode
            ? state.searchedEvents.length
            : state.events.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(state.events[index].toString()),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _cubit!.tapOnEvent(index, _searchController),
                onLongPress: () {
                  _cubit!.selectEvent(index);
                },
                child: _eventMessage(index, state),
              ),
            ),
            background: Container(
              color: Theme.of(context).primaryColor,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            secondaryBackground: Container(
              color: Theme.of(context).primaryColor,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _cubit!.setSelectedIndex(index, _controller);
                _cubit!.copyEventText(_controller);
                state.events.removeAt(index);
              } else if (direction == DismissDirection.endToStart) {
                {
                  state.events.removeAt(index);
                  _cubit!.removeEvent(index);
                }
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _migrateDialog(
    BuildContext context,
    EventPageState state,
    EventPageCubit cubit,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
              'Select the page you want to migrate the selected event(s) to'),
          children: [
            StatefulBuilder(
              builder: ((context, setState) {
                return Container(
                  height: 300,
                  width: 300,
                  child: ListView.builder(
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      return SimpleDialogOption(
                        child: Text(
                          state.chats[index].category,
                          style: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          _cubit!
                              .setMigrateCategory(state.chats[index].category);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cubit!.migrate();
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }

  void _dialog(
    EventPageState state,
    BuildContext context,
    EventPageCubit cubit,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Do you want to delete events?'),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              _cubit!.removeEvents();

              _cubit!.changeEditMode();
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          )
        ],
      ),
    );
  }

  Widget _eventMessage(int index, EventPageState state) {
    var image = state.events[index].image;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: state.events[index].isSelected
            ? Colors.green[300]
            : Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.events[index].description,
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).scaffoldBackgroundColor),
          ),
          Text(
            state.events[index].timeOfCreation,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF616161),
            ),
          ),
          if (state.events[index].isFavorite)
            const Icon(Icons.bookmark_add, size: 12),
          if (image != null)
            Image.file(
              File(image),
            ),
        ],
      ),
    );
  }
}
