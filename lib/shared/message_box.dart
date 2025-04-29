import "package:flutter/material.dart";

class MessageBox extends StatelessWidget {
  const MessageBox(
      {super.key,
      this.title = "TITLE",
      this.message = "MESSAGE",
      this.dialogWidth,
      this.onClose,});

  final String title;
  final String message;
  final double? dialogWidth;
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          dialogWidth == null ? null : BoxConstraints(maxWidth: dialogWidth!),
      width: dialogWidth,
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

  static Future show(BuildContext aParentContext, String aTitle, String aMessage, double? aDialogWidth) {
    return showDialog<String>(
      barrierDismissible: false,
      context: aParentContext,
      builder: (BuildContext context) => Dialog(
        child: MessageBox(
          title: aTitle,
          message: aMessage,
          dialogWidth: aDialogWidth,
        ),
      ),
    );
  }
}
