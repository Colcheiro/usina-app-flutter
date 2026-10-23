import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/usuario.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? fotoSelecionada;

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> selecionarFoto() async {
    try {
      final imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagem == null) return;

      setState(() {
        fotoSelecionada = imagem;
      });
    } on PlatformException catch (e) {
      mostrarMensagem(
        'Não foi possível abrir as fotos: ${e.message ?? e.code}',
      );
    }
  }

  Future<void> tirarFoto() async {
    try {
      final imagem = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (imagem == null) return;

      setState(() {
        fotoSelecionada = imagem;
      });
    } on PlatformException catch (e) {
      mostrarMensagem(
        'Não foi possível acessar a câmera: ${e.message ?? e.code}',
      );
    } catch (_) {
      mostrarMensagem('Câmera indisponível. Selecione uma foto da galeria.');
    }
  }

  void salvar() {
    if (formKey.currentState!.validate()) {
      final usuario = Usuario(
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        senha: senhaController.text.trim(),
        fotoPath: fotoSelecionada?.path,
      );

      print('Nome: ${usuario.nome}');
      print('E-mail: ${usuario.email}');
      print('Senha: ${usuario.senha}');
      print('Foto: ${usuario.fotoPath ?? "sem foto"}');

      mostrarMensagem('Usuário validado com sucesso!');
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: fotoSelecionada == null
                    ? null
                    : FileImage(File(fotoSelecionada!.path)),
                child: fotoSelecionada == null
                    ? const Icon(Icons.person, size: 70)
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: selecionarFoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Selecionar foto'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: tirarFoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Tirar foto'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!valor.contains('@') || !valor.contains('.')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
