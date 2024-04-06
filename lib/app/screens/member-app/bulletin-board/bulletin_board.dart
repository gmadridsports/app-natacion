import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/get_bulletin_notices/get_bulletin_notices.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../../../../Context/Natacion/application/get_bulletin_notices/get_bulletin_notices_response.dart';
import '../../../../shared/dependency_injection.dart';
import '../launchURL.dart';

class BulletinBoard extends StatefulWidget {
  const BulletinBoard({super.key});

  @override
  State<BulletinBoard> createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  MadridDateTime _newestNoticeDateTime;

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
            DependencyInjection().getInstanceOf<DateTimeRepository>();

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
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

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  _refreshList() {
    _newestNoticeDateTime = MadridDateTime.fromMicrosecondsSinceEpoch(
        _dateTimeRepository.now().microsecondsSinceEpoch);
    _pagingController.refresh();
  }

  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _refreshList(),
        ),
        child: PagedListView.separated(
          reverse: true,
          pagingController: _pagingController,
          padding: const EdgeInsets.all(32),
          separatorBuilder: (context, index) => const SizedBox(
            height: 16,
          ),
          builderDelegate: PagedChildBuilderDelegate<BulletinNotice>(
            itemBuilder: (context, notice, index) => Container(
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
