import 'package:cached_network_image/cached_network_image.dart';
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
    return BlocBuilder<HomeCubit, HomeState>(
        bloc: context.watch<HomeCubit>(),
        builder: ((context, state) =>
            state.searchMode ? const SearchResultList() : const BodyList()));
  }
}

class BodyList extends StatelessWidget {
  const BodyList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      bloc: context.read<EventCubit>(),
      builder: (context, state) {
        return BlocBuilder<HomeCubit, HomeState>(
          bloc: context.watch<HomeCubit>(),
          builder: ((context, homeState) => ListView.builder(
                itemCount: state.eventList.length,
                itemBuilder: ((context, index) {
                  if (homeState.showBookmarked) {
                    if (state.eventList[index].favorite) {
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            EditAction(
                              event: state.eventList[index],
                              eventKey: state.eventList[index].id!,
                            ),
                            RemoveAction(eventKey: state.eventList[index].id!),
                            MoveAction(
                              eventKey: state.eventList[index].id!,
                              categoryName:
                                  state.eventList[index].categoryTitle,
                            ),
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
                                  ? Image(
                                      image: CachedNetworkImageProvider(
                                          state.eventList[index].imageUrl!),
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                    )
                                  : null),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    return Slidable(
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          EditAction(
                            event: state.eventList[index],
                            eventKey: state.eventList[index].id!,
                          ),
                          RemoveAction(eventKey: state.eventList[index].id!),
                          MoveAction(
                            eventKey: state.eventList[index].id!,
                            categoryName: state.eventList[index].categoryTitle,
                          ),
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
                                ? Image(
                                    image: CachedNetworkImageProvider(
                                        state.eventList[index].imageUrl!),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                  )
                                : null),
                      ),
                    );
                  }
                }),
              )),
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
            ? Center(
                child: Lottie.asset('assets/search.json', repeat: false),
              )
            : ListView.builder(
                itemCount: state.eventList.length,
                itemBuilder: ((context, index) {
                  if (_searchResult.isNotEmpty &&
                      state.eventList[index].title.contains(
                        _searchResult,
                      )) {
                    return Slidable(
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          EditAction(
                            event: state.eventList[index],
                            eventKey: state.eventList[index].id!,
                          ),
                          RemoveAction(eventKey: state.eventList[index].id!),
                          MoveAction(
                            eventKey: state.eventList[index].id!,
                            categoryName: state.eventList[index].categoryTitle,
                          ),
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
                                ? Image(
                                    image: CachedNetworkImageProvider(
                                        state.eventList[index].imageUrl!),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
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
