﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using ChambersDataModel.Entities;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial interface IChambersDbContextProcedures
    {
        Task<List<spDriverExcursionsPointsForDateResult>> spDriverExcursionsPointsForDateAsync(DateTime? ForDate, int? StageDateId, string TagName, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<spGetStagesLimitsAndDatesResult>> spGetStagesLimitsAndDatesAsync(int? TagId, DateTime? DateTime, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<spPivotExcursionPointsResult>> spPivotExcursionPointsAsync(string TagName, DateTime? StartDate, DateTime? EndDate, double? LowThreashold, double? HiThreashold, int? TagId, int? StepLogId, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
    }
}
