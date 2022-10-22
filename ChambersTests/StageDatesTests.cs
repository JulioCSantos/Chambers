using ChambersDataModel;
using ChambersTests.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests
{
    public  class StageDatesTests
    {
        #region Context
        // ReSharper disable once InconsistentNaming
        private  static readonly ChambersDbContext imContext = BootStrap.InMemoryDbcontext;
        #endregion Context

        #region name
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StageDatesTests) + "_" + name;
            return newName;
        }
        #endregion name

        public static StagesDate NewStageDate([CallerMemberName] string? name = null) {
            var stage = StagesTests.NewStage(name);
            imContext.Stages.Add(stage);
            var stagesDate = new StagesDate() { Stage = stage };
;
            return stagesDate;
        }

        public void InsertStageDateTest()
        {
            var insertStageDate = NewStageDate(nameof(InsertStageDateTest));
            insertStageDate.StartDate = DateTime.Now;
            insertStageDate.EndDate = insertStageDate.StartDate.AddYears(1).AddDays(-1);
            imContext.StagesDates.Add(insertStageDate);

        }
    }
}
