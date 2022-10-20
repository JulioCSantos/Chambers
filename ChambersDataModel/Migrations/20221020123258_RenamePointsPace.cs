using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChambersDataModel.Migrations
{
    //https://learn.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.migrations.migrationbuilder.renametable?view=efcore-6.0#microsoft-entityframeworkcore-migrations-migrationbuilder-renametable(system-string-system-string-system-string-system-string)
    public partial class RenamePointsPace : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: nameof(CollectionPointsPace), 
                newName: "PointsPace"
            );
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "PointsPace",
                newName: nameof(CollectionPointsPace)
            );
        }
    }
}
