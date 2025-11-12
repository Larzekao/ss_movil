import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/customers/presentation/controllers/favorites_controller.dart';

class FavoriteButton extends ConsumerWidget {
  final int productId;
  final VoidCallback? onError;
  final double size;
  final bool showLabel;

  const FavoriteButton({
    super.key,
    required this.productId,
    this.onError,
    this.size = 24,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesControllerProvider);
    final isFavorite = favoritesState.isFavorite(productId);

    return GestureDetector(
      onTap: () async {
        try {
          await ref
              .read(favoritesControllerProvider.notifier)
              .toggleFavorite(productId);

          if (context.mounted) {
            final message = isFavorite
                ? 'Eliminado de favoritos'
                : 'Agregado a favoritos';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(milliseconds: 800),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          onError?.call();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      },
      child: showLabel
          ? Chip(
              avatar: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              label: Text(isFavorite ? 'Favorito' : 'Agregar'),
              backgroundColor: isFavorite ? Colors.red[50] : Colors.grey[100],
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: size,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
    );
  }
}
