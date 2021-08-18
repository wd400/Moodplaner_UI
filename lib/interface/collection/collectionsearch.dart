
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/collection.dart';
import 'package:moodplaner/core/download.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/utils/widgets.dart';
import 'package:share/share.dart';


import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../login.dart';
import '../home.dart';
import 'collectiontrack.dart';
import 'edittrackmetrics.dart';


class CollectionSearch extends StatefulWidget {
  CollectionSearch({Key? key}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}


class CollectionSearchState extends State<CollectionSearch> {
  int elementsPerRow = 2;
  double? tileWidthAlbum;
  double? tileHeightAlbum;
  double? tileWidthArtist;
  double? tileHeightArtist;
  TextEditingController textFieldController = new TextEditingController();
  String query = '';
  bool get search =>  this._tracks.length == 0 && query == '';
  bool get result => this._tracks.length == 0 && query != '';
  bool get tracks => this._tracks.length == 0;
  List<Widget> _tracks =  <Widget>[];
  int globalIndex = 0;

  Widget newTrack(Track collectionItem,Collection collection) {
    {
      return (
        CollectionTrackTile(
          track: collectionItem,
          popupMenuButton: PopupMenuButton(
            elevation: 2,
            onSelected: (index) {
              switch (index) {
                case 0:
                  showDialog(
                    context: context,
                    builder: (subContext) =>
                        AlertDialog(
                          title: Text(
                            language!
                                .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                            style: Theme
                                .of(subContext)
                                .textTheme
                                .headline1,
                          ),
                          content: Text(
                            language!
                                .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                            style: Theme
                                .of(subContext)
                                .textTheme
                                .headline5,
                          ),
                          actions: [
                            MaterialButton(
                              textColor: Theme
                                  .of(context)
                                  .primaryColor,
                              onPressed: () async {
                                await collection.delete(collectionItem);
                                Navigator.of(subContext).pop();
                              },
                              child: Text(language!.STRING_YES),
                            ),
                            MaterialButton(
                              textColor: Theme
                                  .of(context)
                                  .primaryColor,
                              onPressed: Navigator
                                  .of(subContext)
                                  .pop,
                              child: Text(language!.STRING_NO),
                            ),
                          ],
                        ),
                  );
                  break;
                case 1:
                  Share.shareFiles(
                      [collectionItem.filePath!]
                  );
                  break;
                case 2:
                  showDialog(
                    context: context,
                    builder: (subContext) =>
                        AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          actionsPadding: EdgeInsets.zero,
                          title: Text(
                            language!
                                .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                            style: Theme
                                .of(subContext)
                                .textTheme
                                .headline1,
                          ),
                          content: Container(
                            height: 280,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        24, 8, 0, 16),
                                    child: Text(
                                      language!
                                          .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                      style: Theme
                                          .of(subContext)
                                          .textTheme
                                          .headline5,
                                    ),
                                  ),
                                  Container(
                                    height: 236,
                                    width: 280,
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          color: Theme
                                              .of(context)
                                              .dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ValueListenableBuilder(

                                        valueListenable: Hive.box<Playlist>('playlists').listenable(),


                                        builder: (BuildContext context, Box<dynamic> box, Widget? child) {
                                          var playlistsKeys = box
                                              .keys.toList();
                                          return ListView.builder(
                                            itemCount: playlistsKeys
                                                .length,
                                            itemBuilder: (
                                                BuildContext context,
                                                int playlistIndex) {
                                              return ListTile(
                                                title: Text(box
                                                    .get(
                                                    playlistsKeys[playlistIndex])
                                                    .playlistName!,
                                                  style:
                                                  Theme
                                                      .of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                leading: Icon(
                                                  Icons.queue_music,
                                                  size: Theme
                                                      .of(context)
                                                      .iconTheme
                                                      .size,
                                                  color: Theme
                                                      .of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                                onTap: () async {
                                                  await collection
                                                      .playlistAddTrack(
                                                    box.get(
                                                        playlistsKeys[playlistIndex])
                                                    ,
                                                    collectionItem,
                                                  );
                                                  Navigator.of(
                                                      subContext)
                                                      .pop();
                                                },
                                              );
                                            },
                                          );
                                        }
                                    ),
                                  ),
                                ]),
                          ),
                          actions: [
                            MaterialButton(
                              textColor: Theme
                                  .of(context)
                                  .primaryColor,
                              onPressed: Navigator
                                  .of(subContext)
                                  .pop,
                              child: Text(
                                  language!.STRING_CANCEL),
                            ),
                          ],
                        ),
                  );
                  break;
                case 3:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      //GeneratorDrawerWidget
                        builder: (
                            BuildContext context) {

                          // context.read(paintSettingsProvider).updatebargraph(value: false);
                          return   EditTrackMetrics(track:collectionItem);

                        }
                    ),
                  );
                  break;
                case 4:

                  //download

                print("iiiici");
                  download.addTask(new DownloadTask(fileUri:  Uri.parse('$SERVER_IP/songs/${collectionItem.hash}'),
                      saveLocation: File(Hive.box('configuration').get('collectionDirectory')+'/'+collectionItem.getName()),
                  extras:Track(trackName: collectionItem.trackName,albumArtistName: collectionItem.albumArtistName, todel: false)));
                  download.start();
                  break;
              }
            },
            icon: Icon(Icons.more_vert,
                color: Theme
                    .of(context)
                    .iconTheme
                    .color,
                size: Theme
                    .of(context)
                    .iconTheme
                    .size),
            tooltip: language!.STRING_OPTIONS,
            itemBuilder: (_) =>
            <PopupMenuEntry>[
              PopupMenuItem(
                value: 0,
                child: Text(language!.STRING_DELETE),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(language!.STRING_SHARE),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(language!.STRING_ADD_TO_PLAYLIST),
              ),
              PopupMenuItem(
                value: 3,
                child: Text(language!.STRING_EDIT_MEASURES),
              ),
              PopupMenuItem(
                value: 4,
                child: Text(language!.STRING_SAVE_TO_DOWNLOADS),
              ),
            ],
          ),
        )
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    this.elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    this.tileWidthAlbum = (MediaQuery.of(context).size.width - 16 - (this.elementsPerRow - 1) * 8) / this.elementsPerRow;
    this.tileHeightAlbum = this.tileWidthAlbum! * 242 / 156;
    this.tileWidthArtist = (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) / elementsPerRow;
    this.tileHeightArtist = this.tileWidthArtist! + 36.0;
    return Consumer(
        builder: (context, ScopedReader watch, _) {
          var collection = watch(collectionProvider);
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                autofocus: true,
                controller: this.textFieldController,
                cursorWidth: 1.0,
                onChanged: (String query) async {
                  int localIndex = globalIndex;
                  this.globalIndex++;
                  var connectivityResult = await (Connectivity().checkConnectivity());
                  List<dynamic> resultCollection;
                  if (connectivityResult != ConnectivityResult.none && await storage.read(key: "token")!='') {

                 resultCollection = await collection.searchServer(query);

                } else {
                    resultCollection = await collection.search(query);
          }
                  List<Widget> tracks = <Widget>[];
                  for (dynamic collectionItem in resultCollection) {
                    
                if (collectionItem is Track) {
                  
                tracks.add( newTrack(collectionItem, collection));
                }
                  }
                  if (localIndex == globalIndex - 1) {
                    this._tracks = tracks;
                    this.setState(() {});



                  }
                },
                decoration: InputDecoration.collapsed(
                    hintText: language!.STRING_SEARCH_COLLECTION),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme
                    .of(context)
                    .iconTheme
                    .color),
                iconSize: Theme
                    .of(context)
                    .iconTheme
                    .size!,
                splashRadius: Theme
                    .of(context)
                    .iconTheme
                    .size! - 8,
                onPressed: Navigator
                    .of(context)
                    .pop,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: Theme
                      .of(context)
                      .iconTheme
                      .color),
                  iconSize: Theme
                      .of(context)
                      .iconTheme
                      .size!,
                  splashRadius: Theme
                      .of(context)
                      .iconTheme
                      .size! - 8,
                  tooltip: language!.STRING_OPTIONS,
                  onPressed: this.textFieldController.text != ""
                      ? this.textFieldController.clear
                      : Navigator
                      .of(context)
                      .pop,
                ),
              ],
            ),
            body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                this.search ? Container(
                  margin: EdgeInsets.only(top: 56),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    children: [
                      Icon(Icons.search, size: 72, color: Theme
                          .of(context)
                          .iconTheme
                          .color),
                      Divider(
                        color: Colors.transparent,
                        height: 8,
                      ),
                      Text(
                        language!.STRING_LOCAL_SEARCH_WELCOME,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5,
                      )
                    ],
                  ),
                ) : Container(),
                this.result ? Container(
                  margin: EdgeInsets.only(top: 56),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    children: [
                      Icon(Icons.close, size: 72, color: Theme
                          .of(context)
                          .iconTheme
                          .color),
                      Divider(
                        color: Colors.transparent,
                        height: 8,
                      ),
                      Text(
                        language!.STRING_LOCAL_SEARCH_NO_RESULTS,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5,
                      )
                    ],
                  ),
                ) : Container(),
                this.tracks ? Container() : SubHeader(language!.STRING_TRACK),
              ] + (this.tracks ? [Container()]: this._tracks),
            ),
          );
        }
    );
  }
}
