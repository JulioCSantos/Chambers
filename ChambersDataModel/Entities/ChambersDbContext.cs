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

        public virtual DbSet<CompressedPoint> CompressedPoints { get; set; } = null!;
        public virtual DbSet<Excursion> Excursions { get; set; } = null!;
        public virtual DbSet<ExcursionPoint> ExcursionPoints { get; set; } = null!;
        public virtual DbSet<ExcursionType> ExcursionTypes { get; set; } = null!;
        public virtual DbSet<PointsPace> PointsPaces { get; set; } = null!;
        public virtual DbSet<PointsStepsLog> PointsStepsLogs { get; set; } = null!;
        public virtual DbSet<PointsStepsLogNextValue> PointsStepsLogNextValues { get; set; } = null!;
        public virtual DbSet<Stage> Stages { get; set; } = null!;
        public virtual DbSet<StagesDate> StagesDates { get; set; } = null!;
        public virtual DbSet<StagesLimitsAndDate> StagesLimitsAndDates { get; set; } = null!;
        public virtual DbSet<Tag> Tags { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CompressedPoint>(entity =>
            {
                entity.HasNoKey();

                entity.Property(e => e.Tag)
                    .HasMaxLength(255)
                    .IsUnicode(false)
                    .HasColumnName("tag");

                entity.Property(e => e.Time)
                    .HasColumnType("datetime")
                    .HasColumnName("time");

                entity.Property(e => e.Value).HasColumnName("value");
            });

            modelBuilder.Entity<Excursion>(entity =>
            {
                entity.HasNoKey();

                entity.HasIndex(e => e.RampOutPointId, "IX_Excursions_RampOutPointId");

                entity.HasIndex(e => e.RampInPointId, "IX_Excursions_RampinPointId");

                entity.Property(e => e.ExcursionId).ValueGeneratedOnAdd();

                entity.Property(e => e.RampInDateTime).HasColumnType("datetime");

                entity.Property(e => e.RampOutDateTime).HasColumnType("datetime");

                entity.HasOne(d => d.RampInPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampInPointId)
                    .HasConstraintName("fkExcursionsPointId_ExcursionsRampInPointId");

                entity.HasOne(d => d.RampOutPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampOutPointId)
                    .HasConstraintName("fkExcursionsPointId_ExcursionsRampOutPointId");
            });

            modelBuilder.Entity<ExcursionPoint>(entity =>
            {
                entity.HasKey(e => e.PointId)
                    .HasName("pkExcursionPointsPointId");

                entity.HasIndex(e => e.ExcursionType, "IX_ExcursionPoints_ExcursionType");

                entity.HasIndex(e => e.StepLogId, "IX_ExcursionPoints_PaceLogId");

                entity.Property(e => e.ValueDate).HasColumnType("datetime");

                entity.HasOne(d => d.ExcursionTypeNavigation)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.ExcursionType)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkExcursionTypesExcursionType_ExcursionPointsExcursionType");

                entity.HasOne(d => d.StepLog)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.StepLogId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkPointsStepsLogStepLogId_ExcursionPointsStepLogId");
            });

            modelBuilder.Entity<ExcursionType>(entity =>
            {
                entity.HasKey(e => e.ExcursionType1)
                    .HasName("pkExcursionType");

                entity.Property(e => e.ExcursionType1)
                    .ValueGeneratedNever()
                    .HasColumnName("ExcursionType");

                entity.Property(e => e.ExcursionDescription).HasMaxLength(255);
            });

            modelBuilder.Entity<PointsPace>(entity =>
            {
                entity.HasKey(e => e.PaceId)
                    .HasName("pkPointsPacesPointId");

                entity.HasIndex(e => e.TagId, "IX_CollectionPointsPace_TagId");

                entity.Property(e => e.NextStepEndDate)
                    .HasColumnType("datetime")
                    .HasComputedColumnSql("(dateadd(day,[StepSizeDays],[NextStepStartDate]))", false);

                entity.Property(e => e.NextStepStartDate).HasColumnType("datetime");

                entity.HasOne(d => d.Tag)
                    .WithMany(p => p.PointsPaces)
                    .HasForeignKey(d => d.TagId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkTagsTagId_PointsPacesTagId");
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

                entity.Property(e => e.StageName).HasMaxLength(255);

                entity.Property(e => e.StageStartDate).HasColumnType("datetime");

                entity.Property(e => e.StartDate).HasColumnType("datetime");

                entity.Property(e => e.TagName)
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

                entity.Property(e => e.TagName).HasMaxLength(255);
            });

            modelBuilder.Entity<Stage>(entity =>
            {
                entity.HasIndex(e => new { e.TagId, e.StageName }, "IxTagStageName")
                    .IsUnique()
                    .HasFilter("([StageName] IS NOT NULL)");

                entity.Property(e => e.MaxValue).HasDefaultValueSql("((3.4000000000000000e+038))");

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
            });

            modelBuilder.Entity<Tag>(entity =>
            {
                entity.HasIndex(e => e.TagName, "ixTagsTagName");

                entity.Property(e => e.TagId).ValueGeneratedNever();

                entity.Property(e => e.TagName).HasMaxLength(255);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
