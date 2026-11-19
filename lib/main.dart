import 'package:material_ui/material_ui.dart';

const _background = Color(0xFFF8F9FF);
const _surfaceLow = Color(0xFFEFF4FF);
const _surface = Color(0xFFFFFFFF);
const _ink = Color(0xFF0B1C30);
const _muted = Color(0xFF64748B);
const _primary = Color(0xFF005C55);
const _primaryContainer = Color(0xFF0F766E);
const _amber = Color(0xFFF59E0B);
const _tertiary = Color(0xFF007952);
const _red = Color(0xFFBA1A1A);

void main() => runApp(const BudgetWiseApp());

class BudgetWiseApp extends StatelessWidget {
  const BudgetWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          surface: _background,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _ink,
          displayColor: _ink,
          fontFamily: 'Inter',
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _background,
          foregroundColor: _ink,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: const Color(0xFFCFE9E5),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? _primary : _muted,
            ),
          ),
        ),
      ),
      home: const BudgetWiseShell(),
    );
  }
}

class TransactionItem {
  const TransactionItem({
    required this.name,
    required this.category,
    required this.amount,
    required this.icon,
    this.isIncome = false,
  });
  final String name;
  final String category;
  final double amount;
  final IconData icon;
  final bool isIncome;
}

class BudgetWiseShell extends StatefulWidget {
  const BudgetWiseShell({super.key});

  @override
  State<BudgetWiseShell> createState() => _BudgetWiseShellState();
}

class _BudgetWiseShellState extends State<BudgetWiseShell> {
  bool _showOnboarding = true;
  bool _showAuth = false;
  int _tab = 0;
  final List<TransactionItem> _transactions = const [
    TransactionItem(name: 'Whole Foods Market', category: 'Food & Dining', amount: 64.20, icon: Icons.restaurant),
    TransactionItem(name: 'Blue Bottle Coffee', category: 'Cafe', amount: 6.50, icon: Icons.local_cafe),
    TransactionItem(name: 'Subway Transit', category: 'Transport', amount: 11.95, icon: Icons.directions_subway),
    TransactionItem(name: 'Salary Deposit', category: 'Payroll', amount: 2850, icon: Icons.payments, isIncome: true),
    TransactionItem(name: 'Uber Express', category: 'Transport', amount: 18.45, icon: Icons.local_taxi),
  ];

  Future<void> _openAddTransaction() async {
    final result = await Navigator.of(context).push<TransactionItem>(
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result != null && mounted) {
      setState(() => _transactions.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingPage(onDone: () => setState(() {
        _showOnboarding = false;
        _showAuth = true;
      }));
    }
    if (_showAuth) {
      return AuthPage(onDone: () => setState(() => _showAuth = false));
    }

    final pages = [
      DashboardPage(transactions: _transactions, onAdd: _openAddTransaction),
      TransactionsPage(transactions: _transactions, onAdd: _openAddTransaction),
      BudgetsPage(onAdd: _openAddTransaction),
      ReportsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(top: false, child: pages[_tab]),
      floatingActionButton: _tab == 4
          ? null
          : FloatingActionButton(
              onPressed: _openAddTransaction,
              backgroundColor: _primaryContainer,
              foregroundColor: Colors.white,
              elevation: 6,
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        height: 76,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class BudgetHeader extends StatelessWidget {
  const BudgetHeader({super.key, required this.subtitle});
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: _background.withValues(alpha: 0.95),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.currency_exchange, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BudgetWise', style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: _muted)),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFDCE9FF),
            foregroundColor: _primary,
            child: Icon(Icons.person, size: 18),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;
  final _titles = const ['Track your spending effortlessly', 'Set smart, adaptive budgets', 'Reach your goals with confidence'];
  final _texts = const [
    'Monitor real-time expenses and watch your savings grow every month.',
    'Personalized limits that adjust to your lifestyle without rigid spreadsheets.',
    'Turn your plans into clear milestones and celebrate every win.',
  ];
  final _icons = const [Icons.credit_card, Icons.pie_chart, Icons.savings];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, color: _primary),
                  const SizedBox(width: 8),
                  const Text('BudgetWise', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: widget.onDone, child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                itemCount: _titles.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [const Color(0xFFDCE9FF), _surface]),
                        ),
                        child: Icon(_icons[index], size: 92, color: _primary),
                      ),
                      const SizedBox(height: 36),
                      Text(_titles[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(_texts[index], textAlign: TextAlign.center, style: const TextStyle(color: _muted, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  for (var i = 0; i < _titles.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: _page == i ? _primary : const Color(0xFFD3E4FE), borderRadius: BorderRadius.circular(8)),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_page == _titles.length - 1) {
                        widget.onDone();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: _primaryContainer, minimumSize: const Size(128, 48)),
                    child: Text(_page == _titles.length - 1 ? 'Get Started' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _signup = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.currency_exchange, size: 56, color: _primary)),
            const SizedBox(height: 8),
            const Text('BudgetWise', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const Text('Calm financial clarity', textAlign: TextAlign.center, style: TextStyle(color: _muted)),
            const SizedBox(height: 24),
            Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: _authTab('Log In', !_signup, () => setState(() => _signup = false))),
                Expanded(child: _authTab('Sign Up', _signup, () => setState(() => _signup = true))),
              ]),
            ),
            const SizedBox(height: 18),
            if (_signup) ...[
              _authField('Full Name', Icons.person),
              const SizedBox(height: 12),
            ],
            _authField('Email address', Icons.mail),
            const SizedBox(height: 12),
            TextField(
              obscureText: _obscure,
              decoration: InputDecoration(
                filled: true,
                fillColor: _surface,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
                hintText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: widget.onDone,
              style: FilledButton.styleFrom(backgroundColor: _primaryContainer, minimumSize: const Size.fromHeight(52)),
              child: Text(_signup ? 'Create Account' : 'Sign In'),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(onPressed: widget.onDone, icon: const Icon(Icons.g_mobiledata), label: const Text('Continue with Google'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), side: BorderSide(color: Colors.grey.shade200))),
          ],
        ),
      ),
    );
  }

  Widget _authTab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(color: selected ? _surface : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? _primary : _muted, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _authField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: _surface,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.transactions, required this.onAdd});
  final List<TransactionItem> transactions;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BudgetHeader(subtitle: 'Dashboard'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              const Text('Tuesday, Oct 28  •  On track', style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Good morning, Alex', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF004842)]),
                  boxShadow: const [BoxShadow(color: Color(0x260F766E), blurRadius: 18, offset: Offset(0, 8))],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL NET BALANCE', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 11, letterSpacing: 1)),
                    SizedBox(height: 8),
                    Text('USh 14,850.20', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('+4.2% from last month', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                    SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _BalancePill(label: 'Income', amount: '+USh 4,250', icon: Icons.arrow_downward, positive: true)),
                      SizedBox(width: 8),
                      Expanded(child: _BalancePill(label: 'Expenses', amount: '-USh 1,820', icon: Icons.arrow_upward, positive: false)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.savings, color: _primary),
                      SizedBox(width: 8),
                      Expanded(child: Text('Monthly Budget', style: TextStyle(fontWeight: FontWeight.w700))),
                      Text('USh 1,180 left', style: TextStyle(color: _tertiary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                    SizedBox(height: 14),
                    Text('USh 1,820 spent  /  USh 3,000', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.606, minHeight: 8, color: _primaryContainer, backgroundColor: Color(0xFFE5EEFF), borderRadius: BorderRadius.all(Radius.circular(8))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: const Column(
                  children: [
                    Row(children: [
                      Icon(Icons.donut_large, color: _amber),
                      SizedBox(width: 8),
                      Text('Spending Breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    SizedBox(height: 12),
                    SizedBox(height: 180, width: 180, child: _DonutChart()),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: onAdd, child: const Text('Add')),
                ],
              ),
              ...transactions.take(4).map((item) => _TransactionTile(item: item)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4))],
    ),
    child: child,
  );
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.label, required this.amount, required this.icon, required this.positive});
  final String label;
  final String amount;
  final IconData icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(radius: 15, backgroundColor: positive ? const Color(0xFF007952) : const Color(0xFFFFDAD6), child: Icon(icon, size: 16, color: positive ? Colors.white : _red)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ])),
      ]),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(),
      child: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('TOTAL', style: TextStyle(color: _muted, fontSize: 10)),
          Text('USh 1,820', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ]),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const rectValues = [0.40, 0.25, 0.15, 0.12, 0.08];
    const colors = [_primary, _amber, _tertiary, Color(0xFF684000), _red];
    final rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    var start = -1.5708;
    for (var i = 0; i < rectValues.length; i++) {
      final sweep = rectValues[i] * 6.28318 - 0.06;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += rectValues[i] * 6.28318;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});
  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: item.isIncome ? const Color(0x1A007952) : const Color(0x1AFEA619), foregroundColor: item.isIncome ? _tertiary : _amber, child: Icon(item.icon, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(item.category, style: const TextStyle(color: _muted, fontSize: 12)),
          ])),
          Text('${item.isIncome ? '+' : '-'}USh ${item.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, color: item.isIncome ? _tertiary : _ink)),
        ],
      ),
    );
  }
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.transactions, required this.onAdd});
  final List<TransactionItem> transactions;
  final VoidCallback onAdd;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _filter = 'All';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();
    final items = widget.transactions.where((item) {
      final matchesQuery = query.isEmpty || item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query);
      final matchesType = _filter == 'All' || (_filter == 'Income' && item.isIncome) || (_filter == 'Expense' && !item.isIncome);
      return matchesQuery && matchesType;
    }).toList();

    return Column(
      children: [
        const BudgetHeader(subtitle: 'Transactions'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _surface,
                  hintText: 'Search merchants or categories',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Income', 'Expense', 'This Month'].map((label) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == label,
                      onSelected: (_) => setState(() => _filter = label),
                      selectedColor: _primary,
                      backgroundColor: _surface,
                      showCheckmark: false,
                      labelStyle: TextStyle(color: _filter == label ? Colors.white : _ink, fontWeight: FontWeight.w600),
                      side: BorderSide.none,
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 14),
              for (final item in items) _TransactionTile(item: item),
            ],
          ),
        ),
      ],
    );
  }
}

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  Widget build(BuildContext context) {
    const budgets = [
      ('Food & Dining', 'restaurant', 620.0, 700.0, _amber),
      ('Housing & Utilities', 'home', 1100.0, 1100.0, _primary),
      ('Transportation', 'directions_car', 140.0, 300.0, _tertiary),
      ('Shopping & Retail', 'shopping_bag', 380.0, 300.0, _red),
      ('Health & Wellness', 'favorite', 80.0, 200.0, _tertiary),
      ('Entertainment', 'movie', 120.0, 150.0, _amber),
    ];

    IconData iconFor(String name) => switch (name) {
      'home' => Icons.home,
      'directions_car' => Icons.directions_car,
      'shopping_bag' => Icons.shopping_bag,
      'favorite' => Icons.favorite,
      'movie' => Icons.movie,
      _ => Icons.restaurant,
    };

    return Column(
      children: [
        const BudgetHeader(subtitle: 'Budgets'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Row(children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                const Expanded(child: Text('October 2024', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(16)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MONTHLY PACING', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 11, letterSpacing: 1)),
                  SizedBox(height: 8),
                  Text('USh 2,140 / USh 3,200', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: 0.67, minHeight: 8, color: Color(0xFF9CF2E8), backgroundColor: Color(0x33FFFFFF), borderRadius: BorderRadius.all(Radius.circular(8))),
                ]),
              ),
              const SizedBox(height: 14),
              for (final budget in budgets) ...[
                _BudgetTile(
                  title: budget.$1,
                  icon: iconFor(budget.$2),
                  spent: budget.$3,
                  limit: budget.$4,
                  color: budget.$5,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.title, required this.icon, required this.spent, required this.limit, required this.color});
  final String title;
  final IconData icon;
  final double spent;
  final double limit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = spent / limit;
    final over = spent > limit;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: over ? const Color(0xFFFFEAE7) : _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.13), foregroundColor: color, child: Icon(icon, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(over ? 'Over budget by USh ${(spent - limit).toStringAsFixed(0)}' : (limit - spent == 0 ? 'Exact limit reached' : 'USh ${(limit - spent).toStringAsFixed(0)} remaining'), style: TextStyle(color: over ? _red : _muted, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('USh ${spent.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w700, color: over ? _red : _ink)),
            Text('of USh ${limit.toStringAsFixed(0)}', style: const TextStyle(color: _muted, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: percent.clamp(0, 1), minHeight: 8, color: color, backgroundColor: const Color(0xFFE5EEFF), borderRadius: const BorderRadius.all(Radius.circular(8))),
      ]),
    );
  }
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _period = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BudgetHeader(subtitle: 'Reports'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                  const Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, size: 18, color: _primary), SizedBox(width: 6), Text('October 2024', style: TextStyle(fontWeight: FontWeight.w700))])),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                ]),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(12)),
                child: Row(children: ['Weekly', 'Monthly', 'Yearly'].indexed.map((entry) => Expanded(child: GestureDetector(
                  onTap: () => setState(() => _period = entry.$1),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _period == entry.$1 ? _primary : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                    child: Text(entry.$2, style: TextStyle(color: _period == entry.$1 ? Colors.white : _muted, fontWeight: FontWeight.w600)),
                  ),
                ))).toList()),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Income vs Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Row(children: [
                    Expanded(child: _ReportMetric(label: 'Earned', amount: 'USh 4,250', color: _tertiary)),
                    SizedBox(width: 8),
                    Expanded(child: _ReportMetric(label: 'Spent', amount: 'USh 1,820', color: _amber)),
                  ]),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final values in const [(75.0, 30.0), (64.0, 38.0), (85.0, 28.0), (78.0, 34.0)])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Container(
                                  width: 14,
                                  height: values.$1 * 1.2,
                                  decoration: BoxDecoration(color: _tertiary, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 14,
                                  height: values.$2 * 1.2,
                                  decoration: BoxDecoration(color: _amber, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                                ),
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFFF1D9), borderRadius: BorderRadius.circular(16)),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.lightbulb, color: _amber),
                  SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Spending Insight', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('You spent 14% less on Dining than last month. You are on track to save an extra USh 240 this October.', style: TextStyle(color: Color(0xFF653E00), height: 1.45)),
                  ])),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), Text('Total: USh 1,820', style: TextStyle(color: _primary, fontWeight: FontWeight.w700))]),
                  const SizedBox(height: 12),
                  const SizedBox(width: 190, height: 190, child: _DonutChart()),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({required this.label, required this.amount, required this.color});
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _muted, fontSize: 11)), Text(amount, style: const TextStyle(fontWeight: FontWeight.w700))]),
      ]),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BudgetHeader(subtitle: 'Profile'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFDCE9FF),
                    foregroundColor: _primary,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text('Favor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Text('favor@example.com', style: TextStyle(color: _muted)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(12)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _ProfileStat(label: 'Wallets', value: '4'),
                      _ProfileStat(label: 'Budgets', value: '8'),
                      _ProfileStat(label: 'Streak', value: '42d'),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('Preferences', style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _SettingsCard(children: [
                const _SettingsTile(icon: Icons.currency_exchange, title: 'Currency', trailing: 'UGX (USh)'),
                _SettingsSwitch(icon: Icons.notifications_active, title: 'Push Notifications', subtitle: 'Alerts and bill reminders', value: _notifications, onChanged: (value) => setState(() => _notifications = value)),
                _SettingsSwitch(icon: Icons.dark_mode, title: 'Dark Mode', subtitle: 'Following system default', value: _darkMode, onChanged: (value) => setState(() => _darkMode = value)),
              ]),
              const SizedBox(height: 18),
              const Text('Financial Data', style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const _SettingsCard(children: [
                _SettingsTile(icon: Icons.account_balance, title: 'Connected Bank Accounts', trailing: '2 linked'),
                _SettingsTile(icon: Icons.download, title: 'Export Data', trailing: ''),
              ]),
              const SizedBox(height: 18),
              const Text('Security', style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const _SettingsCard(children: [
                _SettingsTile(icon: Icons.fingerprint, title: 'Security & Biometrics', trailing: 'Enabled'),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
  ]);
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const Divider(height: 1, indent: 68, endIndent: 16),
        ],
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.trailing});
  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(backgroundColor: const Color(0xFFE5EEFF), foregroundColor: _primary, child: Icon(icon, size: 20)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailing.isNotEmpty) Text(trailing, style: const TextStyle(color: _primary, fontSize: 12)), const SizedBox(width: 4), const Icon(Icons.chevron_right, size: 20, color: _muted)]),
  );
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(backgroundColor: const Color(0xFFE5EEFF), foregroundColor: _primary, child: Icon(icon, size: 20)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
    trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: _primary),
  );
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool _income = false;
  bool _recurring = false;
  String _amount = '48.50';
  String _category = 'Food';
  IconData _categoryIcon = Icons.restaurant;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _key(String key) {
    setState(() {
      if (key == '.') {
        if (!_amount.contains('.')) _amount += '.';
      } else if (key == 'back') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        if (_amount.isEmpty) {
          _amount = '0';
        }
      } else {
        if (_amount == '0') {
          _amount = key;
        } else if (!_amount.contains('.') || _amount.split('.').last.length < 2) {
          _amount += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Food', '🍔', Icons.restaurant),
      ('Transport', '🚗', Icons.directions_car),
      ('Bills', '💡', Icons.lightbulb),
      ('Shopping', '🛍️', Icons.shopping_bag),
      ('Health', '💊', Icons.medication),
      ('Fun', '🎬', Icons.movie),
      ('Other', '🏷️', Icons.sell),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(child: _typeButton('Expense', !_income, () => setState(() => _income = false), _red)),
              Expanded(child: _typeButton('Income', _income, () => setState(() => _income = true), _tertiary)),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            height: 132,
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(24)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Total ${_income ? 'Income' : 'Expense'}', style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 4),
              Text('USh $_amount', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Main Checking • USh 4,280.15', style: TextStyle(color: _primary, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 14),
          const Text('Category', style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: categories.map((category) {
              final selected = _category == category.$1;
              return GestureDetector(
                onTap: () => setState(() {
                  _category = category.$1;
                  _categoryIcon = category.$3;
                }),
                child: Container(
                  decoration: BoxDecoration(color: selected ? const Color(0xFFDCE9FF) : _surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(category.$2, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(category.$1, style: TextStyle(fontSize: 11, color: selected ? _primary : _muted, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Row(children: [Icon(Icons.calendar_today, color: _primary), SizedBox(width: 10), Text('Today, Oct 25, 2024', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                decoration: const InputDecoration(hintText: 'Add a note', prefixIcon: Icon(Icons.edit_note, color: _primary), border: InputBorder.none),
              ),
              Row(children: [
                const Icon(Icons.sync, color: _primary),
                const SizedBox(width: 10),
                const Expanded(child: Text('Recurring')),
                Switch(value: _recurring, onChanged: (value) => setState(() => _recurring = value), activeThumbColor: _primary),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _surfaceLow, borderRadius: BorderRadius.circular(20)),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.7,
              children: [
                for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'])
                  InkWell(
                    onTap: () => _key(key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: key == 'back' ? const Icon(Icons.backspace_outlined) : Text(key == '.' ? '•' : key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              final amount = double.tryParse(_amount) ?? 0;
              Navigator.pop(context, TransactionItem(name: _note.text.trim().isEmpty ? _category : _note.text.trim(), category: _category, amount: amount, icon: _categoryIcon, isIncome: _income));
            },
            icon: const Icon(Icons.check),
            style: FilledButton.styleFrom(backgroundColor: _primaryContainer, minimumSize: const Size.fromHeight(52)),
            label: const Text('Save Transaction'),
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String label, bool selected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: selected ? (color == _red ? const Color(0xFFFFDAD6) : const Color(0xFFCCFBF1)) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? color : _muted, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
