import "package:flutter/material.dart";

class Panel extends StatelessWidget {
  const Panel({super.key, this.child, this.title = "TITLE"});
  final Widget? child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold))),
      ]),
      Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 1.0,
                    blurRadius: 5)
              ]),
          child: child),
    ]);
  }
}

class LabeledText extends StatelessWidget {
  const LabeledText({
    super.key,
    this.label = "LABEL",
    this.value = "?",
    this.selectable = false,
    this.valueFontSize,
    this.fontFamily,
  });
  final String label;
  final String value;
  final bool selectable;
  final double? valueFontSize;
  final String? fontFamily;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "$label: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: selectable
                    ? SelectableText(
                        value,
                        style: TextStyle(
                            fontSize: valueFontSize, fontFamily: fontFamily),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                            fontSize: valueFontSize, fontFamily: fontFamily),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LabeledCheckBox extends StatelessWidget {
  const LabeledCheckBox(
      {super.key,
      this.label = "LABEL",
      this.onChanged,
      required this.value,
      required this.valueString,
      this.labelWidth = 120});

  final String label;
  final dynamic onChanged;
  final String valueString;
  final bool? value;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: labelWidth,
            alignment: Alignment.centerRight,
            child: Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
              ),
              Text(valueString),
            ],
          )),
        ],
      ),
    );
  }
}

class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    this.label = "LABEL",
    this.initialValue = "",
    this.labelWidth = 120,
    this.fieldWidth = 250,
    this.enabled = true,
    this.onSubmitted,
    this.largeMedia = false,
  });

  final String label;
  final String initialValue;
  final double? fieldWidth;
  final double? labelWidth;
  final bool enabled;
  final void Function(String)? onSubmitted;
  final bool largeMedia;
  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  // dispose it when the widget is unmounted
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.initialValue;
    return Container(
      padding: const EdgeInsets.all(8),
      child: widget.largeMedia
          ? Row(
              children: [
                Container(
                  width: widget.labelWidth,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${widget.label}:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 5),
                Focus(
                  child: SizedBox(
                    width: widget.fieldWidth,
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      if (widget.initialValue != _controller.text) {
                        if (widget.onSubmitted != null) {
                          widget.onSubmitted!(_controller.text);
                        }
                      }
                    }
                  },
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: widget.labelWidth,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${widget.label}:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 5),
                Focus(
                  child: SizedBox(
                    // width: fieldWidth,
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  onFocusChange: (value) {
                    if (!value) {
                      if (widget.initialValue != _controller.text) {
                        if (widget.onSubmitted != null) {
                          widget.onSubmitted!(_controller.text);
                        }
                      }
                    }
                  },
                ),
              ],
            ),
    );
  }
}

class MessageDialog extends StatelessWidget {
  const MessageDialog(
      {super.key,
      this.title = "TITLE",
      this.message = "MESSAGE",
      this.dialogWidth,
      this.onClose,
      this.largeMedia = false});

  final String title;
  final String message;
  final bool largeMedia;
  final double? dialogWidth;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          dialogWidth == null ? null : BoxConstraints(maxWidth: dialogWidth!),
      width: largeMedia ? dialogWidth : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 24.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close, size: 24),
                  label: const Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onClose != null) onClose!();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
