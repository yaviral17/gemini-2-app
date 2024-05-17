import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    this.isMe,
    this.message,
    this.loading = false,
  });
  final bool? isMe;
  final String? message;
  final bool? loading;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          widget.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: widget.isMe!
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.loading ?? false
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  // child: Text(
                  //   widget.message ?? "",
                  //   style: TextStyle(
                  //     color: widget.isMe!
                  //         ? Theme.of(context).colorScheme.onSecondary
                  //         : Theme.of(context).colorScheme.onPrimary,
                  //   ),
                  // ),
                  child: MarkdownViewer(widget.message ?? "",
                      styleSheet: MarkdownStyle(
                        textStyle: TextStyle(
                          color: widget.isMe!
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.onPrimary,
                        ),
                      )),
                ),
        ),
      ],
    );
  }
}
