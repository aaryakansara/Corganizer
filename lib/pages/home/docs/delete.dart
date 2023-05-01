import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<String> items;
  final Function(List<String>) onDeleteFilesConfirmed;
  final Function(List<String>) onDeleteFoldersConfirmed;

  const DeleteDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.items,
    required this.onDeleteFilesConfirmed,
    required this.onDeleteFoldersConfirmed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedItems = <String>{};
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    final item = items[index];
                    if (selectedItems.contains(item)) {
                      selectedItems.remove(item);
                    } else {
                      selectedItems.add(item);
                    }
                  },
                  child: Container(
                    color: selectedItems.contains(items[index])
                        ? Colors.blue
                        : Colors.grey,
                    child: Center(
                      child: Text(items[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(
                    'Are you sure you want to delete ${selectedItems.length} item(s)?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onDeleteFilesConfirmed(selectedItems.toList());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete Files'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onDeleteFoldersConfirmed(selectedItems.toList());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete Folders'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
