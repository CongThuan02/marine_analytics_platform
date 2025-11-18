import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/ship_bloc.dart';

class ShipListView extends StatelessWidget {
  const ShipListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ShipBloc()..add(LoadShipsEvent()), child: _ShipListViews());
  }
}

class _ShipListViews extends StatelessWidget {
  const _ShipListViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Ships")),
      body: BlocBuilder<ShipBloc, ShipState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return ListView.builder(
            itemCount: state.ships.length,
            itemBuilder: (context, index) {
              final ship = state.ships[index];
              return ListTile(
                title: Text(ship.name),
                subtitle: Text(ship.type),
                trailing: Text("${ship.createdAt.day}/${ship.createdAt.month}/${ship.createdAt.year}"),
              );
            },
          );
        },
      ),
    );
  }
}
