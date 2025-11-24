import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/presentation/blocs/area/area_bloc.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AreaBloc(),
      child: _DepartmentPage(),
    );

  }
}

class _DepartmentPage extends StatelessWidget {
  const _DepartmentPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách loại chất thải")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 12,
          children: [
            Container(
              padding: .symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12)
              ),
              child: FormBuilderField<String>(
                name: 'area',
                builder: (field) {
                  return InkWell(
                    onTap: () async {
                      final bloc = context.read<AreaBloc>();
                        context.loaderOverlay.show();
                        bloc.add(GetAreas());
                       var areaState=  await bloc.stream.firstWhere((state) => state.status != Status.loading);
                       if(areaState.status == Status.loaded){
                         if(!context.mounted) return;
                         context.loaderOverlay.hide();
                       }
                      final areas = [AreaModel(name: "Chọn"), ...?bloc.state.areas];
                       if(!context.mounted) return;
                      final selected = await showModalBottomSheet<AreaModel>(
                        context: context,
                        builder: (context) {
                          return ListView.builder(
                            itemCount: areas.length,
                            itemBuilder: (context, index) {
                              final item = areas[index];
                              return ListTile(
                                minVerticalPadding: 1,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                title: Text(item.name ?? ''),
                                onTap: () => Navigator.pop(context, item),
                              );
                            },
                          );
                        },
                      );

                      if (selected != null) {
                        field.didChange(selected.name);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Chọn khu vực',
                        border: InputBorder.none,
                      ),
                      child: Text(field.value ?? 'Chọn khu vực'),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: .symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12)
              ),
              child: FormBuilderField<String>(
                name: 'area',
                builder: (field) {
                  return InkWell(
                    onTap: () async {
                      final bloc = context.read<AreaBloc>();
                        context.loaderOverlay.show();
                        bloc.add(GetAreas());
                       var areaState=  await bloc.stream.firstWhere((state) => state.status != Status.loading);
                       if(areaState.status == Status.loaded){
                         if(!context.mounted) return;
                         context.loaderOverlay.hide();
                       }
                      final areas = [AreaModel(name: "Chọn"), ...?bloc.state.areas];
                       if(!context.mounted) return;
                      final selected = await showModalBottomSheet<AreaModel>(
                        context: context,
                        builder: (context) {
                          return ListView.builder(
                            itemCount: areas.length,
                            itemBuilder: (context, index) {
                              final item = areas[index];
                              return ListTile(
                                minVerticalPadding: 1,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                title: Text(item.name ?? ''),
                                onTap: () => Navigator.pop(context, item),
                              );
                            },
                          );
                        },
                      );

                      if (selected != null) {
                        field.didChange(selected.name);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Chọn khu vực',
                        border: InputBorder.none,
                      ),
                      child: Text(field.value ?? 'Chọn khu vực'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
