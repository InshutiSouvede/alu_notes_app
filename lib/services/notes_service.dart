import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String content;

  Note({required this.id, required this.content});

  factory Note.fromDoc(DocumentSnapshot doc) =>
      Note(id: doc.id, content: doc['content'] ?? '');
}

class NotesService {
  final _notesRef = FirebaseFirestore.instance.collection('notes');

  Stream<List<Note>> notesStream() {
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Note.fromDoc(d)).toList());
  }

  Future<void> addNote(String content) async {
    await _notesRef.add({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String id, String content) async {
    await _notesRef.doc(id).update({'content': content});
  }

  Future<void> deleteNote(String id) async {
    await _notesRef.doc(id).delete();
  }
}
