using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class BuildingsAreasUnit
    {
        public object ShallowCopy() {
            return this.MemberwiseClone();
        }
    }
}
