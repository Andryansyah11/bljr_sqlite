import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

// **Membaca semua data dari database**
  void _refreshItems() async {
    print("Memuat ulang data");
    final data = await SQLHelper.getItems();
    print("Data Yang Diambil: $data");
    setState(() {
      _items = data;
      _isLoading = false;
    });
    print("📝 Jumlah item sekarang: ${_items.length}");
  }

// **Menampilkan dialog untuk menambah data**
  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
      _typeController.text = existingItem['type'];
      _imagePath = existingItem['image'];
    }
    showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  backgroundColor: Colors.white,
  builder: (_) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Add or Edit Item",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            prefixIcon: const Icon(Icons.description, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _typeController,
          decoration: InputDecoration(
            labelText: 'Type',
            prefixIcon: const Icon(Icons.category, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imagePath!), height: 80, width: 80, fit: BoxFit.cover),
                )
              : const Text("No Image Selected", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("Pick Image"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (id == null) {
                await SQLHelper.createItem(
                  _titleController.text,
                  _descriptionController.text,
                  _typeController.text,
                  _imagePath!,
                );
              } else {
                await SQLHelper.updateItem(
                  id,
                  _titleController.text,
                  _descriptionController.text,
                  _typeController.text,
                  _imagePath!,
                );
              }
              _titleController.clear();
              _descriptionController.clear();
              _typeController.clear();
              Navigator.of(context).pop();
              _refreshItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: id == null ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
            ),
            child: Text(id == null ? 'Add Item' : 'Update Item', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    ),
  ),
);

  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

// **Menghapus data berdasarkan ID**
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD Example',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                color: Colors.blue.shade50, // Warna latar belakang kartu
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    _items[index]['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_items[index]['description']),
                        const SizedBox(height: 4),
                        Text(
                          _items[index]['type'],
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  leading: _items[index]['image'] != null &&
                          _items[index]['image'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_items[index]['image']),
                              width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showForm(_items[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(_items[index]['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

