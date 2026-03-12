import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result = await apiService.getProducts();

      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> refreshProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    await loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : RefreshIndicator(
                      onRefresh: refreshProducts,
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['model_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Model Code: ${product['model_code'] ?? ''}'),
                                  Text('Appliance Type: ${product['appliance_type'] ?? ''}'),
                                  Text('Unit of Measurement: ${product['unitsofmeasurement'] ?? ''}'),
                                  Text('Contract Date: ${product['contract_date'] ?? ''}'),
                                  Text('Delivery Date: ${product['delivery_date'] ?? ''}'),
                                  Text('Installment Date: ${product['installment_date'] ?? ''}'),
                                  Text('Client ID: ${product['client_id'] ?? ''}'),
                                  Text('Employee ID: ${product['employee_id'] ?? ''}'),
                                  Text('Notes: ${product['notes'] ?? ''}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}