import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../store_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/image_helper.dart';

class StoreView extends GetView<StoreController> {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'PET HAVEN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Get.toNamed(Routes.CART),
              ),
              Obx(
                () => controller.cart.isNotEmpty
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${controller.cart.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                onChanged: controller.search,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Banner
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/onboarding1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Categories
            SizedBox(
              height: 50,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected =
                        controller.selectedCategoryId.value == category['id'];
                    return GestureDetector(
                      onTap: () => controller.selectCategory(category['id']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : (isDark
                                        ? Colors.black26
                                        : Colors.black.withValues(alpha: 0.05)),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? Colors.white12 : Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          category['name'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[600]),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Loading Indicator
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(),
            ),

            // Product Grid
            Obx(
              () => controller.products.isEmpty && !controller.isLoading.value
                  ? Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(child: Text("no_products".tr)),
                    )
                  : AnimationLimiter(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: GestureDetector(
                                  onTap: () => Get.toNamed(
                                    Routes.PRODUCT_DETAILS,
                                    arguments: product,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black45
                                              : Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white10
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                              image: DecorationImage(
                                                image:
                                                    product.image.startsWith(
                                                          'http',
                                                        ) ||
                                                        !product.image
                                                            .startsWith(
                                                              'assets',
                                                            )
                                                    ? NetworkImage(
                                                        ImageHelper.getImageUrl(
                                                              product.image,
                                                            ) ??
                                                            '',
                                                      )
                                                    : AssetImage(product.image)
                                                          as ImageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      product.categoryName,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 14,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        product.rating
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '\$${product.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration:
                                                        const BoxDecoration(
                                                          color:
                                                              AppColors.primary,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'orders_history'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.recentOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: Colors.grey[400], size: 60),
                      const SizedBox(height: 10),
                      Text(
                        'no_recent_orders'.tr,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.recentOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.recentOrders[index];
                  final product = order['product'];
                  final status = order['status'] ?? 'pending';

                  Color statusColor;
                  switch (status) {
                    case 'delivered':
                      statusColor = Colors.green;
                      break;
                    case 'shipped':
                      statusColor = Colors.blue;
                      break;
                    case 'cancelled':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.orange;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading:
                          product != null &&
                              product['image'] != null &&
                              product['image'].toString().startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                ImageHelper.getImageUrl(product['image']) ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.grey,
                              ),
                            ),
                      title: Text(
                        'Order #${order['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?['name']?['en'] ??
                                product?['name'] ??
                                'General Order',
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '\$${(order['total_amount'] ?? 0).toString()}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showOrderDetails(context, order),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, dynamic order) {
    final product = order['product'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: Get.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildDetailRow('Order ID', '#${order['id']}'),
              _buildDetailRow(
                'Status',
                (order['status'] ?? 'pending').toUpperCase(),
              ),
              _buildDetailRow(
                'Payment',
                (order['payment_status'] ?? 'paid').toUpperCase(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Shipping Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildDetailRow('Name', order['shipping_name'] ?? 'N/A'),
              _buildDetailRow('Phone', order['shipping_phone'] ?? 'N/A'),
              _buildDetailRow('Address', order['shipping_address'] ?? 'N/A'),
              const SizedBox(height: 20),
              const Text(
                'Item Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  product?['name']?['en'] ?? product?['name'] ?? 'Pet Product',
                ),
                subtitle: Text('\$${order['total_amount']}'),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product != null && product['image'] != null
                      ? Image.network(
                          ImageHelper.getImageUrl(product['image']) ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.shopping_bag),
                        )
                      : const Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
