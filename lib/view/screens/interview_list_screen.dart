import 'package:flutter/material.dart';
import 'package:garlic/view/screens/interview_form_screen.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:provider/provider.dart';

class InterviewListScreen extends StatefulWidget {
  static const routeName = '/interviewList';
  const InterviewListScreen({super.key});

  @override
  State<InterviewListScreen> createState() => _InterviewListScreenState();
}

class _InterviewListScreenState extends State<InterviewListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GarlicVM>().loadInterviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GarlicVM>();
    return Scaffold(
      appBar: AppBar(title: const Text('면접조사')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, InterviewFormScreen.routeName);
          if (mounted) context.read<GarlicVM>().loadInterviews();
        },
        backgroundColor: const Color(0xFF2F6B4F),
        icon: const Icon(Icons.add),
        label: const Text('새 면접'),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.interviews.isEmpty
              ? const Center(child: Text('등록된 면접조사가 없습니다.\n새 면접을 추가하세요.'))
              : RefreshIndicator(
                  onRefresh: () => context.read<GarlicVM>().loadInterviews(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.interviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final row = vm.interviews[i];
                      final name = (row['name'] ?? '').toString();
                      final phone = (row['phone'] ?? '').toString();
                      final written = row['write_data'] == 'Y';
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        title: Text(name.isEmpty ? '(이름 없음)' : name),
                        subtitle: Text(
                          [
                            if (phone.isNotEmpty) phone,
                            written ? '작성완료' : '작성중',
                          ].join(' · '),
                        ),
                        trailing: Icon(
                          written ? Icons.check_circle : Icons.edit_note,
                          color: written
                              ? const Color(0xFF2F6B4F)
                              : Colors.orange,
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            InterviewFormScreen.routeName,
                            arguments: row['survey_uuid']?.toString(),
                          );
                          if (mounted) {
                            context.read<GarlicVM>().loadInterviews();
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
