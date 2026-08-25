import 'package:flutter/material.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:provider/provider.dart';

class InterviewFormScreen extends StatefulWidget {
  static const routeName = '/interviewForm';
  final String? surveyUuid;

  const InterviewFormScreen({super.key, this.surveyUuid});

  @override
  State<InterviewFormScreen> createState() => _InterviewFormScreenState();
}

class _InterviewFormScreenState extends State<InterviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  String? _surveyUuid;

  // respondent
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _mobile = TextEditingController();
  final _bankAccount = TextEditingController();
  final _bankName = TextEditingController();
  final _farmCareer = TextEditingController();
  final _garlicCareer = TextEditingController();
  final _onionCareer = TextEditingController();
  String _monthlyReport = '';

  // garlic areas
  final Map<String, TextEditingController> _gArea = {};
  final Map<String, String> _gCrop = {};
  String _gGap = '';
  final _gReason = TextEditingController();
  final Map<String, TextEditingController> _gInfo = {};
  final _gMemo = TextEditingController();

  // onion
  final Map<String, TextEditingController> _oArea = {};
  final Map<String, String> _oCrop = {};
  String _oGap = '';
  final _oReason = TextEditingController();
  final Map<String, TextEditingController> _oInfo = {};
  final _oMemo = TextEditingController();

  static const _likertCrop = ['매우 좋음', '좋음', '비슷', '나쁨', '매우 나쁨'];
  static const _likertGap = ['매우 많음', '많음', '비슷', '적음', '매우 적음'];

  TextEditingController _c(Map<String, TextEditingController> m, String k) {
    return m.putIfAbsent(k, () => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    _surveyUuid = widget.surveyUuid;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_surveyUuid != null) {
      final data = await context.read<GarlicVM>().getInterview(_surveyUuid!);
      if (data != null) _apply(data);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _apply(Map<String, dynamic> data) {
    _surveyUuid = data['survey_uuid']?.toString();
    final r = Map<String, dynamic>.from(data['respondent'] as Map? ?? {});
    final g = Map<String, dynamic>.from(data['garlic'] as Map? ?? {});
    final o = Map<String, dynamic>.from(data['onion'] as Map? ?? {});

    _name.text = '${r['name'] ?? ''}';
    _phone.text = '${r['phone'] ?? ''}';
    _address.text = '${r['address'] ?? ''}';
    _mobile.text = '${r['mobile'] ?? ''}';
    _bankAccount.text = '${r['bank_account'] ?? ''}';
    _bankName.text = '${r['bank_name'] ?? ''}';
    _farmCareer.text = '${r['farm_career'] ?? ''}';
    _garlicCareer.text = '${r['garlic_career'] ?? ''}';
    _onionCareer.text = '${r['onion_career'] ?? ''}';
    _monthlyReport = '${r['monthly_report'] ?? ''}';

    void fillAreas(Map src, Map<String, TextEditingController> dest, List keys) {
      for (final k in keys) {
        _c(dest, k).text = '${src[k] ?? ''}';
      }
    }

    fillAreas(g, _gArea, [
      'daeseo_2027',
      'daeseo_2026',
      'namdo_2027',
      'namdo_2026',
      'hanji_2027',
      'hanji_2026',
      'total_2027',
      'total_2026',
    ]);
    _gCrop['daeseo'] = '${g['crop_daeseo'] ?? ''}';
    _gCrop['namdo'] = '${g['crop_namdo'] ?? ''}';
    _gCrop['hanji'] = '${g['crop_hanji'] ?? ''}';
    _gGap = '${g['gap_rate'] ?? ''}';
    _gReason.text = '${g['early_reason'] ?? ''}';
    fillAreas(g, _gInfo, [
      'daeseo_parcels',
      'daeseo_seed',
      'daeseo_method',
      'daeseo_plants',
      'namdo_parcels',
      'namdo_seed',
      'namdo_method',
      'namdo_plants',
      'hanji_parcels',
      'hanji_seed',
      'hanji_method',
      'hanji_plants',
    ]);
    _gMemo.text = '${g['memo'] ?? ''}';

    fillAreas(o, _oArea, [
      'early_2027',
      'early_2026',
      'mid_2027',
      'mid_2026',
    ]);
    _oCrop['early'] = '${o['crop_early'] ?? ''}';
    _oCrop['mid'] = '${o['crop_mid'] ?? ''}';
    _oGap = '${o['gap_rate'] ?? ''}';
    _oReason.text = '${o['early_reason'] ?? ''}';
    fillAreas(o, _oInfo, [
      'early_parcels',
      'early_seed',
      'early_method',
      'early_plants',
      'mid_parcels',
      'mid_seed',
      'mid_method',
      'mid_plants',
    ]);
    _oMemo.text = '${o['memo'] ?? ''}';
  }

  Map<String, dynamic> _buildBody() {
    Map<String, String> vals(Map<String, TextEditingController> m) =>
        m.map((k, v) => MapEntry(k, v.text.trim()));

    return {
      if (_surveyUuid != null) 'survey_uuid': _surveyUuid,
      'farmer_key': _name.text.trim(),
      'write_data': 'Y',
      'respondent': {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'mobile': _mobile.text.trim(),
        'bank_account': _bankAccount.text.trim(),
        'bank_name': _bankName.text.trim(),
        'monthly_report': _monthlyReport,
        'farm_career': _farmCareer.text.trim(),
        'garlic_career': _garlicCareer.text.trim(),
        'onion_career': _onionCareer.text.trim(),
      },
      'garlic': {
        ...vals(_gArea),
        'crop_daeseo': _gCrop['daeseo'] ?? '',
        'crop_namdo': _gCrop['namdo'] ?? '',
        'crop_hanji': _gCrop['hanji'] ?? '',
        'gap_rate': _gGap,
        'early_reason': _gReason.text.trim(),
        ...vals(_gInfo),
        'memo': _gMemo.text.trim(),
      },
      'onion': {
        ...vals(_oArea),
        'crop_early': _oCrop['early'] ?? '',
        'crop_mid': _oCrop['mid'] ?? '',
        'gap_rate': _oGap,
        'early_reason': _oReason.text.trim(),
        ...vals(_oInfo),
        'memo': _oMemo.text.trim(),
      },
    };
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await context.read<GarlicVM>().saveInterview(_buildBody());
      _surveyUuid = saved['survey_uuid']?.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('면접조사가 저장되었습니다.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _address,
      _mobile,
      _bankAccount,
      _bankName,
      _farmCareer,
      _garlicCareer,
      _onionCareer,
      _gReason,
      _gMemo,
      _oReason,
      _oMemo,
      ..._gArea.values,
      ..._gInfo.values,
      ..._oArea.values,
      ..._oInfo.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
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
        title: Text(_surveyUuid == null ? '면접조사 신규' : '면접조사 작성'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _section('응답자 정보', [
              _field('이름', _name),
              _field('전화번호', _phone, type: TextInputType.phone),
              _field('휴대전화', _mobile, type: TextInputType.phone),
              _field('주소', _address),
              _field('은행명', _bankName),
              _field('계좌번호', _bankAccount),
              _choice('월보수신여부', ['예', '아니오'], _monthlyReport, (v) {
                setState(() => _monthlyReport = v);
              }),
              _field('영농경력(년)', _farmCareer, type: TextInputType.number),
              _field('마늘 재배경력(년)', _garlicCareer, type: TextInputType.number),
              _field('양파 재배경력(년)', _onionCareer, type: TextInputType.number),
            ]),
            _section('마늘 · 재배면적(평)', [
              _field('난지형대서 2027', _c(_gArea, 'daeseo_2027'), type: TextInputType.number),
              _field('난지형대서 2026', _c(_gArea, 'daeseo_2026'), type: TextInputType.number),
              _field('난지형남도 2027', _c(_gArea, 'namdo_2027'), type: TextInputType.number),
              _field('난지형남도 2026', _c(_gArea, 'namdo_2026'), type: TextInputType.number),
              _field('한지형마늘 2027', _c(_gArea, 'hanji_2027'), type: TextInputType.number),
              _field('한지형마늘 2026', _c(_gArea, 'hanji_2026'), type: TextInputType.number),
              _field('합계 2027', _c(_gArea, 'total_2027'), type: TextInputType.number),
              _field('합계 2026', _c(_gArea, 'total_2026'), type: TextInputType.number),
            ]),
            _section('마늘 · 작황/결주/재배정보', [
              _choice('작황 대서', _likertCrop, _gCrop['daeseo'] ?? '', (v) {
                setState(() => _gCrop['daeseo'] = v);
              }),
              _choice('작황 남도', _likertCrop, _gCrop['namdo'] ?? '', (v) {
                setState(() => _gCrop['namdo'] = v);
              }),
              _choice('작황 한지', _likertCrop, _gCrop['hanji'] ?? '', (v) {
                setState(() => _gCrop['hanji'] = v);
              }),
              _choice('결주율', _likertGap, _gGap, (v) {
                setState(() => _gGap = v);
              }),
              _field('초기 생육 상이 사유', _gReason),
              _field('대서 필지개수', _c(_gInfo, 'daeseo_parcels')),
              _field('대서 종자명', _c(_gInfo, 'daeseo_seed')),
              _field('대서 정식방법(기계/인력)', _c(_gInfo, 'daeseo_method')),
              _field('대서 평균주수(평)', _c(_gInfo, 'daeseo_plants')),
              _field('남도 필지개수', _c(_gInfo, 'namdo_parcels')),
              _field('남도 종자명', _c(_gInfo, 'namdo_seed')),
              _field('남도 정식방법', _c(_gInfo, 'namdo_method')),
              _field('남도 평균주수', _c(_gInfo, 'namdo_plants')),
              _field('한지 필지개수', _c(_gInfo, 'hanji_parcels')),
              _field('한지 종자명', _c(_gInfo, 'hanji_seed')),
              _field('한지 정식방법', _c(_gInfo, 'hanji_method')),
              _field('한지 평균주수', _c(_gInfo, 'hanji_plants')),
              _field('마늘 특이사항', _gMemo),
            ]),
            _section('양파 · 재배면적(평)', [
              _field('조생종 2027', _c(_oArea, 'early_2027'), type: TextInputType.number),
              _field('조생종 2026', _c(_oArea, 'early_2026'), type: TextInputType.number),
              _field('중만생종 2027', _c(_oArea, 'mid_2027'), type: TextInputType.number),
              _field('중만생종 2026', _c(_oArea, 'mid_2026'), type: TextInputType.number),
            ]),
            _section('양파 · 작황/결주/재배정보', [
              _choice('작황 조생', _likertCrop, _oCrop['early'] ?? '', (v) {
                setState(() => _oCrop['early'] = v);
              }),
              _choice('작황 중만생', _likertCrop, _oCrop['mid'] ?? '', (v) {
                setState(() => _oCrop['mid'] = v);
              }),
              _choice('결주율', _likertGap, _oGap, (v) {
                setState(() => _oGap = v);
              }),
              _field('초기 생육 상이 사유', _oReason),
              _field('조생 필지개수', _c(_oInfo, 'early_parcels')),
              _field('조생 종자명', _c(_oInfo, 'early_seed')),
              _field('조생 정식방법', _c(_oInfo, 'early_method')),
              _field('조생 평균주수', _c(_oInfo, 'early_plants')),
              _field('중만생 필지개수', _c(_oInfo, 'mid_parcels')),
              _field('중만생 종자명', _c(_oInfo, 'mid_seed')),
              _field('중만생 정식방법', _c(_oInfo, 'mid_method')),
              _field('중만생 평균주수', _c(_oInfo, 'mid_plants')),
              _field('양파 특이사항', _oMemo),
            ]),
            const SizedBox(height: 12),
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
      ),
    );
  }
}
