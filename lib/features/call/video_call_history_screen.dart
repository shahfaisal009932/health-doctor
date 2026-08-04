import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/call_history_model.dart';
import '../../data/repositories/call_repository.dart';
import 'widgets/call_history_card.dart';

class VideoCallHistoryScreen extends StatefulWidget {
  const VideoCallHistoryScreen({super.key});

  @override
  State<VideoCallHistoryScreen> createState() => _VideoCallHistoryScreenState();
}

class _VideoCallHistoryScreenState extends State<VideoCallHistoryScreen> {
  final CallRepository _repository = Get.find<CallRepository>();

  String _appointmentId = '';
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<CallHistoryModel> _history = [];

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    _appointmentId = argument is String ? argument : '';
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final history = await _repository.getCallHistory(_appointmentId);
      if (!mounted) return;
      setState(() {
        _history = history;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = 'Failed to load call history.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Call History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return ErrorView(message: _errorMessage, onRetry: _loadHistory);
    }
    if (_history.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: 'No Calls Recorded',
        subtitle: 'Completed consultations will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final call = _history[index];
        return CallHistoryCard(call: call);
      },
    );
  }
}
