using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class StagesDate
    {
        public StagesDate(string stageName, DateTime? startDate = null, DateTime? endDate = null) {
            Stage = new Stage(stageName);
            SetDates(startDate, endDate);
        }

        public StagesDate(Stage stage, DateTime? startDate = null, DateTime? endDate = null) {
            Stage = stage;
            SetDates(startDate, endDate);
        }

        public void SetDates(DateTime? startDate, DateTime? endDate) {
            if (startDate != null) { StartDate = (DateTime)startDate; }
            if (endDate != null) { EndDate = (DateTime)endDate; }
        }
    }
}
