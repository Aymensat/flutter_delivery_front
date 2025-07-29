import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final Function(String)? onSubmitted;

  const SearchBar({
    required this.controller, // This controller should be used
    super.key,
    this.hintText = 'Search restaurants or food...',
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  // Removed the internal _controller.
  // We will now use widget.controller directly.

  @override
  void initState() {
    super.initState();
    // Add a listener to the passed controller to rebuild the widget
    // when the text changes (e.g., for showing/hiding the clear icon).
    widget.controller.addListener(_onControllerTextChanged);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed.
    widget.controller.removeListener(_onControllerTextChanged);
    // No need to dispose widget.controller here, as it's managed by the parent.
    super.dispose();
  }

  // A method to trigger a rebuild when the controller's text changes.
  void _onControllerTextChanged() {
    setState(() {
      // The state change will cause the build method to be re-run,
      // updating the visibility of the clear icon.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller:
            widget.controller, // Use the controller passed from the parent
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              widget
                  .controller
                  .text
                  .isNotEmpty // Check the passed controller's text
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear(); // Clear the passed controller
                    widget.onChanged(''); // Notify parent of the clear
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
