using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel.Extensions
{
    public static class CompressedPointsExtensions
    {
        public static List<Interpolated> ToInterpolatedPoints(this DbSet<CompressedPoint> compPoints) {
            var interPoints = new List<Interpolated>();
            foreach (var cp in compPoints) {
                var ip = new Interpolated() {
                    Tag = cp.Tag, Value = cp.Value, Time = cp.Time
                };
                interPoints.Add(ip);
            }

            return interPoints;
        }

    }
}
