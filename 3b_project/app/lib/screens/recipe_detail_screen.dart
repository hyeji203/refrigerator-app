import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          const CartIconButton(),
          IconButton(
            icon: Icon(
              recipe.isSaved == 1 ? Icons.bookmark : Icons.bookmark_outline,
              color: recipe.isSaved == 1 ? Colors.amber : null,
            ),
            onPressed: () async {
              await ApiService.dio.patch('/recipes/${recipe.recipeId}/save');
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (recipe.cookingTime != null)
                      _infoItem(Icons.timer, '${recipe.cookingTime}분', '조리시간'),
                    if (recipe.difficulty != null)
                      _infoItem(Icons.bar_chart, recipe.difficulty!, '난이도'),
                    if (recipe.servings != null)
                      _infoItem(Icons.people, '${recipe.servings}인분', '분량'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // YouTube 영상 링크
            if (recipe.youtubeUrl != null) ...[
              const Text('요리 영상',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(recipe.youtubeUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('YouTube 앱을 열 수 없습니다.')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_filled,
                          color: Colors.red, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recipe.youtubeTitle ?? '요리 방법 영상 보기',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.open_in_new, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 필요 재료
            if (recipe.ingredients.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('필요 재료',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: const Text('장바구니에 담기'),
                    onPressed: () {
                      final cart = context.read<CartService>();
                      final missing = recipe.ingredients
                          .where((e) => e.isAvailable == 0)
                          .map((e) => CartItem(
                                name: e.ingredientName,
                                amount: e.amount,
                              ))
                          .toList();
                      if (missing.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('냉장고에 모든 재료가 있어요!')),
                        );
                        return;
                      }
                      cart.addItems(missing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${missing.length}개 재료를 장바구니에 담았어요.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...recipe.ingredients.map((ing) => ListTile(
                    dense: true,
                    leading: Icon(
                      ing.isAvailable == 1
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: ing.isAvailable == 1 ? Colors.green : Colors.grey,
                    ),
                    title: Text(ing.ingredientName),
                    trailing: Text(ing.amount ?? '',
                        style: const TextStyle(color: Colors.grey)),
                  )),
              const SizedBox(height: 16),
            ],

            // 조리법
            const Text('조리법',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              recipe.description ?? '조리법 정보가 없습니다.',
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
