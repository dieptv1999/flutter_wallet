import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wallet/model/transaction.dart';
import 'package:flutter_wallet/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DbService db = DbService();

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Transaction History",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: buildListView(),
    );
  }

  FutureBuilder<List<TransactionCustom>> buildListView() {
    String prevDay = '';
    String today = DateFormat("EEE, MMM d, y").format(DateTime.now());
    String yesterday = DateFormat("EEE, MMM d, y")
        .format(DateTime.now().add(const Duration(days: -1)));

    return FutureBuilder<List<TransactionCustom>>(
        future: db.transactions(),
        builder: (BuildContext context,
            AsyncSnapshot<List<TransactionCustom>> snapshot) {
          if (snapshot.hasData) {
            List<TransactionCustom> transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                TransactionCustom transaction = transactions[index];
                DateTime date = DateTime.fromMillisecondsSinceEpoch(
                    transaction.createdMillis);
                String dateString = DateFormat("EEE, MMM d, y").format(date);

                if (today == dateString) {
                  dateString = "Today";
                } else if (yesterday == dateString) {
                  dateString = "Yesteday";
                }

                bool showHeader = prevDay != dateString;
                prevDay = dateString;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    showHeader
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Text(
                        dateString,
                        style:
                        Theme
                            .of(context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : const Offstage(),
                    buildItem(index, context, date, transaction),
                  ],
                );
              },
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildItem(int index, BuildContext context, DateTime date,
      TransactionCustom transaction) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(width: 20),
          buildLine(index, context),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            // color: Theme.of(context).accentColor,
            child: Text(
              DateFormat("hh:mm a").format(date),
              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    // color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: buildItemInfo(transaction, context),
          ),
        ],
      ),
    );
  }

  Card buildItemInfo(TransactionCustom transaction, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: transaction.point.isNegative
                  ? [Colors.deepOrange, Colors.red]
                  : [Colors.green, Colors.teal]),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  transaction.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                NumberFormat("###,###,#### P").format(transaction.point),
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildLine(int index, BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).accentColor,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor, shape: BoxShape.circle),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: 2,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
