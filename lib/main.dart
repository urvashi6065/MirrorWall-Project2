import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:webview/model_Class.dart';
import 'package:webview/provider.dart';

import 'Connectionscareen.dart';

enum Status { google, yahoo, bing, duckduckgo }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => providerClass())],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: cheakConnection(),
      ),
    );
  }
}

class cheakConnection extends StatefulWidget {
  const cheakConnection({Key? key}) : super(key: key);

  @override
  State<cheakConnection> createState() => _cheakConnectionState();
}

class _cheakConnectionState extends State<cheakConnection> {
  @override
  void initState() {
    final provider = Provider.of<providerClass>(context, listen: false);
    provider.initConnectivity();
    provider.connectivitySubscription = provider
        .connectivity.onConnectivityChanged
        .listen(provider.updateConnectionStatus);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final providerVar = Provider.of<providerClass>(context, listen: true);
    return (providerVar.connectionStatus.name == 'none')
        ? connection()
        : MyHomePage(title: '');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    final provider = Provider.of<providerClass>(context, listen: false);
    provider.pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          provider.webController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          provider.webController?.loadUrl(
              urlRequest:
              URLRequest(url: await provider.webController?.getUrl()));
        }
      },
    );

    super.initState();
  }

  double webprogress = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<providerClass>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Browser'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: Colors.grey,
                      ),
                      Container(
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              openBottomsheet();
                            },
                            child: Text(
                              'All Bookmarks',
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.screen_search_desktop_outlined,
                        color: Colors.grey,
                      ),
                      TextButton(
                          onPressed: () {
                            ShowAlertBox();
                          },
                          child: Text(
                            'Search Engine',
                            style: TextStyle(color: Colors.black),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                onLoadStop: (context, url) {
                  provider.pullToRefreshController!.endRefreshing();
                },
                pullToRefreshController: provider.pullToRefreshController,
                key: provider.webkey,
                initialUrlRequest: URLRequest(
                  url: WebUri('https://www.google.com'),
                ),
                onWebViewCreated: (value) {
                  provider.webController = value;
                },
                onProgressChanged: (controller, int progress) =>
                    setState(() {
                      setState(() {
                        webprogress = progress / 100;
                      });
                    }),
              ),
            ),

            TextFormField(
              controller: provider.searchController,
              decoration: InputDecoration(
                hintText: "Search or type web address",
                suffixIcon: IconButton(
                    onPressed: () {
                      if (provider.s1 == Status.google) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri(
                                    'https://www.google.co.in/search?q=${provider
                                        .searchController.text}')));
                      } else if (provider.s1 == Status.yahoo) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri(
                                    'https://in.search.yahoo.com/search?q=${provider
                                        .searchController.text}')));
                      } else if (provider.s1 == Status.bing) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri(
                                    'https://www.bing.com/search?q=${provider
                                        .searchController.text}')));
                      } else {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri(
                                    'https://duckduckgo.com/${provider
                                        .searchController.text}')));
                      }
                    },
                    icon: Icon(Icons.search)),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            webprogress < 1
                ? LinearProgressIndicator(
              value: webprogress,
              color: Colors.red,
            )
                : SizedBox(),
            // LinearProgressIndicator(),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      if (provider.s1 == Status.google) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri('https://www.google.co.in/')));
                      } else if (provider.s1 == Status.yahoo) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri('https://in.search.yahoo.com/')));
                      } else if (provider.s1 == Status.bing) {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri('https://www.bing.com/')));
                      } else {
                        provider.webController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri('https://duckduckgo.com/')));
                      }
                    },
                    icon: Icon(Icons.home)),
                IconButton(
                    onPressed: () {
                      modelclass model = modelclass(
                        name: provider.searchController.text, url: (provider.s1 == Status.google) ?
                          'https://www.google.co.in/search?q=${provider
                              .searchController.text}': (provider
                          .s1 == Status.yahoo) ?
                          'https://in.search.yahoo.com/search${provider
                              .searchController.text}':(provider.s1==Status.bing)? 'https://www.bing.com/search?q=${provider
                          .searchController.text}':(provider.s1==Status.duckduckgo)?'https://duckduckgo.com/${provider
                          .searchController.text}':'dhfhdh',
                      );
                      provider.addListdata(model);
                    },
                    icon: Icon(Icons.bookmark_add_outlined)),
                IconButton(
                    onPressed: () {
                      provider.webController!.goForward();
                    },
                    icon: Icon(Icons.arrow_back_ios_outlined)),
                IconButton(
                    onPressed: () {
                      provider.webController!.reload();
                    },
                    icon: Icon(Icons.refresh)),
                IconButton(
                    onPressed: () {
                      provider.webController!.goBack();
                    },
                    icon: Icon(Icons.arrow_forward_ios_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  openBottomsheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Consumer<providerClass>(builder: (context, convar, child) {
              return Container(
                height: 600,
                width: double.infinity,
                child: (convar.bookMark.isEmpty)
                    ? Center(child: Text('No any bookmarks yet...'))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.deepPurple,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('DISMISS')),
                      ],
                    ),
                    Container(
                      height: 400,
                      child: ListView.builder(
                          itemCount: convar.bookMark.length,
                          itemBuilder: (context, int index) {
                            return ListTile(
                                onTap: () {
                                  convar.webController!.loadUrl(
                                      urlRequest: URLRequest(
                                          url: WebUri(
                                              convar.bookMark[index].url!)));
                                },
                                title: Text(convar.bookMark[index].name!),
                                subtitle:Text(convar.bookMark[index].url!),
                                trailing: IconButton(
                                onPressed: ()
                            {
                              convar.delateListdata(index);
                            },
                            icon: Icon(Icons.close)),
                            );
                          }),
                    ),
                  ],
                ),
              );
            });
          });
        });
  }

  ShowAlertBox() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Consumer<providerClass>(builder: (context, conVar, child) {
              return AlertDialog(
                title: Center(child: Text('Select Engine')),
                content: Container(
                  height: 250,
                  child: Column(
                    children: [
                      RadioListTile(
                        value: Status.google,
                        groupValue: conVar.s1,
                        onChanged: (value) {
                          conVar.setValue(value);
                          Navigator.of(context).pop();
                          conVar.webController!.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri(
                                      'https://www.google.co.in/search?q=${conVar
                                          .searchController.text}')));

                          Navigator.of(context).pop();
                        },
                        title: Text(
                          'Google',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile(
                        value: Status.yahoo,
                        groupValue: conVar.s1,
                        onChanged: (value) {
                          conVar.setValue(value);
                          Navigator.of(context).pop();
                          conVar.webController!.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri(
                                      'https://in.search.yahoo.com/search${conVar
                                          .searchController.text}')));
                        },
                        title: Text(
                          'Yahoo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile(
                        value: Status.bing,
                        groupValue: conVar.s1,
                        onChanged: (value) {
                          conVar.setValue(value);
                          Navigator.of(context).pop();
                          conVar.webController!.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri(
                                      'https://www.bing.com/search?q=${conVar
                                          .searchController.text}')));
                        },
                        title: Text(
                          'Bing',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      RadioListTile(
                        value: Status.duckduckgo,
                        groupValue: conVar.s1,
                        onChanged: (value) {
                          conVar.setValue(value);
                          Navigator.of(context).pop();
                          conVar.webController!.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri(
                                      'https://duckduckgo.com/${conVar
                                          .searchController.text}')));
                        },
                        title: Text(
                          'Duck Duck Go',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          });
        });
  }
}
