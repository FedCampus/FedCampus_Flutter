import 'package:flutter/material.dart';
import 'package:fedcampus/view/widgets/widget.dart';

class HealthCard extends StatelessWidget {
  const HealthCard({
    super.key,
    required this.fem,
    required this.ffem,
    required this.value,
    required this.imagePath,
    required this.name,
    required this.unit,
  });

  final double fem;
  final double ffem;
  final String value;
  final String imagePath;
  final String name;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final valueColumn;
    if (unit != null) {
      valueColumn = Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primaryContainer)),
          Text(unit!,
              style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primaryContainer))
        ],
      );
    } else {
      valueColumn = Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primaryContainer)),
        ],
      );
    }
    return FedCard(
      fem: fem,
      ffem: ffem,
      widget: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FedIcon(fem: fem, imagePath: imagePath),
              SizedBox(
                height: 10 * fem,
              ),
              Text(
                name,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ],
          ),
          SizedBox(
            width: 11 * fem,
          ),
          valueColumn
        ],
      ),
    );
  }
}
