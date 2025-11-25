import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/blocs/login/login_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == Status.loading) {
          context.loaderOverlay.show();
          return;
        }
        context.loaderOverlay.hide();

        if (state.status == Status.success && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
          );
          context.go('/');
        }

        if (state.status == Status.fail && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Đăng nhập")),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Chào mừng bạn trở lại!",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Đăng nhập để tiếp tục quản lý chất thải.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  FormTextField(
                    name: 'email',
                    label: 'Email',
                    validators: [
                      FormBuilderValidators.required(errorText: 'Vui lòng nhập email'),
                      FormBuilderValidators.email(errorText: 'Email không hợp lệ'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    name: 'password',
                    label: 'Mật khẩu',
                    isPassword: true,
                    validators: [
                      FormBuilderValidators.required(errorText: 'Vui lòng nhập mật khẩu'),
                      FormBuilderValidators.minLength(6, errorText: 'Tối thiểu 6 ký tự'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Đăng nhập"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pushNamed('/register'),
                    child: const Text("Chưa có tài khoản? Đăng ký ngay"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) return;
    final values = formState!.value;
    final email = values['email'] as String? ?? '';
    final password = values['password'] as String? ?? '';
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(LoginSubmitted(email: email, password: password));
  }
}
