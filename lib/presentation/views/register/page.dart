import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/localization/localization_extension.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/singUp.dart';
import 'package:marine_analytics_platform/presentation/blocs/register/register_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';
import 'package:marine_analytics_platform/presentation/widgets/clickable_logo.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _onSubmit() {
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) {
      _showSnackBar('Vui lòng kiểm tra thông tin của bạn.', isError: true);
      return;
    }

    final values = formState!.value;

    final singUp = SingUp(
      email: values['email'] as String?,
      password: values['password'] as String?,
      departmentId: values['department_id'] as String?,
      role: values['role'] as String?,
    );

    context.read<RegisterBloc>().add(RegisterSubmitted(singUp));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == Status.loading) {
          context.loaderOverlay.show();
          return;
        }
        context.loaderOverlay.hide();

        if (state.status == Status.success && state.message != null) {
          _showSnackBar(state.message!);
          if (context.canPop()) {
            context.pop();
          }
        }
        if (state.status == Status.fail && state.message != null) {
          _showSnackBar(state.message!, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.register)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  // Clickable Logo
                  const ClickableLogo(
                    logoSize: 70,
                    titleFontSize: 28,
                    subtitleFontSize: 14,
                  ),
                  const SizedBox(height: 32),
                  FormTextField(
                    name: "email",
                    label: context.l10n.email,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    name: "password",
                    isPassword: true,
                    label: context.l10n.password,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(
                        6,
                        errorText: 'Tối thiểu 6 ký tự',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormSelect(
                    name: "department_id",
                    label: "Phòng ban",
                    tableName: "departments",
                    validators: [
                      (value) {
                        if (value == null || value == 'select') {
                          return 'Vui lòng chọn phòng ban';
                        }
                        return null;
                      },
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormSelect(
                    name: 'role',
                    label: 'Vai trò',
                    iniItems: const [
                      {'id': 'admin', 'name': 'Admin'},
                      {'id': 'staff', 'name': 'Staff'},
                      {'id': 'viewer', 'name': 'Viewer'},
                    ],
                    validators: [
                      (value) {
                        if (value == null || value == 'select') {
                          return 'Vui lòng chọn vai trò';
                        }
                        return null;
                      },
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      child: Text(context.l10n.register),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
