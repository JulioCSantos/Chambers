using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class StagesDate
    {
        public StagesDate(string stageName, DateTime? startDate = null, DateTime? endDate = null): this() {
            Stage = new Stage(stageName);
            SetDates(startDate, endDate);
        }

        public StagesDate(Stage stage, DateTime? startDate = null, DateTime? endDate = null) : this() {
            Stage = stage;
            SetDates(startDate, endDate);
        }

        public void SetDates(DateTime? startDate, DateTime? endDate) {
            startDate ??= DateTime.Now.AddMonths(-1);
            StartDate = startDate ?? DateTime.Now.AddMonths(-1);
            if (endDate != null) { EndDate = (DateTime)endDate; }
        }
    }
}
