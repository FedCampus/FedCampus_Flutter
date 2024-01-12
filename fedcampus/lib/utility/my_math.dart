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

double silvermanBandwidth(List<double> data) {
  double stdDev = _calculateStandardDeviation(data);
  int sampleSize = data.length;
  double bandwidth = 0.9 * stdDev * pow(sampleSize, (-1 / 5));
  return bandwidth;
}

double _calculateStandardDeviation(List<double> data) {
  double mean = data.reduce((a, b) => a + b) / data.length;
  double variance = data.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
      (data.length - 1);
  double stdDev = sqrt(variance);
  return stdDev;
}
