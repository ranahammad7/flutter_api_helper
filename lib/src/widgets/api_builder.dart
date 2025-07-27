import 'package:flutter/material.dart';
import '../models/api_error.dart';

/// Widget that builds UI based on API call state
class ApiBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget? loading;
  final Widget Function(ApiError error)? error;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  const ApiBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
  });

  @override
  State<ApiBuilder<T>> createState() => _ApiBuilderState<T>();
}

class _ApiBuilderState<T> extends State<ApiBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          if (error is ApiError) {
            return widget.error?.call(error) ??
                _DefaultErrorWidget(error: error);
          }
          return widget.error?.call(
                ApiError(
                  message: error.toString(),
                  type: ApiErrorType.unknown,
                ),
              ) ??
              _DefaultErrorWidget(
                error: ApiError(
                  message: error.toString(),
                  type: ApiErrorType.unknown,
                ),
              );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;

          // Check if data is empty
          if (widget.isEmpty?.call(data) == true) {
            return widget.empty ??
                const Center(child: Text('No data available'));
          }

          return widget.builder(data);
        }

        return widget.empty ?? const Center(child: Text('No data available'));
      },
    );
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  final ApiError error;

  const _DefaultErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            error.message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (error.statusCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Status Code: ${error.statusCode}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case ApiErrorType.network:
        return Icons.wifi_off;
      case ApiErrorType.timeout:
        return Icons.timer_off;
      case ApiErrorType.server:
        return Icons.error_rounded;
      case ApiErrorType.client:
        return Icons.error;
      case ApiErrorType.authentication:
        return Icons.lock;
      case ApiErrorType.parsing:
        return Icons.data_object;
      default:
        return Icons.error_outline;
    }
  }
}
