import 'package:e_shop/domain/entities/product_entity.dart';
import 'package:e_shop/domain/repositories/product_repository.dart';

class FetchProductUsecase {
  final ProductRepository repository;

  FetchProductUsecase(this.repository);

  Future<void> call() async {
    return await repository.fetchProducts();
  }
}
