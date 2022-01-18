import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_wallet/services/web3_service.dart';
import 'package:flutter_wallet/ui/screen/QRScanner.dart';
import 'package:flutter_wallet/ui/screen/WalletConnectQr.dart';
import 'package:flutter_wallet/util/file_path.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Web3Service web3Service = Web3Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 34),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _contentHeader(),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Account Overview',
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(
                height: 16,
              ),
              _contentOverView(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Send Money',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRScanner()));
                    },
                    child: SvgPicture.asset(
                      scan,
                      color: Theme.of(context).iconTheme.color,
                      width: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _contentSendMoney(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SvgPicture.asset(
                    filter,
                    color: Theme.of(context).iconTheme.color,
                    width: 18,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              _contentServices(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            SvgPicture.asset(
              logo,
              width: 34,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              'eWallet',
              style: Theme.of(context).textTheme.headline4,
            )
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WalletConnectQr()));
              },
              child: SvgPicture.asset(
                scan,
                width: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  // print('call');
                  // xOffset = 240;
                  // yOffset = 180;
                  // scaleFactor = 0.7;
                  // isDrawerOpen = true;
                });
              },
              child: SvgPicture.asset(
                menu,
                width: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contentOverView() {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 22, bottom: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        // color: const Color(0xffF1F3F6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<double>(
                stream: Stream.periodic(const Duration(seconds: 15))
                    .asyncMap((i) => web3Service.getBalance()),
                builder:
                    (BuildContext context, AsyncSnapshot<double> snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data.toString());
                    return Text(
                      snapshot.data.toString(),
                      style: Theme.of(context).textTheme.headline5,
                    );
                  } else {
                    return const CircularProgressIndicator(
                      value: 8,
                    );
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Current Balance',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
              )
            ],
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: FutureBuilder<String>(
                              future: web3Service.getAddress(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return QrImage(
                                    data: snapshot.data ?? '',
                                    version: QrVersions.auto,
                                    size: 180.0,
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                        ),
                      ),
                    );
                  });
            },
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: const Color(0xffFFAC30),
                borderRadius: BorderRadius.circular(80),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSendMoney() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 80,
            padding: const EdgeInsets.only(
              left: 18,
              right: 18,
              top: 28,
              bottom: 28,
            ),
            child: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Color(0xffFFAC30),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xffD8D9E4))),
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ClipRRect(
                      child: SvgPicture.asset(avatorOne),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Text(
                  'Mike',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffD8D9E4))),
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ClipRRect(
                      child: SvgPicture.asset(avatorTwo),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Text(
                  'Joseph',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffD8D9E4))),
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: ClipRRect(
                      child: SvgPicture.asset(avatorThree),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Text(
                  'Ashley',
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contentServices(BuildContext context) {
    List<ModelServices> listServices = [];

    listServices.add(ModelServices(title: "Send\nMoney", img: send));
    listServices.add(ModelServices(title: "Receive\nMoney", img: recive));
    listServices.add(ModelServices(title: "Mobile\nPrepaid", img: mobile));
    listServices
        .add(ModelServices(title: "Electricity\nBill", img: electricity));
    listServices.add(ModelServices(title: "Cashback\nOffer", img: cashback));
    listServices.add(ModelServices(title: "Movie\nTickets", img: movie));
    listServices.add(ModelServices(title: "Flight\nTickets", img: flight));
    listServices.add(ModelServices(title: "More\nOptions", img: menu));

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.1),
        children: listServices.map((value) {
          return GestureDetector(
            onTap: () {
              // print('${value.title}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),
                  child: SvgPicture.asset(
                    value.img,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  value.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ModelServices {
  String title, img;

  ModelServices({required this.title, required this.img});
}
