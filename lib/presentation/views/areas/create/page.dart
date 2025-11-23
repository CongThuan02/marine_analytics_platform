import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/blocs/area/area_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreateAreaPage extends StatelessWidget {
  const CreateAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AreaBloc()..add(GetAreas()), child: _CreateAreaPage());
  }
}

class _CreateAreaPage extends StatelessWidget {
  const _CreateAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.loaderOverlay.hide();
    return BlocBuilder<AreaBloc, AreaState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text("Danh sách khu vực")),
          body: state.areas != null && state.areas != [] && state.status != Status.loading
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 28.0),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<AreaBloc>().add(GetAreas());
                        },
                        icon: Icon(Icons.add),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return Text('${state.areas?[index].name}');
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 12),
                          itemCount: state.areas?.length ?? 0,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
            onPressed: () {
              final bloc = context.read<AreaBloc>();
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BlocProvider.value(
                    value: bloc,
                    child: BlocListener<AreaBloc, AreaState>(
                      listener: (context, state) {
                        if (state.status == Status.loading) {
                          context.loaderOverlay.show();
                        }
                        if (state.status == Status.success) {
                          showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: state.message));
                          context.pop(true);
                          context.loaderOverlay.hide();
                        }
                        if (state.status == Status.loaded) {
                          context.loaderOverlay.hide();
                        }
                      },
                      child: BlocBuilder<AreaBloc, AreaState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Column(
                                spacing: 12,
                                mainAxisSize: .min,
                                children: [
                                  Row(
                                    mainAxisAlignment: .center,
                                    crossAxisAlignment: .center,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Thêm mới khu vực",
                                            style: TextStyle(fontSize: 24, fontWeight: .w500),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: .bottomRight,
                                        child: IconButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          icon: Icon(Icons.close_rounded),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      spacing: 12,
                                      children: [
                                        FormTextField(
                                          name: 'area',
                                          label: 'Tên khu vực',
                                          onChanged: (value) {
                                            bloc.add(UpdateFieldName(name: value ?? ''));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<AreaBloc>().add(CreateArea());
                                    },
                                    child: Text("Thêm"),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ).then((value) {
                bloc.add(GetAreas());
              });
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
