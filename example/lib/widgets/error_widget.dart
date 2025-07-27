import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';

class ApiErrorWidget extends StatelessWidget {
  final ApiError error;
  final VoidCallback? onRetry;

  const ApiErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getErrorIcon(),
                size: 64,
                color: _getErrorColor(),
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.message,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case ApiErrorType.network:
        return Icons.signal_wifi_off;
      case ApiErrorType.timeout:
        return Icons.access_time;
      case ApiErrorType.server:
        return Icons.error;
      case ApiErrorType.authentication:
        return Icons.lock;
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    switch (error.type) {
      case ApiErrorType.network:
        return Colors.orange;
      case ApiErrorType.timeout:
        return Colors.amber;
      case ApiErrorType.authentication:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  String _getErrorTitle() {
    switch (error.type) {
      case ApiErrorType.network:
        return 'Network Error';
      case ApiErrorType.timeout:
        return 'Request Timeout';
      case ApiErrorType.server:
        return 'Server Error';
      case ApiErrorType.authentication:
        return 'Authentication Error';
      default:
        return 'Error';
    }
  }
}
