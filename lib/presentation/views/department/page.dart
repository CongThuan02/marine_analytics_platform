import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/presentation/blocs/area/area_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/department/widget/create.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

import '../../widgets/form_slect/form_select.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => DepartmentBloc(), child: _DepartmentPage());
  }
}

class _DepartmentPage extends StatelessWidget {
  const _DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DepartmentBloc>();
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách phòng ban")),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => CreateDepartment(bloc),
            isScrollControlled: true,
            useSafeArea: true,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
