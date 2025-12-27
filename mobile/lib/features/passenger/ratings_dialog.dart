import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';

class RatingsDialog extends StatefulWidget {
  final String nganyaId;

  const RatingsDialog({super.key, required this.nganyaId});

  @override
  State<RatingsDialog> createState() => _RatingsDialogState();
}

class _RatingsDialogState extends State<RatingsDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/ratings/${widget.nganyaId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': _rating,
          'comment': _commentController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Nganya'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Optional Comment',
              hintText: 'Clean, safe, fast?',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _submitRating,
                child: const Text('Submit'),
              ),
      ],
    );
  }
}
