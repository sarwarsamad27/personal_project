import 'package:flutter/material.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/productProvider/deleteProduct_provider.dart';
import 'package:provider/provider.dart';

class DeleteProductDialog extends StatelessWidget {
  final String productId;

  const DeleteProductDialog({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Product"),
      content: const Text(
        "Are you sure you want to delete this product permanently?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Close dialog

            final token = await LocalStorage.getToken() ?? "";
            final provider = Provider.of<DeleteProductProvider>(
              context,
              listen: false,
            );

            await provider.deleteProduct(productId: productId, token: token);

            if (provider.deleteProductModel?.message != null) {
              AppToast.show(provider.deleteProductModel!.message!);
              Navigator.pop(context); // Close product detail screen
            } else {
              AppToast.show("Failed to delete product");
            }
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
