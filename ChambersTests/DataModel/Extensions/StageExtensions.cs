using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel.Extensions
{
    public static class StageExtensions
    {
        public static double GetMidValue(this Stage stage)
        {
            var halfStep = (stage.MaxThreshold - stage.MinThreshold) / 2;
            var midValue = halfStep + stage.MinThreshold;
            return midValue;
        }
    }
}
