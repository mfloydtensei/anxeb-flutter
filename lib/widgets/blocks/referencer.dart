import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class ReferencerBlock<V> extends StatefulWidget {
  final Anxeb.Scope scope;
  final Anxeb.Referencer<V> referencer;
  final Anxeb.ReferenceItemWidget<V>? itemWidget;
  final Anxeb.ReferenceHeaderWidget<V>? headerWidget;
  final Anxeb.ReferenceCreateWidget<V>? footerWidget;
  final Anxeb.ReferenceEmptyWidget<V>? emptyWidget;
  final EdgeInsets? padding;

  const ReferencerBlock({
    super.key,
    required this.scope,
    required this.referencer,
    this.itemWidget,
    this.headerWidget,
    this.footerWidget,
    this.emptyWidget,
    this.padding,
  });

  @override
  State<ReferencerBlock<V>> createState() => _ReferencerBlockState<V>();
}

class _ReferencerBlockState<V> extends State<ReferencerBlock<V>> {
  @override
  void initState() {
    super.initState();
    widget.referencer.updater = () {
      if (mounted) setState(() {});
    };
  }

  List<Widget> _buildFooterWidgets(dynamic page) {
    if (widget.footerWidget == null) return const [];
    return [
      Container(
        margin: const EdgeInsets.only(top: 14, bottom: 13),
        child: DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          lineThickness: 1,
          dashLength: 2,
          dashColor: widget.scope.application.settings.colors.primary,
          dashGapLength: 4.0,
        ),
      ),
      widget.footerWidget!(page),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final referencer = widget.referencer;
    final pages = referencer.pages;

    if (pages.isEmpty) {
      return Center(
        child: widget.emptyWidget?.call(null) ??
            const Text('No data available'),
      );
    }

    return PageView(
      controller: referencer.controller,
      allowImplicitScrolling: true,
      pageSnapping: true,
      onPageChanged: (index) => referencer.currentPage = index,
      children: pages.map((page) {
        return Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.headerWidget != null) widget.headerWidget!(page),
              Expanded(
                child: page.items.isEmpty
                    ? widget.emptyWidget?.call(page) ??
                        const Center(child: Text('No items found'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...page.items.map((item) =>
                                widget.itemWidget?.call(page, item) ??
                                const SizedBox.shrink()),
                            ..._buildFooterWidgets(page),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
