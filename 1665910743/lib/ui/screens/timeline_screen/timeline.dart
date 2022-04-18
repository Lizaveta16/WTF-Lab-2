import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/event_tile.dart';
import '../../widgets/event_tile_actions.dart';
import '../chat_screen/cubit/event_cubit.dart';
import '../home/cubit/home_cubit.dart';
import '../settings/cubit/settings_cubit.dart';

class Timeline extends StatelessWidget {
  static const title = 'Timeline';

  const Timeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;

    return Container(
      child: state.searchMode ? const SearchResultList() : const BodyList(),
    );
  }
}

class BodyList extends StatelessWidget {
  const BodyList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _eventCubit = context.read<EventCubit>();
    final _showBookmarked = context.watch<HomeCubit>().state.showBookmarked;
    return BlocBuilder<EventCubit, EventState>(
      bloc: _eventCubit,
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.eventList.length,
          itemBuilder: ((context, index) {
            if (_showBookmarked) {
              if (state.eventList[index].favorite) {
                if (state.eventList[index].image.length > 2) {
                  context
                      .read<EventCubit>()
                      .getImage(state.eventList[index].title);
                }

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
                    child: EventTile(
                        iconCode: state.eventList[index].iconCode,
                        isSelected: state.eventList[index].isSelected,
                        title: state.eventList[index].title,
                        date: state.eventList[index].date,
                        favorite: state.eventList[index].favorite,
                        tag: state.eventList[index].tag,
                        image: (state.eventList[index].imageUrl != null)
                            ? Image.network(
                                state.eventList[index].imageUrl!,
                                width: 70,
                                height: 70,
                              )
                            : null),
                  ),
                );
              } else {
                return const SizedBox();
              }
            } else {
              if (state.eventList[index].image.length > 2) {
                context
                    .read<EventCubit>()
                    .getImage(state.eventList[index].title);
              }

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
                  child: EventTile(
                      iconCode: state.eventList[index].iconCode,
                      isSelected: state.eventList[index].isSelected,
                      title: state.eventList[index].title,
                      date: state.eventList[index].date,
                      favorite: state.eventList[index].favorite,
                      tag: state.eventList[index].tag,
                      image: (state.eventList[index].imageUrl != null)
                          ? Image.network(
                              state.eventList[index].imageUrl!,
                              width: 70,
                              height: 70,
                            )
                          : null),
                ),
              );
            }
          }),
        );
      },
    );
  }
}

class SearchResultList extends StatelessWidget {
  const SearchResultList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _eventCubit = context.read<EventCubit>();
    final _searchResult = context.watch<HomeCubit>().state.searchResult;

    return BlocBuilder<EventCubit, EventState>(
      bloc: _eventCubit,
      builder: (context, state) {
        return _searchResult.isEmpty
            ? Center(child: Lottie.asset('assets/search.json'))
            : ListView.builder(
                itemCount: state.eventList.length,
                itemBuilder: ((context, index) {
                  if (_searchResult.isNotEmpty &&
                      state.eventList[index].title.contains(
                        _searchResult,
                      )) {
                    if (state.eventList[index].image.length > 2) {
                      context
                          .read<EventCubit>()
                          .getImage(state.eventList[index].title);
                    }

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
                        child: EventTile(
                            iconCode: state.eventList[index].iconCode,
                            isSelected: state.eventList[index].isSelected,
                            title: state.eventList[index].title,
                            date: state.eventList[index].date,
                            favorite: state.eventList[index].favorite,
                            tag: state.eventList[index].tag,
                            image: (state.eventList[index].imageUrl != null)
                                ? Image.network(
                                    state.eventList[index].imageUrl!,
                                    width: 70,
                                    height: 70,
                                  )
                                : null),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
              );
      },
    );
  }
}
