    // Created with scaffold-dbcontext "Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True"
    //      Microsoft.EntityFrameworkCore.SqlServer -context DbContextFileName
    
scaffold-dbcontext "Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True" Microsoft.EntityFrameworkCore.SqlServer -context ChambersDbContext -OutputDir Entities -force

    // .. in the Nuget Package Manager Console after adding Microsoft.EntityFrameworkCore,
    // Microsoft.EntityFrameworkCore.SqlServer and Microsoft.EntityFrameworkCore.Tools Nuget packages
    // to DataModel project and Microsoft.EntityFrameworkCore.Design to Startup project

    // Created with scaffold-dbcontext "Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True" -force
 

    //To protect potentially sensitive information in your connection string,
    //you should move it out of source code. You can avoid scaffolding the connection
    //string by using the Name= syntax to read it from configuration
    //- see https://go.microsoft.com/fwlink/?linkid=2131148.
    //For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263