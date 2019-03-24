import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_app/blocs/providers.dart';
import 'package:video_app/blocs/video_list_bloc.dart';
import 'package:video_app/screen_values.dart';
import 'package:video_app/screens/camera_screen.dart';
import 'package:video_app/screens/video_player_screen.dart';
import 'package:video_app/util.dart';

class VideoListScreen extends StatefulWidget {
  static const String TAG = "VideoListScreen";

  @override
  State<StatefulWidget> createState() => _VideoListState();
}

class _VideoListState extends State<StatefulWidget> {

  @override
  Widget build(BuildContext context) {

    /// Get bloc to access video files stream
    VideoListBloc videoListBloc = Providers.getVideoListBloc(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ListScreenValues.fabCropTop),
              topRight: Radius.circular(ListScreenValues.fabCropTop),
              bottomLeft: Radius.circular(ListScreenValues.fabCropBottom),
              bottomRight: Radius.circular(ListScreenValues.fabCropBottom)
            )
        ),
        tooltip: ListScreenValues.fabHintString,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder:(context) => CameraScreen())),
        backgroundColor: Theme.of(context).accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        shape: AutomaticNotchedShape(
            BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(ListScreenValues.navBarCropX, ListScreenValues.navBarCropY),
                    topRight: Radius.elliptical(ListScreenValues.navBarCropX, ListScreenValues.navBarCropY)
                )
            )
        ),
        child: Padding(
          padding: EdgeInsets.only(
              top: ListScreenValues.navBarPaddingTop,
              bottom: ListScreenValues.navBarPaddingBottom
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: StreamBuilder<Object>(
                  stream: videoListBloc.saveMode,
                  initialData: false,
                  builder: (context, saveModeEnabled) {
                    if (!saveModeEnabled.hasData) {
                      return Container();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () => videoListBloc.setSaveMode(!saveModeEnabled.data),
                            child: Icon(saveModeEnabled.data ? Icons.arrow_back : Icons.save,
                                color: Theme.of(context).primaryColorLight)
                        ),
                        Text(
                            saveModeEnabled.data ?
                            ListScreenValues.backString : ListScreenValues.saveString,
                            style: TextStyle(
                                fontSize: ListScreenValues.navBarIconTextSize,
                                color: Theme.of(context).primaryColorLight
                            )
                        ),
                      ],
                    );
                  }
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: ListScreenValues.navBarRecordButtonTextPaddingTop
                ),
                child: Text(
                    ListScreenValues.recordVideoString,
                    style: TextStyle(
                        fontSize: ListScreenValues.navBarIconTextSize,
                        color: Theme.of(context).primaryColorLight
                    )
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    /// Delete movies and update list
                    Util.deleteMovies().then((_) => videoListBloc.initializeControllers());
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.delete, color: Theme.of(context).primaryColorLight),
                      Text(
                          ListScreenValues.deleteString,
                          style: TextStyle(
                              fontSize: ListScreenValues.navBarIconTextSize,
                              color: Theme.of(context).primaryColorLight
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<FileSystemEntity>>(
        stream: videoListBloc.videos,
        builder: (context, files) {
          if (!files.hasData) {
            return Container();
          }

          /// Convert to list, so that we can use it in ListView.builder()
          List<FileSystemEntity> filesList = List<FileSystemEntity>();
          files.data.forEach((file) {
            filesList.add(file);
          });

          return ListView.builder(
              itemCount: filesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: index == 0,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VideoPlayer(filesList[index]))),
                  contentPadding: EdgeInsets.all(ListScreenValues.listTilePadding),
                  leading: Text("${index + 1}.", style: TextStyle(fontSize: ListScreenValues.listTileNumberSize)),
                  title: StreamBuilder<bool>(
                    stream: videoListBloc.saveMode,
                    initialData: false,
                    builder: (context, saveModeEnabled) {
                      if (!saveModeEnabled.hasData) {
                        return Container();
                      }

                      if (!saveModeEnabled.data) {
                        return Container(
                            child: Text('${ListScreenValues.listTileTextBeginning}: '
                                '${filesList[index].path}',
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: ListScreenValues.listTileTextSize)
                            )
                        );
                      } else {
                        List<String> splitMoviePath = filesList[index].path.split("/");
                        return GestureDetector(
                          onTap: () {
                            Util.saveMovie(filesList[index]).then((path) {
                              final snackBar = SnackBar(
                                content: Text("Saved to $path"),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              videoListBloc.initializeControllers();
                            });
                          },
                          child: Container(
                              child: Text('${ListScreenValues.listTileTextBeginningSave}: '
                                  '${splitMoviePath[splitMoviePath.length - 1]}',
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: ListScreenValues.listTileTextSize)
                              )
                          ),
                        );
                      }
                    }
                  ),
                );
              }
          );
        }
      ),
    );
  }
}
