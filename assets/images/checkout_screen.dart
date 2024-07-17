import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.home),
                    title:
                    const Text('House # 324, Block-P\nJohar Town, Lahore'),
                    trailing:
                    ElevatedButton(onPressed: () {}, child:
                    const Text('Change', style:
                    TextStyle(color:
                    Colors.white))),
                  ),
                ),
                const SizedBox(height : 20),
                const Text('Payment Summary', style : TextStyle(fontSize : 18, fontWeight : FontWeight.bold)),
                const Card (
                    child : Padding (
                        padding : EdgeInsets.all(8.0),
                        child : Column (
                            children:[
                              Row (
                                  mainAxisAlignment :
                                  MainAxisAlignment.spaceBetween,
                                  children:[
                                    Text ('Order Total'),
                                    Text ('2000 Rs')
                                  ]
                              ),
                              Row (
                                  mainAxisAlignment :
                                  MainAxisAlignment.spaceBetween,
                                  children:[
                                    Text ('Shipping'),
                                    Text ('Free')
                                  ]
                              ),
                              Divider(),
                              Row (
                                  mainAxisAlignment :
                                  MainAxisAlignment.spaceBetween,
                                  children:[
                                    Text ('Total', style :
                                    TextStyle(fontWeight :
                                    FontWeight.bold)),
                                    Text ('2000 Rs', style :
                                    TextStyle(fontWeight :
                                    FontWeight.bold))
                                  ]
                              )
                            ]
                        )
                    )
                ),
                const Spacer(),
                Center(child:ElevatedButton(onPressed : (){},child:
                const Padding(padding:
                EdgeInsets.symmetric(horizontal :50, vertical :10),child:
                Text('Place Order',
                    style:
                    TextStyle(fontSize
                        :20)))))]
          )),
    );
  }
}