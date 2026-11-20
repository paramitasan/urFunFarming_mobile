import 'package:material_ui/material_ui.dart';
import 'market_api.dart';

class SignInPage extends StatefulWidget {
  const SignInPage(this.api, {super.key});
  final MarketApi api;
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String user = '', pass = '', error = '';
  bool busy = false;
  Future<void> submit() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await widget.api.login(user, pass);
      if (mounted) Navigator.pop(context, true);
    } on MarketFailure catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ListView(padding: const EdgeInsets.all(24), children: [
                    Text('Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                            'Use your urFunFarming account to contact a grower or manage your harvests.')),
                    TextField(
                        autofillHints: const [AutofillHints.username],
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        onChanged: (v) => user = v),
                    const SizedBox(height: 12),
                    TextField(
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        onChanged: (v) => pass = v,
                        onSubmitted: (_) => submit()),
                    if (error.isNotEmpty) ErrorText(error),
                    const SizedBox(height: 18),
                    FilledButton(
                        onPressed: busy ? null : submit,
                        child: Text(busy ? 'Signing in…' : 'Sign in')),
                  ])))));
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Semantics(
          liveRegion: true,
          child: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.error))));
}

class Choice extends StatelessWidget {
  const Choice(this.label, this.value, this.options, this.changed, {super.key});
  final String label, value;
  final Map<String, String> options;
  final ValueChanged<String> changed;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options.entries
          .map((v) => DropdownMenuItem(value: v.key, child: Text(v.value)))
          .toList(),
      onChanged: (v) {
        if (v != null) changed(v);
      });
}

String titleCase(String v) =>
    v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
Map<String, String> choices(List<String> v) =>
    {for (final x in v) x: titleCase(x)};
Widget gap() => const SizedBox(height: 12);

class EditHarvest extends StatefulWidget {
  const EditHarvest(this.api, {this.listing, super.key});
  final MarketApi api;
  final Harvest? listing;
  @override
  State<EditHarvest> createState() => _EditHarvestState();
}

class _EditHarvestState extends State<EditHarvest> {
  final form = GlobalKey<FormState>();
  late Json fields;
  bool busy = false;
  String error = '';
  @override
  void initState() {
    super.initState();
    final existing = widget.listing?.fields ?? {};
    fields = {
      for (final k in [
        'title',
        'description',
        'area',
        'image_url',
        'available_until'
      ])
        k: existing[k] ?? '',
      for (final e in {
        'category': 'vegetables',
        'city': 'Depok',
        'unit': 'kg',
        'quantity': '1',
        'price': '0',
        'price_quantity': '1',
        'available_from': dateText(jakartaDate()),
        'is_available': true
      }.entries)
        e.key: existing[e.key] ?? e.value
    };
  }

  Widget field(String key, String label,
          {bool optional = false,
          bool decimal = false,
          int lines = 1,
          String? hint}) =>
      TextFormField(
          initialValue: fields[key].toString(),
          maxLines: lines,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          decoration: InputDecoration(labelText: label, helperText: hint),
          onChanged: (v) => fields[key] = v.trim(),
          validator: (v) {
            final text = (v ?? '').trim();
            if (text.isEmpty) return optional ? null : 'Please enter $label.';
            if (decimal &&
                (num.tryParse(text) == null || num.parse(text) < 0)) {
              return 'Enter a positive number or zero.';
            }
            if (key == 'price_quantity' && num.tryParse(text) == 0) {
              return 'Enter more than zero.';
            }
            if (key == 'quantity' &&
                fields['is_available'] == true &&
                num.tryParse(text) == 0) {
              return 'Pause a listing with no stock.';
            }
            if (key.startsWith('available_')) {
              final d = DateTime.tryParse(text);
              if (d == null || dateText(d) != text) return 'Use YYYY-MM-DD.';
              if (key == 'available_until' &&
                  text.compareTo(fields['available_from']) < 0) {
                return 'End date must follow the start date.';
              }
            }
            return null;
          });
  Widget pick(String key, String label, List<String> options) => Choice(label,
      fields[key], choices(options), (v) => setState(() => fields[key] = v));
  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = '';
    });
    final body = {
      ...fields,
      'available_until':
          fields['available_until'] == '' ? null : fields['available_until']
    };
    try {
      await widget.api.save(body, id: widget.listing?.id);
      if (mounted) Navigator.pop(context, true);
    } on MarketFailure catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
          error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title:
              Text(widget.listing == null ? 'Post a harvest' : 'Edit harvest')),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                      key: form,
                      child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            field('title', 'Title'),
                            gap(),
                            field('description', 'Description', lines: 3),
                            gap(),
                            pick('category', 'Produce', categories),
                            gap(),
                            field('quantity', 'Available quantity',
                                decimal: true),
                            gap(),
                            pick('unit', 'Unit', units),
                            gap(),
                            field('price', 'Price in rupiah',
                                decimal: true,
                                hint: 'Enter 0 to share for free.'),
                            gap(),
                            field('price_quantity', 'Quantity per price',
                                decimal: true),
                            gap(),
                            field('area', 'Collection area',
                                hint:
                                    'A neighbourhood or public meeting place.'),
                            gap(),
                            pick('city', 'City', cities),
                            gap(),
                            field('available_from', 'Available from',
                                hint: 'YYYY-MM-DD · Jakarta time'),
                            gap(),
                            field('available_until', 'Available until',
                                optional: true, hint: 'Optional · YYYY-MM-DD'),
                            gap(),
                            field('image_url', 'Photo URL', optional: true),
                            gap(),
                            SwitchListTile(
                                value: fields['is_available'],
                                title: const Text('Available to collect'),
                                onChanged: (v) =>
                                    setState(() => fields['is_available'] = v)),
                            if (error.isNotEmpty) ErrorText(error),
                            gap(),
                            FilledButton(
                                onPressed: busy ? null : save,
                                child: Text(busy ? 'Saving…' : 'Save listing')),
                            gap()
                          ]))))));
}

class FilterPage extends StatefulWidget {
  const FilterPage(this.initial, {super.key, required this.mine});
  final Map<String, String> initial;
  final bool mine;
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late Map<String, String> f;
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    f = {...widget.initial};
  }

  Widget pick(String k, String label, Map<String, String> options,
          {String defaultValue = ''}) =>
      Choice(label, f[k] ?? defaultValue, options,
          (v) => setState(() => f[k] = v));
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Filter harvests')),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Form(
                  key: key,
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    pick('category', 'Produce',
                        {'': 'All produce', ...choices(categories)}),
                    gap(),
                    pick(
                        'city', 'City', {'': 'All cities', ...choices(cities)}),
                    gap(),
                    pick('price_type', 'Offer',
                        {'': 'Any price', 'free': 'Free', 'paid': 'Paid'}),
                    gap(),
                    TextFormField(
                        initialValue: f['max_price'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Maximum price (Rp)'),
                        onChanged: (v) => f['max_price'] = v.trim(),
                        validator: (v) => v != null &&
                                v.isNotEmpty &&
                                (num.tryParse(v) == null || num.parse(v) < 0)
                            ? 'Enter a non-negative price.'
                            : null),
                    gap(),
                    pick('availability', 'Availability',
                        {'now': 'Available now', 'any': 'Any time'},
                        defaultValue: widget.mine ? 'any' : 'now'),
                    gap(),
                    pick(
                        'sort',
                        'Sort',
                        {
                          'newest': 'Newest first',
                          'price_asc': 'Price: low to high',
                          'price_desc': 'Price: high to low',
                          'title': 'Title: A to Z'
                        },
                        defaultValue: 'newest'),
                    gap(),
                    FilledButton(
                        onPressed: () {
                          if (key.currentState!.validate()) {
                            f.removeWhere((k, v) => v.isEmpty);
                            Navigator.pop(context, f);
                          }
                        },
                        child: const Text('Apply filters')),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, <String, String>{}),
                        child: const Text('Reset filters')),
                  ])))));
}
