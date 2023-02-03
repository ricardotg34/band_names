import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'System of a Down', votes: 2),
    // Band(id: '3', name: 'Paramore', votes: 3),
    // Band(id: '4', name: 'Arch Enemy', votes: 1),
  ];

  @override
  void initState() {
    final SocketService socketService = context.read<SocketService>();
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final SocketService socketService = context.read<SocketService>();
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = context.watch<SocketService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Center(
          child: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => BandTile(
            band: bands[i],
            onDismissed: (_) => socketService.emit('delete-band', bands[i].id)),
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New Band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
                child: Text('Add'),
                elevation: 5,
                onPressed: () {
                  addBandToList(textController.text);
                })
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New Band Name:'),
        content: CupertinoTextField(
          controller: textController,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () {
                addBandToList(textController.text);
              }),
          CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final SocketService socketService = context.read<SocketService>();
      socketService.emit('add-band', name);
    }
    Navigator.pop(context);
  }
}

class BandTile extends StatelessWidget {
  const BandTile({@required this.band, @required this.onDismissed});

  final Band band;
  final void Function(DismissDirection) onDismissed;

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = context.watch<SocketService>();
    return Dismissible(
      onDismissed: onDismissed,
      background: _dismissibleBackground(),
      direction: DismissDirection.startToEnd,
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            band.name.substring(0, 2),
            style: Theme.of(context).primaryTextTheme.button,
          ),
          backgroundColor: Theme.of(context).accentColor,
        ),
        title: Text(band.name),
        trailing:
            Text('${band.votes}', style: Theme.of(context).textTheme.subtitle2),
        onTap: () => socketService.emit('vote-band', band.id),
      ),
    );
  }

  Container _dismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 8.0),
      color: Colors.red,
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete band',
            style: TextStyle(color: Colors.white),
          )),
    );
  }
}
