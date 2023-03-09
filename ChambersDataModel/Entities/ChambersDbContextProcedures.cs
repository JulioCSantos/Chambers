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
    public partial class ChambersDbContext
    {
        private IChambersDbContextProcedures _procedures;

        public virtual IChambersDbContextProcedures Procedures
        {
            get
            {
                if (_procedures is null) _procedures = new ChambersDbContextProcedures(this);
                return _procedures;
            }
            set
            {
                _procedures = value;
            }
        }

        public IChambersDbContextProcedures GetProcedures()
        {
            return Procedures;
        }

        protected void OnModelCreatingGeneratedProcedures(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<GetBAUExcursionsResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<spDriverExcursionsPointsForDateResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<spMergeIncompleteCyclesResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<spPivotExcursionPointsResult>().HasNoKey().ToView(null);
        }
    }

    public partial class ChambersDbContextProcedures : IChambersDbContextProcedures
    {
        private readonly ChambersDbContext _context;

        public ChambersDbContextProcedures(ChambersDbContext context)
        {
            _context = context;
        }

        public virtual async Task<List<GetBAUExcursionsResult>> GetBAUExcursionsAsync(string TagsList, DateTime? AfterDate, DateTime? BeforeDate, int? DurationThreshold, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new []
            {
                new SqlParameter
                {
                    ParameterName = "TagsList",
                    Size = -1,
                    Value = TagsList ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                new SqlParameter
                {
                    ParameterName = "AfterDate",
                    Value = AfterDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "BeforeDate",
                    Value = BeforeDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "DurationThreshold",
                    Value = DurationThreshold ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<GetBAUExcursionsResult>("EXEC @returnValue = [dbo].[GetBAUExcursions] @TagsList, @AfterDate, @BeforeDate, @DurationThreshold", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<spDriverExcursionsPointsForDateResult>> spDriverExcursionsPointsForDateAsync(DateTime? ForDate, int? StageDateId, string TagName, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new []
            {
                new SqlParameter
                {
                    ParameterName = "ForDate",
                    Value = ForDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "StageDateId",
                    Value = StageDateId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "TagName",
                    Size = 255,
                    Value = TagName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spDriverExcursionsPointsForDateResult>("EXEC @returnValue = [dbo].[spDriverExcursionsPointsForDate] @ForDate, @StageDateId, @TagName", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<int> spGetStatsAsync(string TagName, DateTime? FirstExcDate, DateTime? LastExcDate, OutputParameter<double?> MinValue, OutputParameter<double?> MaxValue, OutputParameter<double?> AvergValue, OutputParameter<double?> StdDevValue, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterMinValue = new SqlParameter
            {
                ParameterName = "MinValue",
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = MinValue?._value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.Float,
            };
            var parameterMaxValue = new SqlParameter
            {
                ParameterName = "MaxValue",
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = MaxValue?._value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.Float,
            };
            var parameterAvergValue = new SqlParameter
            {
                ParameterName = "AvergValue",
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = AvergValue?._value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.Float,
            };
            var parameterStdDevValue = new SqlParameter
            {
                ParameterName = "StdDevValue",
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = StdDevValue?._value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.Float,
            };
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new []
            {
                new SqlParameter
                {
                    ParameterName = "TagName",
                    Size = 255,
                    Value = TagName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                new SqlParameter
                {
                    ParameterName = "FirstExcDate",
                    Value = FirstExcDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "LastExcDate",
                    Value = LastExcDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                parameterMinValue,
                parameterMaxValue,
                parameterAvergValue,
                parameterStdDevValue,
                parameterreturnValue,
            };
            var _ = await _context.Database.ExecuteSqlRawAsync("EXEC @returnValue = [dbo].[spGetStats] @TagName, @FirstExcDate, @LastExcDate, @MinValue OUTPUT, @MaxValue OUTPUT, @AvergValue OUTPUT, @StdDevValue OUTPUT", sqlParameters, cancellationToken);

            MinValue.SetValue(parameterMinValue.Value);
            MaxValue.SetValue(parameterMaxValue.Value);
            AvergValue.SetValue(parameterAvergValue.Value);
            StdDevValue.SetValue(parameterStdDevValue.Value);
            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<spMergeIncompleteCyclesResult>> spMergeIncompleteCyclesAsync(OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new []
            {
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spMergeIncompleteCyclesResult>("EXEC @returnValue = [dbo].[spMergeIncompleteCycles]", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<spPivotExcursionPointsResult>> spPivotExcursionPointsAsync(string TagName, DateTime? StartDate, DateTime? EndDate, double? LowThreashold, double? HiThreashold, int? TagId, int? StepLogId, int? ThresholdDuration, double? SetPoint, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new []
            {
                new SqlParameter
                {
                    ParameterName = "TagName",
                    Size = 255,
                    Value = TagName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                new SqlParameter
                {
                    ParameterName = "StartDate",
                    Value = StartDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "EndDate",
                    Value = EndDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "LowThreashold",
                    Value = LowThreashold ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Float,
                },
                new SqlParameter
                {
                    ParameterName = "HiThreashold",
                    Value = HiThreashold ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Float,
                },
                new SqlParameter
                {
                    ParameterName = "TagId",
                    Value = TagId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "StepLogId",
                    Value = StepLogId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "ThresholdDuration",
                    Value = ThresholdDuration ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "SetPoint",
                    Value = SetPoint ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Float,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spPivotExcursionPointsResult>("EXEC @returnValue = [dbo].[spPivotExcursionPoints] @TagName, @StartDate, @EndDate, @LowThreashold, @HiThreashold, @TagId, @StepLogId, @ThresholdDuration, @SetPoint", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }
    }
}
