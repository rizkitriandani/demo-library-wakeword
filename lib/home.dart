import 'package:flutter/material.dart';
import 'package:vosk_flutter_plugin/keyword_recognition.dart';

import 'logger.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isModelLoading = false;
  bool isModelLoaded = false;
  bool isRecognizing = false;
  bool isEngineReady = false;

  KeywordRecognition kw = KeywordRecognition(
    keyword: "hello there",
    assetPath: 'assets/models/vosk-model-small-en-us-0.15.zip',
  );

  @override
  void initState() {
    kw.init();
    setState(() {
      isModelLoading = false;
      isModelLoaded = true;
      isEngineReady = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LW Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: [
              if (!isModelLoaded && !isModelLoading)
                RaisedButton(
                    onPressed: () async {
                      setState(() {
                        isModelLoading = true;
                      });
                      await kw.loadModel();
                      setState(() {
                        isModelLoading = false;
                        isModelLoaded = true;
                        isEngineReady = true;
                      });
                    },
                    child: const Text('Load and init model')),
              if (isModelLoading) const CircularProgressIndicator(),
              if (isModelLoaded) const Text('Model loaded'),
              RaisedButton(
                  onPressed: !isRecognizing && isEngineReady && isModelLoaded
                      ? () {
                          kw.startRecognizing();
                          setState(() {
                            isRecognizing = true;
                          });
                        }
                      : null,
                  child: const Text('Recognize microphone')),
              RaisedButton(
                  onPressed: isRecognizing
                      ? () {
                          kw.stopRecognizing();
                          setState(() {
                            isRecognizing = false;
                          });
                        }
                      : null,
                  child: const Text('Stop recognition')),
              const SizedBox(height: 20),
              const Text('On Partial'),
              StreamBuilder(
                stream: kw.onPartialController.stream,
                builder: (context, snapshot) => Text(snapshot.data.toString()),
              ),
              const SizedBox(height: 20),
              const Text('On Result'),
              StreamBuilder(
                stream: kw.onResultController.stream,
                builder: (context, snapshot) {
                  if (kw.isKeywordDetected) {
                    Future.delayed(Duration.zero).then((value) => setState(() {
                          isRecognizing = false;
                        }));
                  }
                  return Text(snapshot.data.toString());
                },
              ),
              // const SizedBox(height: 20),
              // const Text('On final result'),
              // StreamBuilder(
              //   stream: kw.onFinalResultController.stream,
              //   builder: (context, snapshot) => Text(snapshot.data.toString()),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
