﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace ChambersDataModel.Entities
{
    public partial class ChambersDbContext : DbContext
    {
        public ChambersDbContext()
        {
        }

        public ChambersDbContext(DbContextOptions<ChambersDbContext> options)
            : base(options)
        {
        }

        public virtual DbSet<CompressedPoint> CompressedPoints { get; set; }
        public virtual DbSet<DefaultPointsPace> DefaultPointsPaces { get; set; }
        public virtual DbSet<ExcursionPoint> ExcursionPoints { get; set; }
        public virtual DbSet<ExcursionStat> ExcursionStats { get; set; }
        public virtual DbSet<Interpolated> Interpolateds { get; set; }
        public virtual DbSet<PointsPace> PointsPaces { get; set; }
        public virtual DbSet<PointsStepsLog> PointsStepsLogs { get; set; }
        public virtual DbSet<PointsStepsLogNextValue> PointsStepsLogNextValues { get; set; }
        public virtual DbSet<Stage> Stages { get; set; }
        public virtual DbSet<StagesDate> StagesDates { get; set; }
        public virtual DbSet<StagesLimitsAndDate> StagesLimitsAndDates { get; set; }
        public virtual DbSet<Tag> Tags { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CompressedPoint>(entity =>
            {
                entity.HasKey(e => new { e.Tag, e.Time, e.Value })
                    .HasName("pkCompressedPoints");

                entity.Property(e => e.Tag)
                    .HasMaxLength(255)
                    .IsUnicode(false)
                    .HasColumnName("tag");

                entity.Property(e => e.Time)
                    .HasColumnType("datetime")
                    .HasColumnName("time");

                entity.Property(e => e.Value).HasColumnName("value");
            });

            modelBuilder.Entity<DefaultPointsPace>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("DefaultPointsPaces");

                entity.Property(e => e.NextStepStartDate).HasColumnType("datetime");
            });

            modelBuilder.Entity<ExcursionPoint>(entity =>
            {
                entity.HasKey(e => e.CycleId)
                    .HasName("pkExcursionPointsCycleId")
                    .IsClustered(false);

                entity.HasIndex(e => new { e.TagName, e.TagExcNbr, e.RampInDate }, "ixExcursionPointsRampInDateTagNameTagExcNbr")
                    .IsClustered();

                entity.HasIndex(e => new { e.TagName, e.TagExcNbr, e.RampOutDate }, "ixExcursionPointsRampoutDateTagNameTagExcNbr");

                entity.Property(e => e.ExcursionLength).HasComputedColumnSql("(datediff(minute,[RampInDate],[RampOutDate]))", false);

                entity.Property(e => e.FirstExcDate).HasColumnType("datetime");

                entity.Property(e => e.LastExcDate).HasColumnType("datetime");

                entity.Property(e => e.RampInDate).HasColumnType("datetime");

                entity.Property(e => e.RampOutDate).HasColumnType("datetime");

                entity.Property(e => e.TagName)
                    .IsRequired()
                    .HasMaxLength(255)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<ExcursionStat>(entity =>
            {
                entity.HasKey(e => new { e.TagName, e.TagExcNbr });

                entity.Property(e => e.TagName)
                    .HasMaxLength(255)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<Interpolated>(entity =>
            {
                entity.HasKey(e => new { e.Tag, e.Time })
                    .HasName("pkInterpolated");

                entity.ToTable("Interpolated");

                entity.Property(e => e.Tag)
                    .HasMaxLength(20)
                    .IsUnicode(false)
                    .HasColumnName("tag");
            });

            modelBuilder.Entity<PointsPace>(entity =>
            {
                entity.HasKey(e => e.PaceId)
                    .HasName("pcPointsPacesPaceId")
                    .IsClustered(false);

                entity.HasIndex(e => e.StageDateId, "ixPointsPacesStageDateId")
                    .IsClustered();

                entity.Property(e => e.NextStepEndDate)
                    .HasColumnType("datetime")
                    .HasComputedColumnSql("(dateadd(day,[StepSizeDays],[NextStepStartDate]))", false);

                entity.Property(e => e.NextStepStartDate).HasColumnType("datetime");

                entity.Property(e => e.ProcessedDate).HasColumnType("datetime");

                entity.Property(e => e.StepSizeDays).HasDefaultValueSql("((2))");

                entity.HasOne(d => d.StageDate)
                    .WithMany(p => p.PointsPaces)
                    .HasForeignKey(d => d.StageDateId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkPointsPacesStageDateId_StagesDatesStageDateId");
            });

            modelBuilder.Entity<PointsStepsLog>(entity =>
            {
                entity.HasKey(e => e.StepLogId)
                    .HasName("pkPointsStepsLogPaceLogId");

                entity.ToTable("PointsStepsLog");

                entity.Property(e => e.EndDate).HasColumnType("datetime");

                entity.Property(e => e.PaceEndDate).HasColumnType("datetime");

                entity.Property(e => e.PaceStartDate).HasColumnType("datetime");

                entity.Property(e => e.StageEndDate).HasColumnType("datetime");

                entity.Property(e => e.StageName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.StageStartDate).HasColumnType("datetime");

                entity.Property(e => e.StartDate).HasColumnType("datetime");

                entity.Property(e => e.TagName)
                    .IsRequired()
                    .HasMaxLength(255)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<PointsStepsLogNextValue>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("PointsStepsLogNextValues");

                entity.Property(e => e.EndDate).HasColumnType("datetime");

                entity.Property(e => e.PaceEndDate).HasColumnType("datetime");

                entity.Property(e => e.PaceStartDate).HasColumnType("datetime");

                entity.Property(e => e.StageEndDate).HasColumnType("datetime");

                entity.Property(e => e.StageName).HasMaxLength(255);

                entity.Property(e => e.StageStartDate).HasColumnType("datetime");

                entity.Property(e => e.StartDate).HasColumnType("datetime");

                entity.Property(e => e.TagName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<Stage>(entity =>
            {
                entity.HasIndex(e => new { e.TagId, e.StageName }, "IxTagStageName")
                    .IsUnique()
                    .HasFilter("([StageName] IS NOT NULL)");

                entity.Property(e => e.DeprecatedDate).HasColumnType("datetime");

                entity.Property(e => e.MaxThreshold).HasDefaultValueSql("((3.4000000000000000e+038))");

                entity.Property(e => e.ProductionDate).HasColumnType("datetime");

                entity.Property(e => e.StageName).HasMaxLength(255);

                entity.HasOne(d => d.Tag)
                    .WithMany(p => p.Stages)
                    .HasForeignKey(d => d.TagId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("TagsTagId2StagesTagId");
            });

            modelBuilder.Entity<StagesDate>(entity =>
            {
                entity.HasKey(e => e.StageDateId)
                    .HasName("pkStagesDatesStageDateId");

                entity.HasIndex(e => new { e.StageId, e.StartDate }, "IxStagesDatesTagIdStartDate");

                entity.Property(e => e.DeprecatedDate).HasColumnType("datetime");

                entity.Property(e => e.EndDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("('9999-12-31 11:11:59')");

                entity.Property(e => e.StartDate).HasColumnType("datetime");

                entity.HasOne(d => d.Stage)
                    .WithMany(p => p.StagesDates)
                    .HasForeignKey(d => d.StageId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FkStagesStageId_StageId");
            });

            modelBuilder.Entity<StagesLimitsAndDate>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("StagesLimitsAndDates");

                entity.Property(e => e.EndDate).HasColumnType("datetime");

                entity.Property(e => e.StageName).HasMaxLength(255);

                entity.Property(e => e.StartDate).HasColumnType("datetime");

                entity.Property(e => e.TagName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<Tag>(entity =>
            {
                entity.HasIndex(e => e.TagName, "ixTagsTagName");

                entity.Property(e => e.TagId).ValueGeneratedNever();

                entity.Property(e => e.TagName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            OnModelCreatingGeneratedProcedures(modelBuilder);
            OnModelCreatingGeneratedFunctions(modelBuilder);
            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}