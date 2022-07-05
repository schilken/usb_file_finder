import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class ListEditor extends StatefulWidget {
  const ListEditor({Key? key}) : super(key: key);

  @override
  State<ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<ListEditor> {
  final itemList = <String>['Item 1', 'Item 2', 'Item 3'];
  late TextEditingController _textEditingController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  addItem(String newItem) {
    print('Adding $newItem');
    if (newItem.isEmpty) {
      return;
    }
    setState(() {
      itemList.add(newItem);
      _textEditingController.clear();
      Future.delayed(Duration(milliseconds: 100), () => _scrollToEnd());
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
//    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('ListEditor'),
            ),
            Expanded(
              child: Material(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(itemList[index]),
                      trailing: MacosIconButton(
                        icon: const MacosIcon(CupertinoIcons.delete),
                        onPressed: () {
                          setState(() {
                            itemList.removeAt(index);
                            FocusScope.of(context).requestFocus(_focusNode);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Text('Add String to the List:'),
                SizedBox(width: 20.0),
                Expanded(
                  child: MacosTextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    onChanged: (value) {},
                    onSubmitted: addItem,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
