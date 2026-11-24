// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'market_api.dart';
import 'forms.dart';
import 'listing_detail.dart';
import 'package:urfunfarming_mobile/theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, required this.api, this.drawer});
  final MarketApi api;
  final Widget? drawer;
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final search = TextEditingController();
  bool mine = false;
  int page = 1;
  Map<String, String> filters = {};
  late Future<MarketPage> pending;
  @override
  void initState() {
    super.initState();
    pending = fetch();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<MarketPage> fetch() async {
    final hadSession = widget.api.session != null;
    try {
      return await widget.api.catalog(mine: mine, page: page, filters: filters);
    } on MarketFailure catch (e) {
      if (e.status == 401 &&
          hadSession &&
          widget.api.session == null &&
          mounted) {
        setState(() {
          mine = false;
          page = 1;
          filters = {};
          search.clear();
        });
      }
      rethrow;
    }
  }

  void refresh({bool first = false}) => setState(() {
        if (first) page = 1;
        pending = fetch();
      });
  void switchFeed(bool next) {
    mine = next;
    filters = {};
    search.clear();
    refresh(first: true);
  }

  Future<void> account() async {
    if (widget.api.session == null) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => SignInPage(widget.api)));
      if (mounted && ok == true) refresh(first: true);
    } else {
      try {
        await widget.api.logout();
      } on MarketFailure catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Signed out on this device. ${e.message}')));
        }
      }
      if (mounted) switchFeed(false);
    }
  }

  Future<void> filter() async {
    final result = await Navigator.push<Map<String, String>>(context,
        MaterialPageRoute(builder: (_) => FilterPage(filters, mine: mine)));
    if (mounted && result != null) {
      final q = search.text.trim();
      filters = {...result, if (q.isNotEmpty) 'q': q};
      refresh(first: true);
    }
  }

  void searchNow() {
    final q = search.text.trim();
    if (q.isEmpty) {
      filters.remove('q');
    } else {
      filters['q'] = q;
    }
    refresh(first: true);
  }

  Future<void> open(Harvest h) async {
    await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => ListingDetail(widget.api, h.id)));
    if (!mounted) return;
    if (widget.api.session == null && mine) {
      switchFeed(false);
    } else {
      refresh();
    }
  }

  Future<void> create() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => EditHarvest(widget.api)));
    if (!mounted) return;
    if (ok == true) {
      switchFeed(true);
    } else if (widget.api.session == null) {
      switchFeed(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.api.session;
    return Scaffold(
        drawer: widget.drawer,
        appBar: AppBar(title: const Text('urFunFarming'), actions: [
          TextButton.icon(
              onPressed: account,
              icon: Icon(s == null ? Icons.login : Icons.logout),
              label: Text(s == null ? 'Sign in' : 'Sign out')),
          const SizedBox(width: 6)
        ]),
        floatingActionButton: s?.grower == true
            ? FloatingActionButton.extended(
                onPressed: create,
                icon: const Icon(Icons.add),
                label: const Text('Post a harvest'))
            : null,
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: RefreshIndicator(
                        onRefresh: () async {
                          refresh();
                          try {
                            await pending;
                          } on MarketFailure {/* shown in the body */}
                        },
                        child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                      color: const Color(0xff254d36),
                                      borderRadius: BorderRadius.circular(22)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(children: [
                                          Icon(Icons.spa_outlined,
                                              color: Color(0xffd5e7aa),
                                              size: 18),
                                          SizedBox(width: 8),
                                          Text('LOCAL HARVEST  /  JABODETABEK',
                                              style: TextStyle(
                                                  color: Color(0xffd5e7aa),
                                                  fontSize: 11,
                                                  letterSpacing: 1.2,
                                                  fontWeight: FontWeight.w700))
                                        ]),
                                        gap(),
                                        const Text('Harvest Marketplace',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                height: 1.08,
                                                fontWeight: FontWeight.bold)),
                                        gap(),
                                        const Text(
                                            'Find fresh produce from growers in your neighbourhood.',
                                            style: TextStyle(
                                                color: Color(0xffe5eddf),
                                                fontSize: 15)),
                                      ])),
                              gap(),
                              if (s != null)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Wrap(spacing: 8, children: [
                                      ChoiceChip(
                                          label: const Text('Explore'),
                                          selected: !mine,
                                          onSelected: (_) => switchFeed(false)),
                                      ChoiceChip(
                                          label: const Text('My listings'),
                                          selected: mine,
                                          onSelected: (_) => switchFeed(true))
                                    ])),
                              Row(children: [
                                Expanded(
                                    child: TextField(
                                        controller: search,
                                        maxLength: 120,
                                        textInputAction: TextInputAction.search,
                                        onSubmitted: (_) => searchNow(),
                                        decoration: InputDecoration(
                                            labelText: 'Search harvests',
                                            counterText: '',
                                            suffixIcon: IconButton(
                                                tooltip: 'Search',
                                                onPressed: searchNow,
                                                icon: const Icon(
                                                    Icons.search))))),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                    tooltip: 'Filter harvests',
                                    onPressed: filter,
                                    icon: const Icon(Icons.tune))
                              ]),
                              gap(),
                              FutureBuilder<MarketPage>(
                                  future: pending,
                                  builder: (context, snap) {
                                    if (snap.connectionState !=
                                        ConnectionState.done) {
                                      return const Padding(
                                          padding: EdgeInsets.all(36),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    if (snap.hasError) {
                                      return Column(children: [
                                        ErrorText(snap.error.toString()),
                                        TextButton(
                                            onPressed: () {
                                              if (mine &&
                                                  widget.api.session == null) {
                                                switchFeed(false);
                                              } else {
                                                refresh();
                                              }
                                            },
                                            child: const Text('Retry'))
                                      ]);
                                    }
                                    final data = snap.requireData;
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(
                                                  '${mine ? 'My listings' : 'Explore'} · ${data.count} ${data.count == 1 ? 'harvest' : 'harvests'}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium)),
                                          if (data.listings.isEmpty)
                                            const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 28),
                                                child: Text(
                                                    'No harvests found. Try another search or adjust your filters.')),
                                          for (final h in data.listings)
                                            HarvestCard(h,
                                                onTap: () => open(h)),
                                          if (data.pages > 1)
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      tooltip: 'Previous page',
                                                      onPressed: data.page > 1
                                                          ? () {
                                                              page =
                                                                  data.page - 1;
                                                              refresh();
                                                            }
                                                          : null,
                                                      icon: const Icon(
                                                          Icons.chevron_left)),
                                                  Text(
                                                      'Page ${data.page} of ${data.pages}'),
                                                  IconButton(
                                                      tooltip: 'Next page',
                                                      onPressed: data.page <
                                                              data.pages
                                                          ? () {
                                                              page =
                                                                  data.page + 1;
                                                              refresh();
                                                            }
                                                          : null,
                                                      icon: const Icon(
                                                          Icons.chevron_right))
                                                ])
                                        ]);
                                  })
                            ]))))));
  }
}

class HarvestCard extends StatelessWidget {
  const HarvestCard(this.harvest, {super.key, required this.onTap});
  final Harvest harvest;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final h = harvest;
    final c = h.value('category');
    final icon = c == 'fruits'
        ? Icons.apple_outlined
        : c == 'herbs'
            ? Icons.eco_outlined
            : Icons.grass;
    final color = c == 'fruits'
        ? const Color(0xfff3deca)
        : c == 'herbs'
            ? const Color(0xffdce9cc)
            : const Color(0xffedeacb);
    // The app's card look (see AppCardStyle in theme.dart). It is null in
    // the standalone preview (main_marketplace.dart, harvestTheme), which
    // never had a card theme, so the card keeps Flutter's default look there.
    final style = Theme.of(context).extension<AppCardStyle>();
    return Card(
        color: Colors.white,
        elevation: style == null ? null : 0,
        surfaceTintColor: style == null ? null : Colors.transparent,
        shape: style?.shape,
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                      width: 56,
                      height: 68,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          Icon(icon, color: const Color(0xff3b5136), size: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('${titleCase(c)} · ${h.value('status_label')}',
                            style: Theme.of(context).textTheme.labelSmall),
                        Text(h.value('title'),
                            style: Theme.of(context).textTheme.titleMedium),
                        Text("${h.value('area')}, ${h.value('city')}",
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(priceLine(h),
                            style: const TextStyle(
                                color: Color(0xff30583a),
                                fontWeight: FontWeight.bold)),
                      ])),
                  const Icon(Icons.chevron_right)
                ]))));
  }
}

String priceLine(Harvest h) => h.value('price_label') == 'Free'
    ? 'Free'
    : '${h.value('price_label')} / ${h.value('price_unit_label')}';
