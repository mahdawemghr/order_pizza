import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const PizzaApp());
}

class PizzaApp extends StatelessWidget {
  const PizzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🍕 Pizza Palace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const PizzaBuilderPage(),
    );
  }
}

// ==================== MODELS ====================

class PizzaOrder {
  final String size;
  final String crust;
  final List<String> toppings;
  final bool isSpicy;
  final DateTime createdAt;

  PizzaOrder({
    required this.size,
    required this.crust,
    required this.toppings,
    required this.isSpicy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get price {
    double base = _basePrice();
    double toppingsPrice = toppings.length * 1.5;
    double crustExtra = crust == 'Stuffed' ? 2.0 : 0.0;
    double spicyExtra = isSpicy ? 0.5 : 0.0;
    return base + toppingsPrice + crustExtra + spicyExtra;
  }

  double _basePrice() {
    switch (size) {
      case 'Small': return 8.0;
      case 'Medium': return 12.0;
      case 'Large': return 16.0;
      case 'Extra Large': return 20.0;
      default: return 8.0;
    }
  }

  String get sizeEmoji {
    switch (size) {
      case 'Small': return '🍕';
      case 'Medium': return '🍕🍕';
      case 'Large': return '🍕🍕🍕';
      case 'Extra Large': return '🍕🍕🍕🍕';
      default: return '🍕';
    }
  }
}

// ==================== MAIN PAGE ====================

class PizzaBuilderPage extends StatefulWidget {
  const PizzaBuilderPage({super.key});

  @override
  State<PizzaBuilderPage> createState() => _PizzaBuilderPageState();
}

class _PizzaBuilderPageState extends State<PizzaBuilderPage>
    with SingleTickerProviderStateMixin {
  // Pizza configuration
  List<String> pizzaSizes = ['Small', 'Medium', 'Large', 'Extra Large'];
  Map<String, double> pizzaPrices = {
    'Small': 8.0,
    'Medium': 12.0,
    'Large': 16.0,
    'Extra Large': 20.0,
  };
  String selectedSize = 'Medium';

  List<String> crustTypes = ['Thin Crust', 'Thick Crust', 'Stuffed Crust'];
  String selectedCrust = 'Thin Crust';

  bool isSpicy = false;

  // Toppings with prices
  final List<Map<String, dynamic>> availableToppings = [
    {'name': 'Pepperoni', 'emoji': '🥓', 'price': 1.5},
    {'name': 'Mushrooms', 'emoji': '🍄', 'price': 1.0},
    {'name': 'Onions', 'emoji': '🧅', 'price': 0.75},
    {'name': 'Extra Cheese', 'emoji': '🧀', 'price': 1.25},
    {'name': 'Bell Peppers', 'emoji': '🌶️', 'price': 0.75},
    {'name': 'Olives', 'emoji': '🫒', 'price': 1.0},
    {'name': 'Tomatoes', 'emoji': '🍅', 'price': 0.75},
    {'name': 'Bacon', 'emoji': '🥓', 'price': 2.0},
  ];

  Map<String, bool> toppingSelections = {};
  List<PizzaOrder> orderList = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();

    // Initialize topping selections
    for (var topping in availableToppings) {
      toppingSelections[topping['name']] = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<String> get selectedToppings {
    return toppingSelections.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  double get currentPrice {
    double base = pizzaPrices[selectedSize] ?? 8.0;
    double toppingsPrice = selectedToppings.fold(
      0.0,
      (sum, name) {
        var topping = availableToppings.firstWhere(
          (t) => t['name'] == name,
          orElse: () => {'price': 0.0},
        );
        return sum + (topping['price'] as double);
      },
    );
    double crustExtra = selectedCrust == 'Stuffed Crust' ? 2.0 : 0.0;
    double spicyExtra = isSpicy ? 0.5 : 0.0;
    return base + toppingsPrice + crustExtra + spicyExtra;
  }

  void _addToCart() {
    if (selectedToppings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🍕 Please select at least one topping!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      orderList.add(PizzaOrder(
        size: selectedSize,
        crust: selectedCrust,
        toppings: List.from(selectedToppings),
        isSpicy: isSpicy,
      ));
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🍕 Pizza added to cart! \$${currentPrice.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => _navigateToCart(),
        ),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShoppingCartPage(orders: orderList),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      // Refresh when coming back
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFFF8C42),
              const Color(0xFFFFD93D),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🍕 Pizza Palace',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Build your perfect pizza!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      _buildCartButton(),
                    ],
                  ),
                ),
              ),

              // Pizza Preview
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildPizzaPreview(),
                  ),
                ),
              ),

              // Content Cards
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildSizeSection(),
                  _buildCrustSection(),
                  _buildToppingsSection(),
                  _buildSpicySection(),
                  _buildPriceCard(),
                  _buildAddToCartButton(),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: orderList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCart,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF6B35),
              icon: Badge(
                backgroundColor: Colors.red,
                textColor: Colors.white,
                label: Text(
                  '${orderList.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: const Icon(Icons.shopping_cart),
              ),
              label: Text(
                'Cart (\$${orderList.fold(0.0, (sum, o) => sum + o.price).toStringAsFixed(0)})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: _navigateToCart,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
            if (orderList.isNotEmpty)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${orderList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPizzaPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Pizza Visual
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD93D),
                  const Color(0xFFF5C842),
                  const Color(0xFFE8A830),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Crust ring
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4921A),
                      width: 12,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFF3B0),
                        const Color(0xFFFFE066),
                      ],
                    ),
                  ),
                ),
                // Toppings indicators
                ..._buildToppingIndicators(),
                // Spicy indicator
                if (isSpicy)
                  const Positioned(
                    top: 30,
                    child: Icon(Icons.local_fire_department,
                        color: Colors.red, size: 24),
                  ),
                // Center cheese
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF8DC).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Pizza info
          Text(
            '$selectedSize Pizza',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$selectedCrust • ${selectedToppings.length} toppings${isSpicy ? ' • 🔥 Spicy' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToppingIndicators() {
    List<Widget> indicators = [];
    List<String> toppings = selectedToppings;
    int count = toppings.length;

    if (count == 0) return indicators;

    for (int i = 0; i < math.min(count, 6); i++) {
      var topping = availableToppings.firstWhere(
        (t) => t['name'] == toppings[i],
        orElse: () => {'emoji': '🍕'},
      );
      double angle = (i / math.min(count, 6)) * 2 * math.pi - math.pi / 2;
      double radius = 45.0;
      double x = math.cos(angle) * radius;
      double y = math.sin(angle) * radius;

      indicators.add(
        Positioned(
          left: 90 + x - 8,
          top: 90 + y - 8,
          child: Text(
            topping['emoji'] as String? ?? '🍕',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return indicators;
  }

  Widget _buildSizeSection() {
    return _buildCard(
      title: '📏 Choose Your Size',
      child: Column(
        children: pizzaSizes.asMap().entries.map((entry) {
          int idx = entry.key;
          String size = entry.value;
          double price = pizzaPrices[size]!;
          bool isSelected = selectedSize == size;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(
              bottom: idx < pizzaSizes.length - 1 ? 8 : 0,
            ),
            child: Material(
              color: isSelected
                  ? const Color(0xFFFF6B35).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => selectedSize = size),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6B35)
                              : Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_pizza,
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              size,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFFFF6B35)
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? const Color(0xFFFF6B35).withOpacity(0.8)
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCrustSection() {
    return _buildCard(
      title: '🥐 Select Crust Type',
      child: Column(
        children: crustTypes.map((crust) {
          bool isSelected = selectedCrust == crust;
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : Colors.transparent,
              ),
            ),
            tileColor: isSelected
                ? const Color(0xFFFF6B35).withOpacity(0.1)
                : null,
            selectedTileColor: const Color(0xFFFF6B35).withOpacity(0.1),
            leading: Icon(
              Icons.bakery_dining,
              color: isSelected ? const Color(0xFFFF6B35) : null,
            ),
            title: Text(crust),
            trailing: isSelected
                ? const Icon(Icons.check, color: Color(0xFFFF6B35))
                : null,
            onTap: () => setState(() => selectedCrust = crust),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToppingsSection() {
    return _buildCard(
      title: '🥗 Add Toppings',
      subtitle: 'Select as many as you like!',
      child: Column(
        children: availableToppings.asMap().entries.map((entry) {
          int idx = entry.key;
          var topping = entry.value;
          String name = topping['name'] as String;
          String emoji = topping['emoji'] as String;
          double price = topping['price'] as double;
          bool isSelected = toppingSelections[name] ?? false;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(
              bottom: idx < availableToppings.length - 1 ? 4 : 0,
            ),
            child: CheckboxListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tileColor: isSelected
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  toppingSelections[name] = value!;
                });
              },
              secondary: Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '+\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : Colors.grey,
                  fontSize: 12,
                ),
              ),
              activeColor: const Color(0xFFFF6B35),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpicySection() {
    return _buildCard(
      title: '🌶️ Make it Spicy?',
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        value: isSpicy,
        onChanged: (value) => setState(() => isSpicy = value),
        secondary: const Text('🔥', style: TextStyle(fontSize: 28)),
        title: const Text('Add extra spice'),
        subtitle: const Text('For those who like it hot!'),
        activeColor: const Color(0xFFFF6B35),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35),
            const Color(0xFFFF8C42),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Base Price', '\$${pizzaPrices[selectedSize]!.toStringAsFixed(2)}'),
          if (selectedToppings.isNotEmpty)
            _buildPriceRow(
              'Toppings (${selectedToppings.length})',
              '+\$${selectedToppings.fold(0.0, (sum, name) {
                var t = availableToppings.firstWhere(
                  (t) => t['name'] == name,
                  orElse: () => {'price': 0.0},
                );
                return sum + (t['price'] as double);
              }).toStringAsFixed(2)}',
            ),
          if (selectedCrust == 'Stuffed Crust')
            _buildPriceRow('Stuffed Crust', '+\$2.00'),
          if (isSpicy) _buildPriceRow('Extra Spice', '+\$0.50'),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(price, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isSpicy ? Colors.red : const Color(0xFF4CAF50),
                isSpicy ? Colors.orange : const Color(0xFF8BC34A),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _addToCart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ==================== SHOPPING CART PAGE ====================

class ShoppingCartPage extends StatefulWidget {
  final List<PizzaOrder> orders;

  const ShoppingCartPage({super.key, required this.orders});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get totalPrice {
    return widget.orders.fold(0.0, (sum, order) => sum + order.price);
  }

  void _removeOrder(int index) {
    setState(() {
      widget.orders.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pizza removed from cart'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => _buildCheckoutDialog(),
    );
  }

  Widget _buildCheckoutDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFFF8C42),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🎉', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.orders.length} pizza(s) coming your way!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.orders.clear();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B35),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start New Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFFF8C42),
              const Color(0xFFFFD93D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '🛒 Your Cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (widget.orders.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => widget.orders.clear());
                        },
                        icon: const Icon(Icons.delete_sweep,
                            color: Colors.white70),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),

              // Cart Content
              Expanded(
                child: widget.orders.isEmpty
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🍕',
                                  style: TextStyle(fontSize: 80)),
                              const SizedBox(height: 16),
                              const Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some delicious pizzas!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.orders.length,
                        itemBuilder: (context, index) {
                          final order = widget.orders[index];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Dismissible(
                              key: Key(order.createdAt.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 30),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text('Remove Pizza?'),
                                    content: const Text(
                                        'Are you sure you want to remove this pizza from your cart?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                _removeOrder(index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B35)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.local_pizza,
                                          color: Color(0xFFFF6B35), size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order #${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${order.size} • ${order.crust}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (order.toppings.isNotEmpty)
                                            Text(
                                              order.toppings.join(', '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          if (order.isSpicy)
                                            const Text(
                                              '🔥 Spicy',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '\$${order.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF6B35),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _removeOrder(index),
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Summary
              if (widget.orders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.orders.length} Item${widget.orders.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xFFFF6B35).withOpacity(0.4),
                            ),
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}