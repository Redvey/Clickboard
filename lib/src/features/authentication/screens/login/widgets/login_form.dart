import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/common_widgets/large_button.dart';
import '../../../../../core/common_widgets/my_text_field.dart';
import '../../../../../core/constants/text_strings.dart';
import '../../../../../core/utils/validators/validators.dart';
import '../../../controllers/auth_controller.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  final TextEditingController emailCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();

  @override
  void dispose() {
    emailCont.dispose();
    passCont.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            MyTextField(
              focusNode: emailFocus,
              inputControl: emailCont,
              validator: emailValidate,
              hint: emailHint,
              icon: Icons.mail_outline,
              inputType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(passFocus),
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
              focusNode: passFocus,
              validator: passValidate,
              inputControl: passCont,
              hint: passHint,
              icon: Icons.password_outlined,
              inputType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.newPassword],
              showPassword: false,
            ),
            const SizedBox(
              height: 20,
            ),
            MainButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    !ref.read(authControllerProvider)) {
                  ref.read(authControllerProvider.notifier).loginUser(
                      context, emailCont.text.trim(), passCont.text.trim());
                }
              },
              child: (!ref.watch(authControllerProvider))
                  ? const Text('LOG IN')
                  : const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
            ),
            TextButton(
                onPressed: () {
                  GoRouter.of(context).push('/forgot-password');
                },
                child: Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
          ],
        ),
      ),
    );
  }
}
