import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/note_card.dart';
import '../services/notes_service.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
  }

@override
Widget build(BuildContext context) {
  final provider = Provider.of<NotesProvider>(context, listen: false);
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue.shade700,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Your Notes',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => FirebaseAuth.instance.signOut(),
          tooltip: 'Logout',
        ),
      ],
    ),
    body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<List<Note>>(
        stream: provider.notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'Nothing here yet—tap ➕ to add a note.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, i) => NoteCard(
              note: notes[i],
              onEdit: () => _showNoteDialog(note: notes[i]),
              onDelete: () => provider.deleteNote(context, notes[i].id),
            ),
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showNoteDialog(),
      tooltip: 'Add Note',
      child: Icon(Icons.add),
    ),
  );
}

  void _showNoteDialog({Note? note}) {
    final controller = TextEditingController(text: note?.content ?? '');
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(note == null ? 'Add Note' : 'Edit Note'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter note...'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final provider = Provider.of<NotesProvider>(
                    context,
                    listen: false,
                  );
                  if (note == null) {
                    provider.addNote(context, text);
                  } else {
                    provider.updateNote(context, note.id, text);
                  }
                  Navigator.pop(context);
                },
                child: Text(note == null ? 'Add' : 'Save'),
              ),
            ],
          ),
    );
  }
}
