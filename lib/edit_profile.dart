// import 'package:flutter/material.dart';
// import 'package:tugas_17_flutter/model/user_model.dart' as app_models;

// class EditProfilePage extends StatefulWidget {
//   final app_models.User user;

//   const EditProfilePage({super.key, required this.user});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.user.name);
//     _emailController = TextEditingController(text: widget.user.email);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   void _saveProfile() {
//     final updatedUser = app_models.User(
//       id: widget.user.id,
//       name: _nameController.text,
//       email: _emailController.text,
//       profilePhotoUrl: widget.user.profilePhotoUrl,
//       trainingTitle: widget.user.trainingTitle,
//       batchKe: widget.user.batchKe,
//       jenisKelamin: widget.user.jenisKelamin,
//       // batchId: widget.user.batchId,
//       // trainingId: widget.user.trainingId,
//     );

//     Navigator.pop(context, updatedUser);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: AppBar(
//         title: const Text("Edit Profil"),
//         backgroundColor: Colors.grey[850],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Nama",
//                 filled: true,
//                 fillColor: Colors.white10,
//                 labelStyle: TextStyle(color: Colors.white70),
//                 border: OutlineInputBorder(),
//               ),
//               style: const TextStyle(color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 filled: true,
//                 fillColor: Colors.white10,
//                 labelStyle: TextStyle(color: Colors.white70),
//                 border: OutlineInputBorder(),
//               ),
//               style: const TextStyle(color: Colors.white),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _saveProfile,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text(
//                 "Simpan Perubahan",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
