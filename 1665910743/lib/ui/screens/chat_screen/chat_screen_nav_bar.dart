import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants.dart';
import '../../../models/event.dart';
import '../chat_screen/bookmarks.dart';
import '../chat_screen/cubit/event_cubit.dart';

class ChatScreenNavBar extends StatefulWidget {
  final EventCubit eventCubit;
  final TextEditingController controller;
  final String categoryTitle;

  const ChatScreenNavBar({
    Key? key,
    required this.controller,
    required this.categoryTitle,
    required this.eventCubit,
  }) : super(key: key);

  @override
  State<ChatScreenNavBar> createState() => _ChatScreenNavBarState();
}

class _ChatScreenNavBarState extends State<ChatScreenNavBar>
    with SingleTickerProviderStateMixin {
  final picker = ImagePicker();
//TODO: animation to bloc
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -2.0),
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc,
    ),
  );
  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1,
    end: 3,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc,
    ),
  );

  Future getImage() async {
    final _pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (_pickedFile != null) {
      final File? _newImage = await File(_pickedFile.path);

      widget.eventCubit.imageSelect(_newImage!.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected'),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = context.watch<EventCubit>().state.animate;
    if (animate) {
      _controller.forward().then((_) => _controller.reverse());
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      bloc: widget.eventCubit,
      builder: ((context, state) => SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                state.selectedImage != null
                    ? _imagePreview(context, state.selectedImage!)
                    : const SizedBox(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (state.hasSelected.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookmarkEvents(
                                eventCubit: widget.eventCubit,
                              ),
                            ),
                          );
                        } else {
                          widget.eventCubit.removeMultipleEvents();
                        }
                      },
                      icon: SlideTransition(
                        position: _offsetAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Icon(
                            state.hasSelected.isNotEmpty
                                ? Icons.delete
                                : Icons.bookmark,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.eventCubit.iconAdd(true);
                      },
                      icon: Icon(
                        (state.selectedIcon == -1)
                            ? Icons.bubble_chart
                            : iconPack[state.selectedIcon].icon,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                          hintText: ' Enter event',
                          hintStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          border: InputBorder.none,
                        ),
                        controller: widget.controller,
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          if (widget.controller.value.text.isNotEmpty) {
                            if (state.selectedIcon == -1) {
                              widget.eventCubit.addEvent(
                                event: Event(
                                  image: state.selectedImage != null
                                      ? state.selectedImage!
                                      : '',
                                  iconCode: 0,
                                  title: widget.controller.text,
                                  date: DateTime.now(),
                                  favorite: false,
                                  categoryTitle: widget.categoryTitle,
                                  tag: state.selectedTag,
                                ),
                              );
                            } else {
                              widget.eventCubit.addEvent(
                                event: Event(
                                  image: state.selectedImage != null
                                      ? state.selectedImage!
                                      : '',
                                  title: widget.controller.text,
                                  date: DateTime.now(),
                                  favorite: false,
                                  iconCode: iconPack[state.selectedIcon]
                                      .icon!
                                      .codePoint,
                                  categoryTitle: widget.categoryTitle,
                                  tag: state.selectedTag,
                                ),
                              );
                            }
                            widget.eventCubit.iconSelect(-1);
                            widget.controller.clear();
                            widget.eventCubit.imageSelect(null);
                          } else if (widget.controller.value.text.isEmpty) {
                            await getImage();
                          }
                        },
                        icon: Icon(
                          widget.controller.value.text.isEmpty
                              ? Icons.photo_camera
                              : Icons.send,
                          color: Theme.of(context).primaryColor,
                        ))
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget _imagePreview(BuildContext context, String imagePath) {
    return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 27,
          child: ClipOval(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: 50,
              height: 50,
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
