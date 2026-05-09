/// lib/providers/resource_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Resource {
  final String id;
  final String title;
  final String author;
  final String category;
  final int availableCopies;
  final String abstractText;
  final String shelfLocation;
  final String publicationDate;
  final String isbn;
  final String subject;

  Resource({
    required this.id, required this.title, required this.author,
    required this.category, required this.availableCopies,
    required this.abstractText, required this.shelfLocation,
    required this.publicationDate, required this.isbn, required this.subject,
  });

  bool get isAvailable => availableCopies > 0;
}

class ResourceNotifier extends Notifier<List<Resource>> {
  @override
  List<Resource> build() {
    return [
      Resource(
        id: '1', title: 'Clean Code', author: 'Robert C. Martin', category: 'book',
        availableCopies: 3, abstractText: 'Even bad code can function. But if code isn\'t clean, it can bring a development organization to its knees.',
        shelfLocation: 'A2-CS', publicationDate: '2008', isbn: '978-0132350884', subject: 'Software Engineering',
      ),
      Resource(
        id: '2', title: 'Deep Learning', author: 'Ian Goodfellow et al.', category: 'book',
        availableCopies: 0, abstractText: 'An introduction to a broad range of topics in deep learning, covering mathematical and conceptual background.',
        shelfLocation: 'B1-AI', publicationDate: '2016', isbn: '978-0262035613', subject: 'Artificial Intelligence',
      ),
    ];
  }

  void reserve(String id) {
    // Optimistic UI update: could track reservations elsewhere, but for demo just decrease if there were copies or log it.
    // In reality, reserving doesn't change availableCopies immediately until fulfilled, but we just trigger state to reflect.
    state = [...state]; 
  }
}

final resourceProvider = NotifierProvider<ResourceNotifier, List<Resource>>(ResourceNotifier.new);

// For passing the selected resource to the detail screen
final selectedResourceIdProvider = StateProvider<String?>((ref) => null);
