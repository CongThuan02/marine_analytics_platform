import '../../data/models/ship_model.dart';
import '../../data/repositories/ship_repository.dart';

class GetAllShipsUseCase {
  final ShipRepository repo = ShipRepository();

  GetAllShipsUseCase();

  Future<List<ShipModel>> call() async {
    return await repo.getAllShips();
  }
}
