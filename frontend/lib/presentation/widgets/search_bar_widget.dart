import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;

  const SearchBarWidget({super.key, required this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search notes...',
        border: InputBorder.none,
        filled: false,
      ),
      onChanged: widget.onChanged,
    );
  }
}