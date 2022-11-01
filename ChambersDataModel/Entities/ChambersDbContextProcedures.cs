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
            modelBuilder.Entity<spGetCompressedPointsResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<spGetStagesLimitsAndDatesResult>().HasNoKey().ToView(null);
        }
    }

    public partial class ChambersDbContextProcedures : IChambersDbContextProcedures
    {
        private readonly ChambersDbContext _context;

        public ChambersDbContextProcedures(ChambersDbContext context)
        {
            _context = context;
        }

        public virtual async Task<List<spGetCompressedPointsResult>> spGetCompressedPointsAsync(string TagName, DateTime? StartDate, DateTime? EndDate, double? LowThreshold, double? HiThreashold, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "LowThreshold",
                    Value = LowThreshold ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Float,
                },
                new SqlParameter
                {
                    ParameterName = "HiThreashold",
                    Value = HiThreashold ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Float,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<spGetCompressedPointsResult>("EXEC @returnValue = [dbo].[spGetCompressedPoints] @TagName, @StartDate, @EndDate, @LowThreshold, @HiThreashold", sqlParameters, cancellationToken);

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
    }
}
