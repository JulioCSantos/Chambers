using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChambersDataModel.Migrations
{
    public partial class Firstdraft : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CompValues",
                columns: table => new
                {
                    tag = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: false),
                    time = table.Column<DateTime>(type: "datetime", nullable: false),
                    value = table.Column<double>(type: "float", nullable: false)
                },
                constraints: table =>
                {
                });

            migrationBuilder.CreateTable(
                name: "ExcursionTypes",
                columns: table => new
                {
                    ExcursionType = table.Column<int>(type: "int", nullable: false),
                    ExcursionDescription = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Excursio__B449CF3A168138C4", x => x.ExcursionType);
                });

            migrationBuilder.CreateTable(
                name: "Tags",
                columns: table => new
                {
                    TagId = table.Column<int>(type: "int", nullable: false),
                    TagName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tags", x => x.TagId);
                });

            migrationBuilder.CreateTable(
                name: "CollectionPointsPace",
                columns: table => new
                {
                    PaceId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TagId = table.Column<int>(type: "int", nullable: false),
                    NextStepStartTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    StepSizeDays = table.Column<int>(type: "int", nullable: false),
                    NestStepEndTime = table.Column<DateTime>(type: "datetime", nullable: true, computedColumnSql: "(dateadd(day,[StepSizeDays],[NextStepStartTime]))", stored: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Collecti__F7F38BBDBAF2C721", x => x.PaceId);
                    table.ForeignKey(
                        name: "FK__Collectio__TagId__36B12243",
                        column: x => x.TagId,
                        principalTable: "Tags",
                        principalColumn: "TagId");
                });

            migrationBuilder.CreateTable(
                name: "Stages",
                columns: table => new
                {
                    StageId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TagId = table.Column<int>(type: "int", nullable: false),
                    StageName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    MinValue = table.Column<double>(type: "float", nullable: false),
                    MaxValue = table.Column<double>(type: "float", nullable: false, defaultValueSql: "((3.4000000000000000e+038))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stages", x => x.StageId);
                    table.ForeignKey(
                        name: "TagsTagId2StagesTagId",
                        column: x => x.TagId,
                        principalTable: "Tags",
                        principalColumn: "TagId");
                });

            migrationBuilder.CreateTable(
                name: "StagesDates",
                columns: table => new
                {
                    StageDateId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StageId = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "('9999-12-31 11:11:59')")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__StagesDa__CBAD5D1F69D91647", x => x.StageDateId);
                    table.ForeignKey(
                        name: "FkStagesStageId_StageId",
                        column: x => x.StageId,
                        principalTable: "Stages",
                        principalColumn: "StageId");
                });

            migrationBuilder.CreateTable(
                name: "CollectionPointsPaceLog",
                columns: table => new
                {
                    PaceLogId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaceId = table.Column<int>(type: "int", nullable: false),
                    StageDatesId = table.Column<int>(type: "int", nullable: false),
                    StepStartTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    StepEndTime = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Collecti__B49BB7D0F52C5D73", x => x.PaceLogId);
                    table.ForeignKey(
                        name: "FK__Collectio__PaceI__37A5467C",
                        column: x => x.PaceId,
                        principalTable: "CollectionPointsPace",
                        principalColumn: "PaceId");
                    table.ForeignKey(
                        name: "FK__Collectio__Stage__38996AB5",
                        column: x => x.StageDatesId,
                        principalTable: "StagesDates",
                        principalColumn: "StageDateId");
                });

            migrationBuilder.CreateTable(
                name: "ExcursionPoints",
                columns: table => new
                {
                    PointId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ValueDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    Value = table.Column<double>(type: "float", nullable: false),
                    TagId = table.Column<int>(type: "int", nullable: false),
                    ExcursionType = table.Column<int>(type: "int", nullable: false),
                    PaceLogId = table.Column<int>(type: "int", nullable: false),
                    MinValue = table.Column<double>(type: "float", nullable: false),
                    MaxValue = table.Column<double>(type: "float", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Excursio__40A977E1FEC34C08", x => x.PointId);
                    table.ForeignKey(
                        name: "FK__Excursion__Excur__398D8EEE",
                        column: x => x.ExcursionType,
                        principalTable: "ExcursionTypes",
                        principalColumn: "ExcursionType");
                    table.ForeignKey(
                        name: "FK__Excursion__PaceL__3A81B327",
                        column: x => x.PaceLogId,
                        principalTable: "CollectionPointsPaceLog",
                        principalColumn: "PaceLogId");
                });

            migrationBuilder.CreateTable(
                name: "Excursions",
                columns: table => new
                {
                    ExcursionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TagId = table.Column<int>(type: "int", nullable: false),
                    RampInDateTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    RampOutDateTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    RampinPointId = table.Column<int>(type: "int", nullable: true),
                    RampOutPointId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.ForeignKey(
                        name: "FK__Excursion__Rampi__3B75D760",
                        column: x => x.RampinPointId,
                        principalTable: "ExcursionPoints",
                        principalColumn: "PointId");
                    table.ForeignKey(
                        name: "FK__Excursion__RampO__3C69FB99",
                        column: x => x.RampOutPointId,
                        principalTable: "ExcursionPoints",
                        principalColumn: "PointId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_CollectionPointsPace_TagId",
                table: "CollectionPointsPace",
                column: "TagId");

            migrationBuilder.CreateIndex(
                name: "IX_CollectionPointsPaceLog_PaceId",
                table: "CollectionPointsPaceLog",
                column: "PaceId");

            migrationBuilder.CreateIndex(
                name: "IX_CollectionPointsPaceLog_StageDatesId",
                table: "CollectionPointsPaceLog",
                column: "StageDatesId");

            migrationBuilder.CreateIndex(
                name: "IX_ExcursionPoints_ExcursionType",
                table: "ExcursionPoints",
                column: "ExcursionType");

            migrationBuilder.CreateIndex(
                name: "IX_ExcursionPoints_PaceLogId",
                table: "ExcursionPoints",
                column: "PaceLogId");

            migrationBuilder.CreateIndex(
                name: "IX_Excursions_RampinPointId",
                table: "Excursions",
                column: "RampinPointId");

            migrationBuilder.CreateIndex(
                name: "IX_Excursions_RampOutPointId",
                table: "Excursions",
                column: "RampOutPointId");

            migrationBuilder.CreateIndex(
                name: "IxTagStageName",
                table: "Stages",
                columns: new[] { "TagId", "StageName" },
                unique: true,
                filter: "[StageName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IxStagesDatesTagIdStartDate",
                table: "StagesDates",
                columns: new[] { "StageId", "StartDate" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CompValues");

            migrationBuilder.DropTable(
                name: "Excursions");

            migrationBuilder.DropTable(
                name: "ExcursionPoints");

            migrationBuilder.DropTable(
                name: "ExcursionTypes");

            migrationBuilder.DropTable(
                name: "CollectionPointsPaceLog");

            migrationBuilder.DropTable(
                name: "CollectionPointsPace");

            migrationBuilder.DropTable(
                name: "StagesDates");

            migrationBuilder.DropTable(
                name: "Stages");

            migrationBuilder.DropTable(
                name: "Tags");
        }
    }
}
