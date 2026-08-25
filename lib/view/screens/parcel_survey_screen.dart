import 'package:flutter/material.dart';
import 'package:garlic/app_router.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ParcelSurveyScreen extends StatefulWidget {
  static const routeName = '/parcelSurvey';
  final ParcelSurveyArgs args;

  const ParcelSurveyScreen({super.key, required this.args});

  @override
  State<ParcelSurveyScreen> createState() => _ParcelSurveyScreenState();
}

class _ParcelSurveyScreenState extends State<ParcelSurveyScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _surveyUuid;

  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _addr = TextEditingController();
  final _farmmapId = TextEditingController();
  final _gpsArea = TextEditingController();
  final _sketchNote = TextEditingController();
  final _excludeArea = TextEditingController();
  final _flagCount = TextEditingController();
  final _plantDate = TextEditingController();
  final _harvestDate = TextEditingController();

  String _year = '2027년산';
  String _crop = '';
  String _variety = '';
  String _yieldZone = '';
  String _rent = '';
  String _irrigation = '';
  String _contract = '';
  String _landUse = '';

  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    _surveyUuid = widget.args.surveyUuid;
    _addr.text = widget.args.address ?? '';
    _farmmapId.text = widget.args.parcelId;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final vm = context.read<GarlicVM>();
    final detail = await vm.getParcelDetail(widget.args.parcelId);
    if (detail != null) {
      _addr.text = '${detail['stdg_addr'] ?? _addr.text}';
      _farmmapId.text = '${detail['uid'] ?? detail['id'] ?? _farmmapId.text}';
      _landUse = '${detail['clsf_nm'] ?? ''}';
      if (detail['survey_uuid'] != null) {
        _surveyUuid = detail['survey_uuid'].toString();
      }
    }

    Map<String, dynamic>? survey;
    if (_surveyUuid != null) {
      survey = await vm.getParcelSurvey(surveyUuid: _surveyUuid);
    } else {
      survey = await vm.getParcelSurvey(parcelId: widget.args.parcelId);
    }

    if (survey != null) {
      _surveyUuid = survey['survey_uuid']?.toString();
      _name.text = '${survey['name'] ?? ''}';
      _contact.text = '${survey['contact'] ?? ''}';
      _addr.text = '${survey['parcel_addr'] ?? _addr.text}';
      _farmmapId.text = '${survey['farmmap_id'] ?? _farmmapId.text}';
      final s = Map<String, dynamic>.from(survey['survey'] as Map? ?? {});
      _year = '${s['year'] ?? _year}';
      _crop = '${s['crop'] ?? ''}';
      _variety = '${s['variety'] ?? ''}';
      _gpsArea.text = '${s['gps_area'] ?? ''}';
      _sketchNote.text = '${s['sketch_note'] ?? ''}';
      _excludeArea.text = '${s['exclude_area'] ?? ''}';
      _yieldZone = '${s['yield_zone'] ?? ''}';
      _flagCount.text = '${s['flag_count'] ?? ''}';
      _plantDate.text = '${s['plant_date'] ?? ''}';
      _harvestDate.text = '${s['harvest_date'] ?? ''}';
      _rent = '${s['rent'] ?? ''}';
      _irrigation = '${s['irrigation'] ?? ''}';
      _contract = '${s['contract'] ?? ''}';
      _landUse = '${s['land_use'] ?? _landUse}';
    }

    if (_surveyUuid != null) {
      final imgs = await vm.getParcelImg(_surveyUuid!);
      _images = imgs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    if (mounted) setState(() => _loading = false);
  }

  Map<String, dynamic> _body() => {
        if (_surveyUuid != null) 'survey_uuid': _surveyUuid,
        'parcel_id': widget.args.parcelId,
        'name': _name.text.trim(),
        'contact': _contact.text.trim(),
        'parcel_addr': _addr.text.trim(),
        'farmmap_id': _farmmapId.text.trim(),
        'write_data': 'Y',
        'survey': {
          'year': _year,
          'crop': _crop,
          'variety': _variety,
          'gps_area': _gpsArea.text.trim(),
          'sketch_note': _sketchNote.text.trim(),
          'exclude_area': _excludeArea.text.trim(),
          'yield_zone': _yieldZone,
          'flag_count': _flagCount.text.trim(),
          'plant_date': _plantDate.text.trim(),
          'harvest_date': _harvestDate.text.trim(),
          'rent': _rent,
          'irrigation': _irrigation,
          'contract': _contract,
          'land_use': _landUse,
        },
      };

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved =
          await context.read<GarlicVM>().saveParcelSurvey(_body());
      _surveyUuid = saved['survey_uuid']?.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필지측정이 저장되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage(String slot) async {
    if (_surveyUuid == null) {
      await _save();
    }
    if (_surveyUuid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 조사를 저장한 뒤 사진을 첨부하세요.')),
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final vm = context.read<GarlicVM>();
    try {
      await vm.uploadParcelImg(
            surveyUuid: _surveyUuid!,
            slot: slot,
            filePath: file.path,
          );
      final imgs = await vm.getParcelImg(_surveyUuid!);
      if (!mounted) return;
      setState(() {
        _images = imgs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$slot 사진이 업로드되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _contact,
      _addr,
      _farmmapId,
      _gpsArea,
      _sketchNote,
      _excludeArea,
      _flagCount,
      _plantDate,
      _harvestDate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController c, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _choice(
    String label,
    List<String> options,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: options
                .map(
                  (o) => ChoiceChip(
                    label: Text(o, style: const TextStyle(fontSize: 12)),
                    selected: value == o,
                    onSelected: (_) => onChanged(o),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('재배면적 실측조사'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('기본 정보',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _field('1. 이름', _name),
                  _field('2. 연락처', _contact, type: TextInputType.phone),
                  _field('3. 필지 주소', _addr),
                  _field('4. 팜맵 ID', _farmmapId),
                  _choice('5. 재배연도', ['2027년산', '2026년산'], _year, (v) {
                    setState(() => _year = v);
                  }),
                  _choice('6. 품목', ['마늘', '양파'], _crop, (v) {
                    setState(() {
                      _crop = v;
                      _variety = '';
                    });
                  }),
                  _choice(
                    '7. 품종',
                    _crop == '양파'
                        ? ['조생종', '중만생종']
                        : ['남도', '대서', '한지'],
                    _variety,
                    (v) => setState(() => _variety = v),
                  ),
                  _field('8. GPS 실측 재배면적', _gpsArea,
                      type: TextInputType.number),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('필지 요도 · 제외면적',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _field('9. 필지 요도 및 특징', _sketchNote),
                  _field('제외면적', _excludeArea),
                  _choice('11. 생산량 조사 구역', ['지정', '해당없음'], _yieldZone, (v) {
                    setState(() => _yieldZone = v);
                  }),
                  _field('12. 깃발 설치 개수', _flagCount,
                      type: TextInputType.number),
                  _field('13. 정식일', _plantDate),
                  _field('14. 수확예정일', _harvestDate),
                  _choice('15. 토지 임차 여부', ['예', '아니오'], _rent, (v) {
                    setState(() => _rent = v);
                  }),
                  _choice('16. 관수 시설 유무', ['예', '아니오'], _irrigation, (v) {
                    setState(() => _irrigation = v);
                  }),
                  _choice(
                    '17. 계약 형태',
                    ['농협계약', '유통상인', '개별 출하', '미정'],
                    _contract,
                    (v) => setState(() => _contract = v),
                  ),
                  _choice('18. 필지 용도', ['논', '밭'], _landUse, (v) {
                    setState(() => _landUse = v);
                  }),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('10. 현장 사진',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final slot in [
                        'overview',
                        'exclude1',
                        'exclude2',
                        'memo',
                      ])
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(slot),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text({
                                'overview': '전경',
                                'exclude1': '제외면적1',
                                'exclude2': '제외면적2',
                                'memo': '특이사항',
                              }[slot] ??
                              slot),
                        ),
                    ],
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ..._images.map(
                      (img) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.image),
                        title: Text('${img['slot']} · ${img['img_name']}'),
                        subtitle: Text('${img['img_path']}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F6B4F),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(_saving ? '저장 중...' : '저장'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
