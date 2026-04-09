import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/di/injection_container.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/reminder/widgets/create_reminder_bottom_sheet.dart';
import 'package:marine_analytics_platform/presentation/views/reminder/widgets/reminder_card.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReminderBloc>()..add(const LoadReminders()),
      child: const _ReminderView(),
    );
  }
}

class _ReminderView extends StatelessWidget {
  const _ReminderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhắc nhở'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReminderBloc>().add(const LoadReminders());
            },
          ),
        ],
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReminderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReminderBloc>().add(const LoadReminders());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 80, color: AppTheme.primaryGreenLight),
                    const SizedBox(height: 16),
                    const Text('Không có dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Nhấn nút + để thêm nhắc nhở mới', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReminderBloc>().add(const LoadReminders());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.reminders.length,
                itemBuilder: (context, index) {
                  return ReminderCard(reminder: state.reminders[index]);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (bottomSheetContext) => BlocProvider.value(
              value: context.read<ReminderBloc>(),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
                child: const CreateReminderBottomSheet(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
