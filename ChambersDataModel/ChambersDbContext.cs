using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace ChambersDataModel
{
    // Created with scaffold-dbcontext "Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True"
    //      Microsoft.EntityFrameworkCore.SqlServer -context 
    // .. in the Nuget Package Manager Console after adding Microsoft.EntityFrameworkCore,
    // Microsoft.EntityFrameworkCore.SqlServer and Microsoft.EntityFrameworkCore.Tools Nuget packages
    // to DataModel project and Microsoft.EntityFrameworkCore.Design to Startup project

    //To protect potentially sensitive information in your connection string,
    //you should move it out of source code. You can avoid scaffolding the connection
    //string by using the Name= syntax to read it from configuration
    //- see https://go.microsoft.com/fwlink/?linkid=2131148.
    //For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263
    public partial class ChambersDbContext : DbContext
    {
        public ChambersDbContext()
        {
        }

        public ChambersDbContext(DbContextOptions<ChambersDbContext> options)
            : base(options)
        {
        }

        public virtual DbSet<CollectionPointsPace> CollectionPointsPaces { get; set; } = null!;
        public virtual DbSet<CollectionPointsPaceLog> CollectionPointsPaceLogs { get; set; } = null!;
        public virtual DbSet<CollectionPointsPaceLogCalc> CollectionPointsPaceLogCalcs { get; set; } = null!;
        public virtual DbSet<CompValue> CompValues { get; set; } = null!;
        public virtual DbSet<Excursion> Excursions { get; set; } = null!;
        public virtual DbSet<ExcursionPoint> ExcursionPoints { get; set; } = null!;
        public virtual DbSet<ExcursionType> ExcursionTypes { get; set; } = null!;
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
            modelBuilder.Entity<CollectionPointsPace>(entity =>
            {
                entity.HasKey(e => e.PaceId)
                    .HasName("PK__Collecti__F7F38BBDBAF2C721");

                entity.ToTable("CollectionPointsPace");

                entity.Property(e => e.NestStepEndTime)
                    .HasColumnType("datetime")
                    .HasComputedColumnSql("(dateadd(day,[StepSizeDays],[NextStepStartTime]))", false);

                entity.Property(e => e.NextStepStartTime).HasColumnType("datetime");

                entity.HasOne(d => d.Tag)
                    .WithMany(p => p.CollectionPointsPaces)
                    .HasForeignKey(d => d.TagId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Collectio__TagId__36B12243");
            });

            modelBuilder.Entity<CollectionPointsPaceLog>(entity =>
            {
                entity.HasKey(e => e.PaceLogId)
                    .HasName("PK__Collecti__B49BB7D0F52C5D73");

                entity.ToTable("CollectionPointsPaceLog");

                entity.Property(e => e.StepEndTime).HasColumnType("datetime");

                entity.Property(e => e.StepStartTime).HasColumnType("datetime");

                entity.HasOne(d => d.Pace)
                    .WithMany(p => p.CollectionPointsPaceLogs)
                    .HasForeignKey(d => d.PaceId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Collectio__PaceI__37A5467C");

                entity.HasOne(d => d.StageDates)
                    .WithMany(p => p.CollectionPointsPaceLogs)
                    .HasForeignKey(d => d.StageDatesId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Collectio__Stage__38996AB5");
            });

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

                entity.Property(e => e.ExcursionId).ValueGeneratedOnAdd();

                entity.Property(e => e.RampInDateTime).HasColumnType("datetime");

                entity.Property(e => e.RampOutDateTime).HasColumnType("datetime");

                entity.HasOne(d => d.RampOutPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampOutPointId)
                    .HasConstraintName("FK__Excursion__RampO__3C69FB99");

                entity.HasOne(d => d.RampinPoint)
                    .WithMany()
                    .HasForeignKey(d => d.RampinPointId)
                    .HasConstraintName("FK__Excursion__Rampi__3B75D760");
            });

            modelBuilder.Entity<ExcursionPoint>(entity =>
            {
                entity.HasKey(e => e.PointId)
                    .HasName("PK__Excursio__40A977E1FEC34C08");

                entity.Property(e => e.ValueDate).HasColumnType("datetime");

                entity.HasOne(d => d.ExcursionTypeNavigation)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.ExcursionType)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Excursion__Excur__398D8EEE");

                entity.HasOne(d => d.PaceLog)
                    .WithMany(p => p.ExcursionPoints)
                    .HasForeignKey(d => d.PaceLogId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Excursion__PaceL__3A81B327");
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

            modelBuilder.Entity<Stage>(entity =>
            {
                entity.HasIndex(e => new { e.TagId, e.StageName }, "IxTagStageName")
                    .IsUnique();

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
                    .HasName("PK__StagesDa__CBAD5D1F69D91647");

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
