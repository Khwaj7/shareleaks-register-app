import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shareleaks',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        fontFamily: 'Georgia',
        textTheme: TextTheme(
          headline1:
              const TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline3: TextStyle(
            fontStyle: Theme.of(context).textTheme.headline3?.fontStyle,
            fontFamily: Theme.of(context).textTheme.headline3?.fontFamily,
            fontSize: Theme.of(context).textTheme.headline3?.fontSize,
            color: Colors.white,
          ),
          headline6: TextStyle(
            fontStyle: Theme.of(context).textTheme.headline6?.fontStyle,
            fontFamily: Theme.of(context).textTheme.headline6?.fontFamily,
            fontSize: Theme.of(context).textTheme.headline6?.fontSize,
            color: Colors.white,
          ),
          bodyText2: const TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: const MyHomePage(title: 'Shareleaks alpha program'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _submitKey = GlobalKey<FormState>();
  final mail = TextEditingController();
  final name = TextEditingController();
  bool isRegisterPressed = false;
  bool isRegisterOK = false;

  // database
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref('/');
  int currentElementNb = 0;

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red[700]);
  final List<Color> colors = [
    Colors.blueAccent.withOpacity(0.01),
    Colors.blueAccent.withOpacity(0.01),
    Colors.blueAccent.withOpacity(0.01),
    Colors.blueAccent.withOpacity(0.01),
    Colors.white.withOpacity(0.3),
  ];

  void registerMail(String name, String mail) async {
    currentElementNb++;
    ref = FirebaseDatabase.instance.ref('/' + currentElementNb.toString());
    // when async finishes => set isRegisterOk true + reroll build()
    await ref.set({"name": name, "mail": mail}).then((value) => setState(() {
          isRegisterOK = true;
        }));
  }

  void readData() async {
    final snapshot = await ref.child('/').get();
    if (snapshot.exists) {
      currentElementNb = snapshot.children.length;
    } else {
      debugPrint('No data available.');
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    readData();
    return Scaffold(
      body: Container(
        height: (MediaQuery.of(context).size.height),
        width: (MediaQuery.of(context).size.width),
        decoration: const BoxDecoration(
          image:
              DecorationImage(image: AssetImage("roads.jpg"), fit: BoxFit.fill),
        ),
        child: Center(
          child: Stack(
            children: <Widget>[
              /* DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter)
                    ),
                child:*/
              !isRegisterOK
                  ? Form(
                      key: _formKey,
                      child: Column(children: [
                        Text(
                          'Welcome to Shareleaks',
                          style: Theme.of(context).textTheme.headline3,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Want to be informed of our release? \nSubscribe below!',
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                              constraints: BoxConstraints(maxWidth: 250),
                              hintText: 'Your name',
                              labelText: 'Name'),
                          onSaved: (String? newValue) =>
                              {debugPrint('value : $newValue')},
                          validator: (String? value) {
                            return (value == null) ? 'Invalid name' : null;
                          },
                        ),
                        TextFormField(
                          controller: mail,
                          decoration: const InputDecoration(
                              constraints: BoxConstraints(maxWidth: 250),
                              hintText: 'Your email address',
                              labelText: 'Email address'),
                          onSaved: (String? newValue) =>
                              {debugPrint('value : $newValue')},
                          onChanged: (String? value) =>
                              {_formKey.currentState!.validate()},
                          validator: (String? value) {
                            return (value != null &&
                                    (!value.contains('@') ||
                                        !value.contains('.')))
                                ? 'Invalid email'
                                : null;
                          },
                        ),
                        const SizedBox(height: 10),
                        !isRegisterPressed
                            ? ElevatedButton(
                                key: _submitKey,
                                style: style,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //       content: Text('Processing Data')),
                                    // );
                                    registerMail(name.text, mail.text);
                                    setState(() {
                                      isRegisterPressed = true;
                                    });
                                  } else {
                                    debugPrint('Error validators!');
                                  }
                                },
                                child: const Text('Register'),
                              )
                            : const SpinKitWave(
                                color: Colors.white,
                                size: 30.0,
                              ),
                      ]),
                    )
                  : Column(
                      children: <Widget>[
                        Text(
                          'Welcome to Shareleaks',
                          style: Theme.of(context).textTheme.headline3,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'You are successfully registered!',
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
