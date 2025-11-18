part of 'ship_bloc.dart';

class ShipState {
  final bool loading;
  final List<ShipModel> ships;
  final String? error;

  ShipState({this.loading = false, this.ships = const [], this.error});

  ShipState copyWith({bool? loading, List<ShipModel>? ships, String? error}) {
    return ShipState(loading: loading ?? this.loading, ships: ships ?? this.ships, error: error);
  }
}
