import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/RedirectToScreen/redirect_to_screen_for_request.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/get_bulletin_notices/get_bulletin_notices.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/listen_new_remote_published_notices/stop_listening_new_remote_notices.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/notice_body/notice_body.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/screen/NotChangedCurrentScreenDomainEvent.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';
import 'package:gmadrid_natacion/app/screens/NamedRouteScreen.dart';
import 'package:gmadrid_natacion/app/screens/member-app/member_app.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../../../../Context/Natacion/application/get_bulletin_notices/get_bulletin_notices_response.dart';
import '../../../../Context/Natacion/application/listen_new_remote_published_notices/listen_new_remote_notices.dart';
import '../../../../Context/Natacion/domain/bulletin/notice_published_event.dart';
import '../../../../Context/Natacion/domain/navigation_request/navigation_request.dart';
import '../../../../Context/Natacion/domain/screen/screen.dart';
import '../../../../shared/dependency_injection.dart';
import '../../../app_event_listener/app_event_listener.dart';
import '../launchURL.dart';

class BulletinBoard extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => "${MemberApp.routeName}/bulletin-board";

  const BulletinBoard({super.key});

  @override
  State<BulletinBoard> createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  MadridDateTime _newestNoticeDateTime;
  late AppEventListener? _appEventListenerNoticePublished;
  late AppEventListener? _appEventListenerReopenedAppWithValidSession;

  final _pagingController = PagingController<
      (MadridDateTime startingByDateIncluded, String? startingByIdIncluded),
      BulletinNotice>(
    firstPageKey: (
      MadridDateTime.fromMicrosecondsSinceEpoch(DependencyInjection()
          .getInstanceOf<DateTimeRepository>()
          .now()
          .microsecondsSinceEpoch),
      null
    ),
  );
  final DateTimeRepository _dateTimeRepository;

  _BulletinBoardState()
      : _newestNoticeDateTime = MadridDateTime.fromMicrosecondsSinceEpoch(
            DependencyInjection()
                .getInstanceOf<DateTimeRepository>()
                .now()
                .microsecondsSinceEpoch),
        _dateTimeRepository =
            DependencyInjection().getInstanceOf<DateTimeRepository>() {
    _appEventListenerReopenedAppWithValidSession = AppEventListener();
    _appEventListenerNoticePublished = AppEventListener();
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _appEventListenerNoticePublished?.onAppBCEvent<NoticePublishedEvent>(
        NoticePublishedEvent.EVENT_NAME, (event) {
      BulletinNotice newNotice = BulletinNotice(
          event.body, event.publicationDate, event.aggregateId, event.origin);
      _pagingController.itemList = [
        newNotice,
        ..._pagingController.itemList ?? [],
      ];
    }, triggerBCListener: () {
      ListenNewRemoteNotices()();
    }, stopBCListener: () {
      StopListeningNewRemoteNotices()();
    });

    _appEventListenerReopenedAppWithValidSession
        ?.onAppBCEvent<NotChangedCurrentScreenDomainEvent>(
            NotChangedCurrentScreenDomainEvent.EVENT_NAME, (event) {
      _refreshList();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _appEventListenerReopenedAppWithValidSession = null;
    _appEventListenerNoticePublished = null;
    super.dispose();
  }

  Future<void> _fetchPage(
      (
        MadridDateTime olderThanDateExcluded,
        String? beforeIdExcluded
      ) pageKey) async {
    try {
      final GetBulletinNoticesResponse(:notices, :hasMore) =
          await GetBulletinNotices()((pageKey.$1, pageKey.$2));

      if (!hasMore) {
        _pagingController.appendLastPage(notices);
      } else {
        _pagingController.appendPage(notices, (
          MadridDateTime.fromMicrosecondsSinceEpoch(
              notices.last.publicationDate.microsecondsSinceEpoch),
          notices.last.id
        ));
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  _refreshList() {
    _newestNoticeDateTime = MadridDateTime.fromMicrosecondsSinceEpoch(
        _dateTimeRepository.now().microsecondsSinceEpoch);
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: PagedListView.separated(
          reverse: true,
          pagingController: _pagingController,
          padding: const EdgeInsets.all(32),
          separatorBuilder: (context, index) => const SizedBox(
            height: 16,
          ),
          builderDelegate: PagedChildBuilderDelegate<BulletinNotice>(
            itemBuilder: (context, notice, index) => SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromARGB(100, 158, 201, 222),
                      ),
                      child: MarkdownBody(
                        styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 20),
                            h1: const TextStyle(fontSize: 24),
                            h2: const TextStyle(fontSize: 22),
                            h3: const TextStyle(fontSize: 20),
                            h4: const TextStyle(fontSize: 18),
                            h5: const TextStyle(fontSize: 16),
                            h6: const TextStyle(fontSize: 14)),
                        softLineBreak: true,
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                        onTapLink: (text, href, title) {
                          final hrefToOpen = href.toString();
                          if (hrefToOpen.endsWith(
                              NoticeBody.SUFFIX_FLAG_OPEN_INTERNAL_URL)) {
                            RedirectToScreenForRequest()(
                                NavigationRequest.fromScreen(
                                    Screen.mainScreen(
                                        MainScreen.webpageContent),
                                    type: RequestType.overlayedScreen,
                                    params: {
                                  'url': hrefToOpen.replaceAllMapped(
                                      NoticeBody.SUFFIX_FLAG_OPEN_INTERNAL_URL,
                                      (match) => '')
                                }));
                            return;
                          }
                          launchURL(href.toString(), context);
                        },
                        data: notice.body,
                        selectable: true,
                      ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(notice.origin),
                          const Text(' '),
                          Text(
                              DateFormat(_newestNoticeDateTime.sameDayAs(
                                          MadridDateTime
                                              .fromMicrosecondsSinceEpoch(notice
                                                  .publicationDate
                                                  .microsecondsSinceEpoch))
                                      ? 'HH:mm'
                                      : 'dd/MM/yyyy HH:mm')
                                  .format(notice.publicationDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16)),
                        ]),
                  ],
                )),
            firstPageErrorIndicatorBuilder: (_) => Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.error_outline_rounded,
                      size: 40, color: Colors.orange),
                ),
                const Text("Uy, ha ocurrido un error al cargar los avisos",
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center),
                TextButton(
                    onPressed: () {
                      _refreshList();
                    },
                    child: const Text("Reintentar",
                        style: TextStyle(fontSize: 16)))
              ],
            )),
            newPageErrorIndicatorBuilder: (_) => Column(
              children: [
                const Text('Ups, no consigo cargar más avisos',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center),
                TextButton(
                    onPressed: () {
                      _refreshList();
                    },
                    child: const Text("Reintentar",
                        style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ),
      );
}
