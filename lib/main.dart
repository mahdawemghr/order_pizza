import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza Order',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Orders {
  String size;
  String crust;
  List<String> toppings;
  bool isSpicy;

  Orders({
    required this.size,
    required this.crust,
    required this.toppings,
    required this.isSpicy,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> pizzaSizes = ['Small', 'Medium', 'Large', 'Extra Large'];
  Map<String, double> pizzaPrices = {
    'Small': 5.0,
    'Medium': 8.0,
    'Large': 11.0,
    'Extra Large': 14.0,
  };
  String selectedSize = 'Small';

  List<String> crustTypes = ['Thin', 'Thick', 'Stuffed'];
  String selectedCrust = 'Thin';

  bool isSpicy = false;

  bool pepperoni = false;
  bool mushrooms = false;
  bool onions = false;

  List<String> selectedToppings = [];
  List<Orders> orderList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Pizza', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// PIZZA SIZE
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              margin: const EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Pizza Size:'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pizzaSizes.length,
                      itemBuilder: (context, index) {
                        String size = pizzaSizes[index];
                        double price = pizzaPrices[size] ?? 0.0;
                        return ListTile(
                          leading: Radio(
                            value: size,
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value!;
                              });
                            },
                          ),
                          title: Text(size),
                          subtitle: size == selectedSize
                              ? Text('Price: \$${price.toStringAsFixed(2)}')
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// CRUST TYPE
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Crust:'),
                    DropdownMenu(
                      dropdownMenuEntries: crustTypes.map((item) {
                        return DropdownMenuEntry(value: item, label: item);
                      }).toList(),
                      onSelected: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCrust = value;
                          });
                        }
                      },
                      initialSelection: selectedCrust,
                    ),
                  ],
                ),
              ),
            ),

            /// TOPPINGS
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Toppings:'),
                    CheckboxListTile(
                      title: const Text('Pepperoni'),
                      value: pepperoni,
                      onChanged: (bool? value) {
                        setState(() {
                          pepperoni = value!;
                          value
                              ? selectedToppings.add('Pepperoni')
                              : selectedToppings.remove('Pepperoni');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Onions'),
                      value: onions,
                      onChanged: (bool? value) {
                        setState(() {
                          onions = value!;
                          value
                              ? selectedToppings.add('Onions')
                              : selectedToppings.remove('Onions');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Mushrooms'),
                      value: mushrooms,
                      onChanged: (bool? value) {
                        setState(() {
                          mushrooms = value!;
                          value
                              ? selectedToppings.add('Mushrooms')
                              : selectedToppings.remove('Mushrooms');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// SPICY SWITCH
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Spicy?'),
                    Switch(
                      value: isSpicy,
                      onChanged: (bool value) {
                        setState(() {
                          isSpicy = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// ADD TO CART BUTTON
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      orderList.add(
                        Orders(
                          size: selectedSize,
                          crust: selectedCrust,
                          toppings: List.from(selectedToppings),
                          isSpicy: isSpicy,
                        ),
                      );
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ),

            /// CART SUMMARY
            Card(
              color: Theme.of(context).colorScheme.primary,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Added to Cart: ${orderList.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingCart(orderList),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingCart extends StatelessWidget {
  final List<Orders> orders;

  const ShoppingCart(this.orders, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order #${index + 1}'),
                  subtitle: Text(
                    'Size: ${order.size}, Crust: ${order.crust}, '
                    'Toppings: ${order.toppings.join(', ')}, '
                    'Spicy: ${order.isSpicy ? "Yes" : "No"}',
                  ),
                );
              },
            ),
    );
  }
}
