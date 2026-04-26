// ─────────────────────────────────────────────
//  edit_panel.dart
//  Bottom sheet shown in edit mode for size /
//  opacity / key-binding of selected element
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';

class EditPanel extends StatelessWidget {
  const EditPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HudProvider>();
    final id   = prov.selectedId;
    final el   = id != null ? prov.config.elements[id] : null;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOut,
      offset: el != null ? Offset.zero : const Offset(0, 1),
      child: el == null
          ? const SizedBox.shrink()
          : Container(
              height: 178,
              decoration: const BoxDecoration(
                color: VColors.panelBg,
                border: Border(top: BorderSide(color: VColors.red, width: 1.5)),
              ),
              child: _Editor(id: id!, el: el, prov: prov),
            ),
    );
  }
}

class _Editor extends StatefulWidget {
  final String id;
  final dynamic el;
  final HudProvider prov;
  const _Editor({required this.id, required this.el, required this.prov});

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late TextEditingController _keyCtrl;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.el.keyMapping as String);
  }

  @override
  void didUpdateWidget(_Editor old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _keyCtrl.text = widget.el.keyMapping as String;
  }

  @override
  void dispose() { _keyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final el   = widget.el;
    final prov = widget.prov;
    final id   = widget.id;

    return Column(children: [
      // ── Header ──────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Text('EDITING: ${(el.label as String).toUpperCase()}',
              style: VTheme.label(size: 11, color: VColors.red)),
          const Spacer(),
          GestureDetector(
            onTap: () => prov.toggleVisibility(id),
            child: Icon(
              (el.visible as bool) ? Icons.visibility : Icons.visibility_off,
              color: VColors.offWhite, size: 18,
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => prov.selectElement(null),
            child: const Icon(Icons.close, color: VColors.white, size: 18),
          ),
        ]),
      ),
      // ── Size / Opacity sliders ───────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          Expanded(child: _Slider(
            label: 'SIZE',
            value: el.size as double,
            min: 0.3, max: 2.5,
            accent: VColors.red,
            onChanged: (v) => prov.updateSize(id, v),
            display: '${(el.size as double).toStringAsFixed(1)}×',
          )),
          const SizedBox(width: 16),
          Expanded(child: _Slider(
            label: 'OPACITY',
            value: el.opacity as double,
            min: 0.1, max: 1.0,
            accent: VColors.teal,
            onChanged: (v) => prov.updateOpacity(id, v),
            display: '${((el.opacity as double) * 100).round()}%',
          )),
        ]),
      ),
      // ── Key mapping ──────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          Text('KEY  ', style: VTheme.label(size: 9, color: VColors.offWhite)),
          Expanded(child: _KeyField(ctrl: _keyCtrl, onChanged: (v) => prov.updateKeyMapping(id, v))),
          const SizedBox(width: 8),
          for (final k in ['Space', 'Ctrl', 'Shift', 'F', 'R'])
            _Chip(label: k, onTap: () {
              _keyCtrl.text = k;
              prov.updateKeyMapping(id, k);
            }),
        ]),
      ),
      // ── Reset ────────────────────────────────
      Padding(
        padding: const EdgeInsets.only(right: 16, top: 4),
        child: Align(alignment: Alignment.centerRight, child: GestureDetector(
          onTap: prov.resetToDefault,
          child: Text('RESET ALL', style: VTheme.label(size: 9, color: VColors.red)),
        )),
      ),
    ]);
  }
}

// ── Helpers ───────────────────────────────────
class _Slider extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final Color accent;
  final ValueChanged<double> onChanged;
  const _Slider({required this.label, required this.display, required this.value,
      required this.min, required this.max, required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(label, style: VTheme.label(size: 8.5, color: VColors.offWhite)),
      const Spacer(),
      Text(display, style: VTheme.label(size: 8.5, color: VColors.white)),
    ]),
    SliderTheme(
      data: VTheme.sliderTheme(context, accent: accent),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    ),
  ]);
}

class _KeyField extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _KeyField({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    style: VTheme.label(size: 11, color: VColors.white),
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      filled: true, fillColor: VColors.darkBg2,
      border:       OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: VColors.border)),
      enabledBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: VColors.border)),
      focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: VColors.red)),
      hintText: 'e.g. Space',
      hintStyle: VTheme.label(size: 9, color: VColors.offWhite.withOpacity(0.35)),
    ),
    onChanged: onChanged,
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(color: VColors.darkBg2, borderRadius: BorderRadius.circular(4),
          border: Border.all(color: VColors.border)),
      child: Text(label, style: VTheme.label(size: 8, color: VColors.offWhite)),
    ),
  );
}
