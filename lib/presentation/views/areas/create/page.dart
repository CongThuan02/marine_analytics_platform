import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/repositories/area_repository.dart';
import 'package:marine_analytics_platform/presentation/blocs/area/area_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreateAreaPage extends StatelessWidget {
  const CreateAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AreaBloc()..add(GetAreas()),
      child: const _CreateAreaPage(),
    );
  }
}

class _CreateAreaPage extends StatelessWidget {
  const _CreateAreaPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AreaBloc, AreaState>(
      listener: (context, state) {
        if (state.status == Status.loading) {
          context.loaderOverlay.show();
        }
        if (state.status == Status.success) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(message: state.message),
          );
          context.loaderOverlay.hide();

          // Only pop if it's a create action (not delete)
          // Delete messages typically contain "Deleted" or "deleted"
          if (!state.message.toLowerCase().contains('delete')) {
            context.pop(true);
          } else {
            // Reload areas after delete
            context.read<AreaBloc>().add(GetAreas());
          }
        }
        if (state.status == Status.loaded) {
          context.loaderOverlay.hide();
        }
      },
      builder: (context, state) {
        final bloc = context.read<AreaBloc>();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Manage Areas"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(GetAreas()),
              ),
            ],
          ),
          body: _buildBody(context, state, bloc),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateBottomSheet(context, bloc),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AreaState state, AreaBloc bloc) {
    if (state.status == Status.loading &&
        (state.areas == null || state.areas!.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    final areas = state.areas ?? [];

    if (areas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color: AppTheme.primaryGreenLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No areas yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Press + button to add a new area',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => bloc.add(GetAreas()),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: areas.length,
        itemBuilder: (context, index) {
          final area = areas[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: InkWell(
              onLongPress: () =>
                  _showDeleteDialog(context, bloc, area.id, area.name),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: AppTheme.accentBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        area.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () =>
                          _showEditDialog(context, bloc, area.id, area.name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          _showDeleteDialog(context, bloc, area.id, area.name),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context, AreaBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_location,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add New Area',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Form
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormTextField(
                        autofocus: true,
                        name: 'area',
                        label: 'Area name',
                        onChanged: (value) {
                          bloc.add(UpdateFieldName(name: value ?? ''));
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(bottomSheetContext),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                bloc.add(CreateArea());
                              },
                              child: const Text('Add Area'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => bloc.add(GetAreas()));
  }

  void _showEditDialog(
    BuildContext context,
    AreaBloc bloc,
    String id,
    String currentName,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              const Text('Edit Area'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Area Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  return;
                }

                // Update area in database
                final repository = AreaRepository();
                await repository.updateArea(id: id, name: newName);

                // Reload areas
                bloc.add(GetAreas());

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AreaBloc bloc,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(child: Text('Confirm Delete')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete area "$name"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data cannot be recovered after deletion',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(DeleteArea(id: id));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
