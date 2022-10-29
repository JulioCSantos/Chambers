// See https://aka.ms/new-console-template for more information

using ChambersDataModel;
using ChambersDataModel.Entities;

var dbContext = new ChambersDbContext();
dbContext.SeedDb();
Console.WriteLine("Hello, " + dbContext.Database);
