import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_limit/waste_limit_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/waste_limit/widgets/create_limit_bottom_sheet.dart';
import 'package:marine_analytics_platform/presentation/views/waste_limit/widgets/limit_card.dart';

class WasteLimitPage extends StatelessWidget {
  const WasteLimitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteLimitBloc()..add(const LoadWasteLimits()),
      child: const _WasteLimitView(),
    );
  }
}

class _WasteLimitView extends StatelessWidget {
  const _WasteLimitView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Hạn mức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WasteLimitBloc>().add(const LoadWasteLimits());
            },
          ),
        ],
      ),
      body: BlocBuilder<WasteLimitBloc, WasteLimitState>(
        builder: (context, state) {
          if (state is WasteLimitLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WasteLimitError) {
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
                      context.read<WasteLimitBloc>().add(const LoadWasteLimits());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is WasteLimitLoaded) {
            if (state.limits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 80, color: AppTheme.primaryGreenLight),
                    const SizedBox(height: 16),
                    const Text('Chưa có hạn mức nào', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Nhấn nút + để thêm hạn mức mới', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WasteLimitBloc>().add(const LoadWasteLimits());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.limits.length,
                itemBuilder: (context, index) {
                  return LimitCard(limit: state.limits[index]);
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
              value: context.read<WasteLimitBloc>(),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
                child: const CreateLimitBottomSheet(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
