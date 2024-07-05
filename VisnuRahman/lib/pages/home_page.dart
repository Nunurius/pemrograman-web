import 'package:flutter/material.dart';
import 'package:visnurahman/helpers/university_helper.dart';
import 'package:visnurahman/models/university.dart';
import 'package:visnurahman/pages/result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchNameController = TextEditingController();
  final UniversityHelper universityHelper = UniversityHelper.instance;
  late Future<List<University>> _universities;

  @override
  void initState() {
    super.initState();
    _fetchDatabase();
  }

  void _fetchDatabase() {
    setState(() {
      _universities = universityHelper.getAll();
    });
  }

  void openDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Text('Cari universitas', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  )),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'ex. Indonesia.',
                    ),
                    controller: searchNameController,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      
                     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ResultPage(name: searchNameController.text);
                      }));
                      
                      if (result == 'success') {
                        searchNameController.clear();
                        _fetchDatabase();
                      } 
                    }, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.teal),
                      foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                    ),
                    child: const Text('Cari Universitas')
                  )
                ],
              ),
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Universitas', style: TextStyle(
          fontSize: 18,
        )),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<University>>(
        future: _universities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text('Data universitas tidak tersedia, \nSilahkan cari dan simpan data baru dari API!', style: TextStyle(
                color: Colors.red,
              )),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  University university = snapshot.data![index];
                  return _cardUniversity(university);
                }
              ),
            );
          }
        }
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          backgroundColor: Colors.teal,
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }

  Widget _cardUniversity(University university) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(university.name),
          subtitle: Text('${university.url}, ${university.country}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {
                universityHelper.deleteData(university.id);
                _fetchDatabase();
              }, icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}