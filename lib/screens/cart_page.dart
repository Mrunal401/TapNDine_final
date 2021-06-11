import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_cust/constants.dart';
import 'package:my_cust/screens/home_page.dart';
import 'package:my_cust/screens/product_page.dart';
import 'package:my_cust/screens/update_page.dart';
import 'package:my_cust/services/firebase_services.dart';
import 'package:my_cust/widgets/custom_action_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_cust/widgets/custom_btn.dart';
import 'package:my_cust/widgets/custom_input.dart';
import 'package:my_cust/widgets/product_size.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();

}

class _CartPageState extends State<CartPage> {

  FirebaseServices _firebaseServices = FirebaseServices();
  Razorpay razorpay;


  TextEditingController textEditingController = new TextEditingController();
  TextEditingController tabletextEditingController = new TextEditingController();


  @override
  void initState() {
    super.initState();

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }


  void openCheckout() {
    var options = {
      'key': 'rzp_test_4sD5QQ7bXUF7Mn',
      //'key': 'rzp_test_6JPsz7KYt08oqX',
      'amount': num.parse(textEditingController.text)*100,
      'name': num.parse(tabletextEditingController.text),
      'description': 'Pay',
    };

    try {
      razorpay.open(options);
    } catch(e) {
      //debugPrint(e);

      print(e.toString());
    }

  }

  void _handlePaymentSuccess() {
    print("Payment Successful");
    Toast.show("Pament success", context);
  }

  void _handlePaymentError() {
    print("Payment Error");
    Toast.show("Pament error", context);
  }

  void _handleExternalWallet() {
    print("External Wallet");
    Toast.show("External Wallet", context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: _firebaseServices.usersRef.doc(_firebaseServices.getUserId()).collection("Cart").get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              // Collection Data ready to display
              if (snapshot.connectionState == ConnectionState.done) {

                // Display the data inside a list view
                return ListView(
                  padding: EdgeInsets.only(
                    top: 108.0,
                    bottom: 12.0,
                  ),
                  children: snapshot.data.docs.map((document) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProductPage(productId: document.id,),
                        ));
                      },
                      child: FutureBuilder(
                        future: _firebaseServices.productsRef.doc(document.id).get(),
                        builder: (context, productSnap) {
                          if(productSnap.hasError) {
                            return Container(
                              child: Center(
                                child: Text("${productSnap.error}"),
                              ),
                            );
                          }

                          if(productSnap.connectionState == ConnectionState.done) {
                            Map _productMap = productSnap.data.data();


                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 24.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      child: Image.network(
                                        "${_productMap['images'][0]}",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 16.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_productMap['name']}",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.w600),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Text(
                                            "\Rs.${_productMap['price']}",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Theme.of(context)
                                                    .accentColor,
                                                fontWeight:
                                                FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          "Order for - ${document.data()["size"]}",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.w600),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [

                                              IconButton(icon: Icon(FontAwesomeIcons.edit, size: 15,), onPressed: () async{
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => UpdatePage(productId: document.id,)));
                                              }),

                                              IconButton(icon: Icon(FontAwesomeIcons.trashAlt, size: 15,), onPressed: () async{
                                                var CollectionReference = _firebaseServices.usersRef.doc(_firebaseServices.getUserId()).collection("Cart");
                                                await CollectionReference.doc(document.id).delete();
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container();
                        },
                      ),
                    );
                  }).toList(),
                );
              }


              // Loading State
              return Scaffold(
                body: Center(

                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),


          Positioned(
            bottom: 30.0,
            left: 190.0,
            child: Container(
              width: 180.0,
              height: 80.0,
              //width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              child: CustomBtn(
                text: "Pay",
                onPressed: () {
                  openCheckout();
                },
              ),
            ),
          ),


          Positioned(
            bottom: 45.0,
            left: 30.0,
            child: Container(
              width: 150.0,
              height: 50.0,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Color(0xFFB3E5FC),
                  borderRadius: BorderRadius.circular(12.0)
              ),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  prefixText: "Rs. ",
                  hintText: "Amount",
                  suffixText: "/-"
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 110.0,
            left: 50.0,
            child: Container(
              width: 250.0,
              height: 60.0,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Color(0xFFB3E5FC),
                  borderRadius: BorderRadius.circular(12.0)
              ),
              child: TextField(
                controller: tabletextEditingController,
                decoration: InputDecoration(
                  prefixText: "Table No.: ",
                  hintText: "Enter Table No.",
                ),
              ),
            ),
          ),

          CustomActionBar(
            hasBackArrrow: true,
            title: "Confirm Order",
          )
        ],
      ),
    );
  }
}
