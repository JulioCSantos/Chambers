using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel.Extensions
{
    public static class EnumerableExtensions
    {
        public static double StandardDeviationSample(this IEnumerable<double> sequence) {
            var enumerable = sequence as double[] ?? sequence.ToArray();
            if (enumerable.Length == 1) { throw new ArgumentException("Enumerable must have at least two data points"); }
            double average = enumerable.Average();
            double sum = enumerable.Sum(d => Math.Pow(d - average, 2));
            return Math.Sqrt((sum) / (enumerable.Count() - 1));
        }
        public static double StandardDeviationPopulation(this IEnumerable<double> sequence) {
            var enumerable = sequence as double[] ?? sequence.ToArray();
            double average = enumerable.Average();
            double sum = enumerable.Sum(d => Math.Pow(d - average, 2));
            return Math.Sqrt((sum) / enumerable.Count());
        }
    }
}
