// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'forms.dart';
import 'market_api.dart';

class ListingDetail extends StatefulWidget {
  const ListingDetail(this.api, this.id, {super.key});
  final MarketApi api;
  final String id;
  @override
  State<ListingDetail> createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {
  late Future<Harvest> data;
  bool changing = false;
  @override
  void initState() {
    super.initState();
    data = widget.api.detail(widget.id);
  }

  void reload() => setState(() => data = widget.api.detail(widget.id));
  Future<void> change(Harvest h, String action) async {
    if (changing) return;
    if (action == 'edit') {
      final ok = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => EditHarvest(widget.api, listing: h)));
      if (mounted && (ok == true || widget.api.session == null)) reload();
      return;
    }
    if (action == 'delete') {
      final yes = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('Delete this harvest?'),
                  content: Text(
                      '“${h.value('title')}” will be permanently removed.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'))
                  ]));
      if (yes != true || !mounted) return;
    }
    setState(() => changing = true);
    try {
      if (action == 'delete') {
        await widget.api.remove(h.id);
        if (mounted) Navigator.pop(context, true);
      } else {
        await widget.api
            .save({'is_available': h.fields['is_available'] != true}, id: h.id);
        if (mounted) reload();
      }
    } on MarketFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        if (widget.api.session == null) reload();
      }
    } finally {
      if (mounted) setState(() => changing = false);
    }
  }

  Future<void> login() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => SignInPage(widget.api)));
    if (ok == true && mounted) reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Harvest details')),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FutureBuilder<Harvest>(
                      future: data,
                      builder: (ctx, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                ErrorText(snap.error.toString()),
                                TextButton(
                                    onPressed: reload,
                                    child: const Text('Retry'))
                              ]);
                        }
                        final h = snap.requireData, contact = h.contact;
                        return ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              if (h.value('image_url').isNotEmpty)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(h.value('image_url'),
                                        height: 160,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink())),
                              Text(
                                  '${titleCase(h.value('category'))} · ${h.value('status_label')}',
                                  style: Theme.of(ctx).textTheme.labelLarge),
                              gap(),
                              Text(h.value('title'),
                                  style:
                                      Theme.of(ctx).textTheme.headlineMedium),
                              gap(),
                              Text(h.value('description')),
                              gap(),
                              ListTile(
                                  leading:
                                      const Icon(Icons.local_offer_outlined),
                                  title: Text(h.value('price_label') == 'Free'
                                      ? 'Free to collect'
                                      : "${h.value('price_label')} per ${h.value('price_unit_label')}"),
                                  subtitle: Text(
                                      "${h.value('quantity_label')} available")),
                              ListTile(
                                  leading: const Icon(Icons.place_outlined),
                                  title: Text(
                                      "${h.value('area')}, ${h.value('city')}"),
                                  subtitle: Text(
                                      "From ${h.value('available_from')}${h.value('available_until').isEmpty ? '' : ' until ${h.value('available_until')}'}")),
                              const Divider(),
                              Text('Meet the grower',
                                  style: Theme.of(ctx).textTheme.titleLarge),
                              ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(h.value('grower_name'))),
                              if (contact == null)
                                OutlinedButton(
                                    onPressed: login,
                                    child: const Text(
                                        'Sign in to see contact details'))
                              else if (['phone', 'email'].every(
                                  (k) => (contact[k] ?? '').toString().isEmpty))
                                const Text('No contact details shared yet.')
                              else
                                SelectableText([
                                  contact['phone'],
                                  contact['email']
                                ]
                                    .whereType<String>()
                                    .where((v) => v.isNotEmpty)
                                    .join('  ·  ')),
                              gap(),
                              OutlinedButton.icon(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              PickupPage(widget.api, h))),
                                  icon: const Icon(Icons.cloud_outlined),
                                  label: const Text('Plan a pickup with BMKG')),
                              if (h.managed && widget.api.session != null) ...[
                                const Divider(),
                                Text('Manage your listing',
                                    style: Theme.of(ctx).textTheme.titleMedium),
                                gap(),
                                Wrap(spacing: 8, runSpacing: 6, children: [
                                  OutlinedButton(
                                      onPressed: changing
                                          ? null
                                          : () => change(h, 'edit'),
                                      child: const Text('Edit')),
                                  OutlinedButton(
                                      onPressed: changing
                                          ? null
                                          : () => change(h, 'pause'),
                                      child: Text(
                                          h.fields['is_available'] == true
                                              ? 'Pause'
                                              : 'Resume')),
                                  TextButton(
                                      onPressed: changing
                                          ? null
                                          : () => change(h, 'delete'),
                                      child: const Text('Delete')),
                                ])
                              ]
                            ]);
                      })))));
}

class PickupPage extends StatefulWidget {
  const PickupPage(this.api, this.h, {super.key});
  final MarketApi api;
  final Harvest h;
  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  late final List<String> dates;
  late String day;
  bool dry = true, cool = false, loading = false;
  String error = '';
  List? slots;
  @override
  void initState() {
    super.initState();
    final now = jakartaDate();
    dates = [for (var i = 0; i < 3; i++) dateText(now.add(Duration(days: i)))];
    day = dates.first;
  }

  void reset(VoidCallback c) => setState(() {
        c();
        slots = null;
        error = '';
      });
  Future<void> check() async {
    setState(() {
      loading = true;
      error = '';
      slots = null;
    });
    try {
      final result = await widget.api.weather(widget.h.id, {
        'date': day,
        'start_time': '08:00',
        'end_time': '18:00',
        'max_rain': dry ? '1' : '100',
        'max_temperature': cool ? '30' : '35'
      });
      if (mounted) setState(() => slots = result['results'] as List);
    } on MarketFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Pickup weather')),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: ListView(padding: const EdgeInsets.all(20), children: [
                Text('Find a pickup window',
                    style: Theme.of(context).textTheme.headlineSmall),
                gap(),
                Text(
                    "BMKG forecast near ${widget.h.value('city')}. Times are 08:00–18:00 WIB (Jakarta). Availability is checked against the listing."),
                gap(),
                AbsorbPointer(
                    absorbing: loading,
                    child: Column(children: [
                      Choice('Pickup date', day, {for (final d in dates) d: d},
                          (v) => reset(() => day = v)),
                      gap(),
                      SwitchListTile(
                          value: dry,
                          title: const Text('Prefer dry weather'),
                          subtitle: const Text('At most 1 mm rain'),
                          onChanged: (v) => reset(() => dry = v)),
                      SwitchListTile(
                          value: cool,
                          title: const Text('Prefer cooler hours'),
                          subtitle:
                              const Text('At most 30 °C instead of 35 °C'),
                          onChanged: (v) => reset(() => cool = v))
                    ])),
                gap(),
                FilledButton(
                    onPressed: loading ? null : check,
                    child: Text(loading ? 'Checking…' : 'Find pickup times')),
                if (error.isNotEmpty) ErrorText(error),
                gap(),
                if (slots?.isEmpty == true)
                  const Text(
                      'No forecast slots match this listing and your preferences.'),
                for (final s in slots ?? [])
                  ListTile(
                      leading: const Icon(Icons.wb_cloudy_outlined),
                      title: Text(
                          "${s['time'].toString().substring(11, 16)} WIB  ·  ${s['temp']} °C"),
                      subtitle:
                          Text("${s['description']} · ${s['rain_mm']} mm")),
              ]))));
}
