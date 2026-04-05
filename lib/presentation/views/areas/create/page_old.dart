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
  const _CreateAreaPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AreaBloc, AreaState>(
      builder: (context, state) {
        return BlocListener<AreaBloc, AreaState>(
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
          child: Scaffold(
            appBar: AppBar(title: Text("Area List")),
            body: state.areas != null && state.areas != [] && state.status != Status.loading
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<AreaBloc>().add(GetAreas());
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onLongPress: () {
                              final bloc = context.read<AreaBloc>();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return BlocProvider.value(
                                    value: bloc,
                                    child: BlocBuilder<AreaBloc, AreaState>(
                                      builder: (context, state) {
                                        return AlertDialog(
                                          title: Text('Bạn có chắc chắn muốn xóa không ${state.areas?[index].name}'),
                                          content: Text("Lưu ý: dữ liệu không thể phục hồi sau khi xóa"),

                                          actions: <Widget>[
                                            Row(
                                              spacing: 12,
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      context.pop();
                                                    },
                                                    child: Text("Đóng"),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      bloc.add(DeleteArea(id: state.areas?[index].id ?? ''));
                                                    },
                                                    child: Text("Xoá"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ).then((value) {
                                if (value == true) {
                                  bloc.add(GetAreas());
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(12)),
                              child: Text('${state.areas?[index].name}'),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(height: 12),
                        itemCount: state.areas?.length ?? 0,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              onPressed: () {
                final bloc = context.read<AreaBloc>();
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return BlocProvider.value(
                      value: bloc,
                      child: BlocBuilder<AreaBloc, AreaState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Column(
                                spacing: 12,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Add New Area",
                                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
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
                                          autofocus: true,
                                          name: 'area',
                                          label: 'Area Name',
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
                                    child: Text("Add"),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ).then((value) {
                  bloc.add(GetAreas());
                });
              },
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
