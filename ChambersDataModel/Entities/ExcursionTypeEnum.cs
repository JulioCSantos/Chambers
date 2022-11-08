using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class ExcursionType
    {
        public struct ExcEnum {
            public const string RampIn = nameof(RampIn);
            public const string HiExcursion = nameof(HiExcursion);
            public const string LowExcursion = nameof(LowExcursion);
            public const string RampOut = nameof(RampOut);
        }
    }
}
