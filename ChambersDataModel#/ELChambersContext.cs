using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace ChambersDataModel
{
    public partial class ELChambersContext : DbContext
    {
        public ELChambersContext()
        {
        }

        public ELChambersContext(DbContextOptions<ELChambersContext> options)
            : base(options)
        {
        }

        public virtual DbSet<CollectionPointsPaceLogCalc> CollectionPointsPaceLogCalcs { get; set; } = null!;
        public virtual DbSet<CompValue> CompValues { get; set; } = null!;
        public virtual DbSet<Excursion> Excursions { get; set; } = null!;
        public virtual DbSet<ExcursionPoint> ExcursionPoints { get; set; } = null!;
        public virtual DbSet<ExcursionType> ExcursionTypes { get; set; } = null!;
        public virtual DbSet<PointsPace> PointsPaces { get; set; } = null!;
        public virtual DbSet<PointsPacesLog> PointsPacesLogs { get; set; } = null!;
        public virtual DbSet<Stage> Stages { get; set; } = null!;
        public virtual DbSet<StagesDate> StagesDates { get; set; } = null!;
        public virtual DbSet<StagesLimitsAndDate> StagesLimitsAndDates { get; set; } = null!;
        public virtual DbSet<Tag> Tags { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CollectionPointsPaceLogCalc>(entity =>
            {
                entity.HasNoKey();

                entity.ToView("CollectionPointsPaceLogCalc");

                entity.Property(e => e.StageName).HasMaxLength(255);

                entity.Property(e => e.StepEndTime).HasColumnType("datetime");

                entity.Property(e => e.StepStartTime).HasColumnType("datetime");
            });

            modelBuilder.Entity<CompValue>(entity =>
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

                entity.HasIndex(e => e.RampinPointId, "IX_Excursions_RampinPointId");

                entity.Property(e => e.ExcursionId).ValueGeneratedOnAdd();

                entity.Property(e => e.RampInDateTime).HasColumnType("datetime");

                entity.Property(e => e.RampOutDateTime).HasColumnType("datetime");

                entity.HasOne(d => d.RampOutPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampOutPointId)
                    .HasConstraintName("fkExcursionsPointId_ExcursionsRampOutPointId");

                entity.HasOne(d => d.RampinPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampinPointId)
                    .HasConstraintName("fkExcursionsPointId_ExcursionsRampInPointId");
            });

            modelBuilder.Entity<ExcursionPoint>(entity =>
            {
                entity.HasKey(e => e.PointId)
                    .HasName("pkExcursionPointsPointId");

                entity.HasIndex(e => e.ExcursionType, "IX_ExcursionPoints_ExcursionType");

                entity.HasIndex(e => e.PaceLogId, "IX_ExcursionPoints_PaceLogId");

                entity.Property(e => e.ValueDate).HasColumnType("datetime");

                entity.HasOne(d => d.ExcursionTypeNavigation)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.ExcursionType)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkExcursionTypesExcursionType_ExcursionPointsExcursionType");

                entity.HasOne(d => d.PaceLog)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.PaceLogId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkPointsPacesLogPaceLogId_ExcursionPointsPaceLogId");
            });

            modelBuilder.Entity<ExcursionType>(entity =>
            {
                entity.HasKey(e => e.ExcursionType1)
                    .HasName("PK__Excursio__B449CF3A168138C4");

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

                entity.Property(e => e.NestStepEndTime)
                    .HasColumnType("datetime")
                    .HasComputedColumnSql("(dateadd(day,[StepSizeDays],[NextStepStartTime]))", false);

                entity.Property(e => e.NextStepStartTime).HasColumnType("datetime");

                entity.HasOne(d => d.Tag)
                    .WithMany(p => p.PointsPaces)
                    .HasForeignKey(d => d.TagId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkTagsTagId_PointsPacesTagId");
            });

            modelBuilder.Entity<PointsPacesLog>(entity =>
            {
                entity.HasKey(e => e.PaceLogId)
                    .HasName("pkPointsPacesLogPaceLogId");

                entity.ToTable("PointsPacesLog");

                entity.HasIndex(e => e.PaceId, "IX_CollectionPointsPaceLog_PaceId");

                entity.HasIndex(e => e.StageDatesId, "IX_CollectionPointsPaceLog_StageDatesId");

                entity.Property(e => e.StepEndTime).HasColumnType("datetime");

                entity.Property(e => e.StepStartTime).HasColumnType("datetime");

                entity.HasOne(d => d.Pace)
                    .WithMany(p => p.PointsPacesLogs)
                    .HasForeignKey(d => d.PaceId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkPointsPacesPaceId_PointsPaceLog");

                entity.HasOne(d => d.StageDates)
                    .WithMany(p => p.PointsPacesLogs)
                    .HasForeignKey(d => d.StageDatesId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("fkStagesDatesStageDateId_PointsPacesLogStageDatesId");
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
                entity.Property(e => e.TagId).ValueGeneratedNever();

                entity.Property(e => e.TagName).HasMaxLength(255);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
