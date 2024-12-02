import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_application/screens/quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _numQuestions = 10;
  String? _selectedCategory;
  String _difficulty = 'easy';
  String _type = 'multiple';
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('https://opentdb.com/api_category.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data['trivia_categories'] ?? [];
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(e);
      // Handle error appropriately (e.g., show a snackbar or dialog in production)
    }
  }

  void _startQuiz() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          numQuestions: _numQuestions,
          category: _selectedCategory!,
          difficulty: _difficulty,
          type: _type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Questions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<int>(
              value: _numQuestions,
              items: [5, 10, 15]
                  .map((e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text('$e'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _numQuestions = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Category:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              hint: const Text('Choose a category'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Difficulty:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              value: _difficulty,
              items: ['easy', 'medium', 'hard']
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Type:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              value: _type,
              items: ['multiple', 'boolean']
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e == 'boolean' ? 'True/False' : 'Multiple Choice'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _startQuiz,
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
