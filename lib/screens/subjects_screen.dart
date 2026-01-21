import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/study_models.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  // Dynamic greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else if (hour < 22) {
      return 'Good evening!';
    } else {
      return 'Good night!';
    }
  }

  String _getSubGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Rise and shine! Let\'s crush it today 🚀';
    } else if (hour < 17) {
      return 'Keep up the momentum! You\'ve got this 💪';
    } else if (hour < 22) {
      return 'Almost done for the day! Great work 🌙';
    } else {
      return 'Time to recharge. Sweet dreams! 😴';
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final subjects = studyProvider.subjects;

    return Scaffold(
      appBar: appbar(),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                // View subject details/tasks
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: subject.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(subject.icon, color: subject.color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subject.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${studyProvider.tasks.where((t) => t.subjectId == subject.id).length} Tasks',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Subject'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Subject Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false).addSubject(
                  Subject(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    color: Colors.blue,
                    icon: Icons.folder,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget appbar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Dynamic Greeting
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getSubGreeting(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Right side: Profile picture
                GestureDetector(
                  onTap: () {
                    // Handle profile tap
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color.fromARGB(255, 224, 224, 224),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/images/profile_default.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
      ),
    );
  }
}
