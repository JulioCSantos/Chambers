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
        Task<List<CreateCompressedPointResult>> CreateCompressedPointAsync(string CurveName, string tagName, int? offsetDays, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<GetBAUExcursionsResult>> GetBAUExcursionsAsync(string TagsList, DateTime? AfterDate, DateTime? BeforeDate, int? DurationThreshold, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<spDriverExcursionsPointsForDateResult>> spDriverExcursionsPointsForDateAsync(DateTime? FromDate, DateTime? ToDate, string StageDateIds, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<int> spGetStatsAsync(string TagName, DateTime? FirstExcDate, DateTime? LastExcDate, OutputParameter<double?> MinValue, OutputParameter<double?> MaxValue, OutputParameter<double?> AvergValue, OutputParameter<double?> StdDevValue, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<spPivotExcursionPointsResult>> spPivotExcursionPointsAsync(string TagName, DateTime? StartDate, DateTime? EndDate, double? LowThreashold, double? HiThreashold, TimeSpan? TimeStep, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<int> spSeedForTestsAsync(OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
    }
}
