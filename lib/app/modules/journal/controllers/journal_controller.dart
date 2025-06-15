import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';

class JournalController extends GetxController {
  final box = GetStorage();
  var notes = <Note>[].obs;
  final uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void loadNotes() {
    final List<dynamic>? notesData = box.read<List<dynamic>>('notes');
    if (notesData != null) {
      notes.value = notesData.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void addNote(String title, String content) {
    final newNote = Note(
      id: uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    notes.insert(0, newNote);
    _saveNotesToStorage();
  }

  void updateNote(String id, String newTitle, String newContent) {
    final index = notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      var updatedNote = notes[index];
      updatedNote.title = newTitle;
      updatedNote.content = newContent;
      notes[index] = updatedNote;
      _saveNotesToStorage();
    }
  }

  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    _saveNotesToStorage();
  }

  void _saveNotesToStorage() {
    List<Map<String, dynamic>> notesData = notes.map((note) => note.toJson()).toList();
    box.write('notes', notesData);
  }
}
