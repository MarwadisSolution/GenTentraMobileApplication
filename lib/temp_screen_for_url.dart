import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/splash_screen.dart';

import 'Reusable Functions/reusable_functions.dart';
class TempScreenForUrl extends StatefulWidget {
  const TempScreenForUrl({super.key});

  @override
  State<TempScreenForUrl> createState() => _TempScreenForUrlState();
}

class _TempScreenForUrlState extends State<TempScreenForUrl> {
  final TextEditingController urlController = TextEditingController(text: api);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: "Server URL",
                // hintText: "https://example.trycloudflare.com",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorScheme.of(
                      context,
                    ).onSurface.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorScheme.of(
                      context,
                    ).onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){
              print(urlController.text);
              api = urlController.text.trim();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>SplashScreen()));
            },
                child: Text("Added"))
          ],
        ),
      ),
    );
  }
}
