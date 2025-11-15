import 'package:flutter/material.dart';
import 'package:prac5/features/habits/models/habit.dart';
import 'package:prac5/shared/constants.dart';

class HabitFormScreen extends StatefulWidget {
  final Function(Habit) onSave;
  final Habit? habit;

  const HabitFormScreen({super.key, required this.onSave, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _selectedGenre = AppConstants.genres.first;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    if (h != null) {
      _titleController.text = h.title;
      _authorController.text = h.author;
      _selectedGenre = h.genre;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final base =
        widget.habit ??
        Habit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          author: '',
          genre: _selectedGenre,
          dateAdded: DateTime.now(),
        );
    final saved = base.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _selectedGenre,
    );
    widget.onSave(saved);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать привычку' : 'Добавить привычку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите название' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Контекст/триггер *',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите контекст' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                items: AppConstants.genres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedGenre = v ?? _selectedGenre),
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Сохранить' : 'Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
