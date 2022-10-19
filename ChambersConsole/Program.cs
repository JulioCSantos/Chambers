// See https://aka.ms/new-console-template for more information

using ChambersDataModel;

var dbContext = new ChambersDbContext();
Console.WriteLine("Hello, " + dbContext.Database);
