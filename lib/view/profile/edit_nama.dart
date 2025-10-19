import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';
import 'package:tugas_17_flutter/view/widgets/section_title.dart';

class EditNama extends StatefulWidget {
  final String currentName;
  const EditNama({super.key, required this.currentName});

  @override
  State<EditNama> createState() => _EditNamaState();
}

class _EditNamaState extends State<EditNama> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.teal),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              sectionTitle("Ubah Nama"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    CustomTextFormField(
                      controller: _nameController,
                      hintText: 'Nama Lengkap',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: "Ubah",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, _nameController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
