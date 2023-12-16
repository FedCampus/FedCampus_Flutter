library;

import 'dart:math';

List<double> linspace(double start, double end, int numPoints) {
  double step = (end - start) / (numPoints - 1);
  return List<double>.generate(numPoints, (index) => start + step * index);
}

List<double> kernelSmoothing(
    List<double> x, List<double> data, double bandwidth) {
  double normalizationFactor = data.length * bandwidth;
  return x
      .map((point) =>
          data
              .map((dataPoint) => normalPdf((point - dataPoint) / bandwidth))
              .reduce((sum, value) => sum + value) /
          normalizationFactor)
      .toList();
}

double normalPdf(double x) {
  final double sqrtTwoPi = sqrt(2 * pi);
  return exp(-0.5 * x * x) / sqrtTwoPi;
}
