import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoffeeItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  CoffeeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory CoffeeItem.fromJson(Map<String, dynamic> json) {
    return CoffeeItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['imageUrl'],
    );
  }
}

Future<List<CoffeeItem>> fetchCoffeeItems() async {
  final response = await http.get(Uri.parse('http://localhost/cafe-api/'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => CoffeeItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load coffee items');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CoffeeShopScreen(),
    );
  }
}

class CoffeeShopScreen extends StatefulWidget {
  const CoffeeShopScreen({super.key});

  @override
  State<CoffeeShopScreen> createState() => _CoffeeShopScreenState();
}

class _CoffeeShopScreenState extends State<CoffeeShopScreen> {
  late Future<List<CoffeeItem>> futureCoffeeItems;
  List<CoffeeItem> allCoffeeItems = [];
  List<CoffeeItem> filteredCoffeeItems = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCoffeeItems();
  }

  void loadCoffeeItems() async {
    try {
      final items = await fetchCoffeeItems();
      setState(() {
        allCoffeeItems = items;
        filteredCoffeeItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading coffee items: $e');
    }
  }

  void searchCoffee(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCoffeeItems = allCoffeeItems;
      } else {
        filteredCoffeeItems = allCoffeeItems
            .where((coffee) =>
                coffee.name.toLowerCase().contains(query.toLowerCase()) ||
                coffee.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color.fromARGB(255, 19, 19, 19),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Location Section
                      const Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              Row(
                                children: [
                                  Text(
                                    'Tokyo, Japan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      size: 20, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Section
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(Icons.search, color: Colors.grey),
                                  hintText: 'Search coffee',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onChanged: searchCoffee,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Banner Section
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.brown[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(16),
                                ),
                                child: Image(
                                  image: AssetImage('assets/images/banner.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sip the flavor,\nfeel the art.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All Coffee', true),
                          _buildCategoryChip('Macchiato', false),
                          _buildCategoryChip('Latte', false),
                          _buildCategoryChip('Americano', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Coffee Grid
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredCoffeeItems.isEmpty
                            ? const Center(
                                child: Text('No coffee found',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey)))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: filteredCoffeeItems.length,
                                itemBuilder: (context, index) {
                                  final coffee = filteredCoffeeItems[index];
                                  return _buildCoffeeCard(
                                    coffee.name,
                                    coffee.description,
                                    coffee.price,
                                    coffee.imageUrl,
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: const IconThemeData(color: Colors.brown),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orangeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isSelected ? Colors.orangeAccent : Colors.grey),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCoffeeCard(
    String name,
    String description,
    double price,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rp $price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
