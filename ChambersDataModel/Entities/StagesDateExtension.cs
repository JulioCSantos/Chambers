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
            if (startDate != null) { StartDate = startDate!.Value; }
            else {
                if (stage.ProductionDate == null) { SetDates(startDate, endDate); }
                else { StartDate = stage.ProductionDate!.Value; }
            }
            if (endDate != null) { EndDate = endDate!.Value; }
            else { EndDate = DateTime.MaxValue; }


        }

        public void SetDates(DateTime? startDate, DateTime? endDate) {
            startDate ??= DateTime.Now.AddMonths(-1);
            StartDate = startDate ?? DateTime.Now.AddMonths(-1);
            if (endDate != null) { EndDate = (DateTime)endDate; }
        }
    }
}
