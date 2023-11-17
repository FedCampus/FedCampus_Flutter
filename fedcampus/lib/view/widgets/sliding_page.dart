import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class HealthSlidingPages extends StatefulWidget {
  const HealthSlidingPages({super.key});

  @override
  State<HealthSlidingPages> createState() => _HealthSlidingPagesState();
}

class _HealthSlidingPagesState extends State<HealthSlidingPages> {
  final List<Widget> items = [
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
            child: Image.asset("assets/images/guide/health_step_card.jpg")),
        const AutoSizeText("Each card displays your health data"),
      ],
    ),
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Image.asset("assets/images/guide/health_refresh.jpg")),
        const AutoSizeText("Pull down to refresh")
      ],
    ),
    const Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AutoSizeText("Configure what cards to show in Account -> Preferences")
      ],
    )
  ];
  @override
  Widget build(BuildContext context) {
    return SlidingPages(
      items: items,
    );
  }
}

class StatsSlidingPages extends StatefulWidget {
  const StatsSlidingPages({super.key});

  @override
  State<StatsSlidingPages> createState() => _StatsSlidingPagesState();
}

class _StatsSlidingPagesState extends State<StatsSlidingPages> {
  final List<Widget> items = [
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Image.asset("assets/images/guide/stats_filter.jpg")),
        const AutoSizeText(
            "Click the filter button to select a specific group of participants"),
      ],
    ),
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Image.asset("assets/images/guide/stats_fa_card.jpg")),
        const AutoSizeText("Group average and your percentile")
      ],
    )
  ];
  @override
  Widget build(BuildContext context) {
    return SlidingPages(
      items: items,
    );
  }
}

class SlidingPages extends StatefulWidget {
  const SlidingPages({super.key, required this.items});

  final List<Widget> items;

  @override
  State<SlidingPages> createState() => _SlidingPagesState();
}

class _SlidingPagesState extends State<SlidingPages> {
  int idx = 0;
  void updateIdx(int i) {
    setState(() {
      idx = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, widget.items.length);
  }

  Widget _buildCarousel(BuildContext context, int length) {
    double pixel = MediaQuery.of(context).size.width / 400;
    double screenPad = 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            // [PageView] needs to have finite height
            height: 240.0 * pixel,
            child: PageView.builder(
              controller: PageController(
                // https://stackoverflow.com/a/70098325
                viewportFraction:
                    1.0 + (screenPad * 2) / (constraints.maxWidth),
              ),
              itemCount: length,
              itemBuilder: (BuildContext context, int itemIndex) {
                return Padding(
                  padding:
                      EdgeInsets.fromLTRB(screenPad, 12 * pixel, screenPad, 0),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: widget.items[itemIndex],
                  ),
                );
              },
              onPageChanged: updateIdx,
            ),
          );
        }),
        SizedBox(
          height: 9 * pixel,
        ),
        Indicator(
          index: idx,
          length: length,
        )
      ],
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.index,
    required this.length,
  });

  final int index;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildPageIndicator(),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < length; i++) {
      list.add(i == index ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  // https://stackoverflow.com/a/63185381
  Widget _indicator(bool isActive) {
    return SizedBox(
      height: 10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: const Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? const Color(0XFF6BC4C9) : const Color(0XFFEAEAEA),
        ),
      ),
    );
  }
}
