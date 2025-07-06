import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .where((doc) => doc.data()['userId'] == currentUserId)
                  .map((d) => Note.fromDoc(d))
                  .toList(),
        );
  }

  Future<void> addNote(String content) async {
    await _notesRef.add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> updateNote(String id, String content) async {
    await _notesRef.doc(id).update({'content': content});
  }

  Future<void> deleteNote(String id) async {
    await _notesRef.doc(id).delete();
  }
}
