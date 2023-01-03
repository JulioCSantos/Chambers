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
            modelBuilder.Entity<spDriverExcursionsPointsForDateResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<spGetStagesLimitsAndDatesResult>().HasNoKey().ToView(null);
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

        public virtual async Task<List<spGetStagesLimitsAndDatesResult>> spGetStagesLimitsAndDatesAsync(int? TagId, DateTime? DateTime, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "TagId",
                    Value = TagId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "DateTime",
                    Value = DateTime ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spGetStagesLimitsAndDatesResult>("EXEC @returnValue = [dbo].[spGetStagesLimitsAndDates] @TagId, @DateTime", sqlParameters, cancellationToken);

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

        public virtual async Task<List<spPivotExcursionPointsResult>> spPivotExcursionPointsAsync(string TagName, DateTime? StartDate, DateTime? EndDate, double? LowThreashold, double? HiThreashold, int? TagId, int? StepLogId, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spPivotExcursionPointsResult>("EXEC @returnValue = [dbo].[spPivotExcursionPoints] @TagName, @StartDate, @EndDate, @LowThreashold, @HiThreashold, @TagId, @StepLogId", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }
    }
}
