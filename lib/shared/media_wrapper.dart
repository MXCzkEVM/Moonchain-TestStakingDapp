import "package:flutter/material.dart";

class MediaWrapper extends StatelessWidget {
  const MediaWrapper({super.key, this.child, this.desginedWidth});
  final Widget? child;
  final double? desginedWidth;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final widthThreshold = desginedWidth ?? 450;
    final largeMedia = media.width > widthThreshold ? true : false;

    return largeMedia
        ? Row(children: [
            const Expanded(child: SizedBox()),
            SizedBox(
              width: widthThreshold,
              child: child,
            ),
            const Expanded(child: SizedBox())
          ])
        : SizedBox(child: child);
  }
}
