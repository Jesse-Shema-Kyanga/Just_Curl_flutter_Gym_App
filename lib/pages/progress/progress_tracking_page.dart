import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../helpers/database_helper.dart';
import '../../user_preferences.dart';

class ProgressTrackingPage extends StatefulWidget {
  const ProgressTrackingPage({Key? key}) : super(key: key);

  @override
  _ProgressTrackingPageState createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  final DatabaseHelper _db = DatabaseHelper();
  String? userEmail;
  String selectedPeriod = 'week';
  List<FlSpot> weightData = [];
  double currentWeight = 70.0;
  double goalWeight = 65.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userEmail = await UserPreferences.getEmail();
    if (userEmail != null) {
      final userProfile = await _db.getUserProfile(userEmail!);
      if (userProfile != null) {
        setState(() {
          currentWeight = userProfile['current_weight'] ?? 70.0;
          goalWeight = userProfile['weight_goal'] ?? 65.0;
        });
      }
      _loadWeightEntries();
    }
  }

  Future<void> _loadWeightEntries() async {
    if (userEmail != null) {
      final entries = await _db.getWeightEntries(userEmail!, selectedPeriod);
      setState(() {
        weightData = entries
            .asMap()
            .entries
            .map((entry) => FlSpot(
          entry.key.toDouble(),
          entry.value['weight'] as double,
        ))
            .toList();
      });
    }
  }

  Widget _buildProgressHeader() {
    double progressPercentage = ((currentWeight - goalWeight).abs() / goalWeight) * 100;
    bool isWeightLoss = currentWeight > goalWeight;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightDisplay('currentWeight'.tr(), currentWeight),
              Container(
                height: 50,
                width: 2,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              _buildWeightDisplay('goalWeight'.tr(), goalWeight),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% ${isWeightLoss ? 'tolose'.tr() : 'togain'.tr()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightDisplay(String label, double weight) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: weightData.isEmpty
                  ? [const FlSpot(0, 0), const FlSpot(1, 0)]
                  : weightData,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPeriodButton('week'),
        _buildPeriodButton('month'),
        _buildPeriodButton('year'),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    bool isSelected = selectedPeriod == period;
    return TextButton(
      onPressed: () {
        setState(() {
          selectedPeriod = period;
          _loadWeightEntries();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
      ),
      child: Text(
        period.tr(),
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _showWeightEntryDialog() async {
    TextEditingController weightController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('enterWeight'.tr()),
          content: TextField(
            controller: weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'weightInKg'.tr(),
              suffixText: 'kg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                if (weightController.text.isNotEmpty) {
                  double? weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    _saveNewWeight(weight);
                  }
                }
                Navigator.pop(context);
              },
              child: Text('save'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNewWeight(double weight) async {
    if (userEmail != null) {
      await _db.insertWeightEntry(userEmail!, weight);
      await _db.updateUserProfile(userEmail!, currentWeight: weight);
      setState(() {
        currentWeight = weight;
      });
      _loadWeightEntries();
    }
  }
  Widget _buildWeightHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'weightHistory'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weightData.length,
            itemBuilder: (context, index) {
              final entry = weightData[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('${entry.y.toStringAsFixed(1)} kg'),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy').format(
                      DateTime.now().subtract(Duration(days: weightData.length - 1 - index)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('progressTracking'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressHeader(),
            _buildWeightChart(),
            _buildPeriodSelector(),
            _buildWeightHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWeightEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


