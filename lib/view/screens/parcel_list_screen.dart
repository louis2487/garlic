import 'package:flutter/material.dart';
import 'package:garlic/app_router.dart';
import 'package:garlic/view/screens/parcel_survey_screen.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:provider/provider.dart';

class ParcelListScreen extends StatefulWidget {
  static const routeName = '/parcelList';
  const ParcelListScreen({super.key});

  @override
  State<ParcelListScreen> createState() => _ParcelListScreenState();
}

class _ParcelListScreenState extends State<ParcelListScreen> {
  final _q = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GarlicVM>().loadParcels();
    });
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GarlicVM>();
    return Scaffold(
      appBar: AppBar(title: const Text('필지측정 · 목록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _q,
              decoration: InputDecoration(
                hintText: '주소·PNU·ID 검색',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _q.clear();
                    context.read<GarlicVM>().loadParcels();
                  },
                ),
              ),
              onSubmitted: (v) => context.read<GarlicVM>().loadParcels(q: v),
            ),
          ),
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<GarlicVM>().loadParcels(q: _q.text),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: vm.parcels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = vm.parcels[i];
                        final written = p['write_data'] == 'Y';
                        final area = p['area'];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          title: Text('${p['stdg_addr'] ?? ''}'),
                          subtitle: Text(
                            '${p['clsf_nm'] ?? ''} · PNU ${p['pnu'] ?? ''}\n'
                            '면적 ${area is num ? area.toStringAsFixed(1) : area} ㎡',
                          ),
                          isThreeLine: true,
                          trailing: Icon(
                            written ? Icons.check_circle : Icons.edit_note,
                            color: written
                                ? const Color(0xFF2F6B4F)
                                : Colors.orange,
                          ),
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              ParcelSurveyScreen.routeName,
                              arguments: ParcelSurveyArgs(
                                parcelId: '${p['id']}',
                                surveyUuid: p['survey_uuid']?.toString(),
                                address: '${p['stdg_addr'] ?? ''}',
                              ),
                            );
                            if (mounted) {
                              context.read<GarlicVM>().loadParcels(q: _q.text);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
