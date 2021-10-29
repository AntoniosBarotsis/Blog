---
title: "Testing an ASP .NET Core project"
date: 2021-10-29T16:12:35+02:00
draft: true
cover:
  image: "images/x.png"
---

# Introduction

Most Web API templates I could find online do not have testing pre configured in them and the official ones do not have it at all so I thought
that I would make a post about setting up basic unit tests as well as mocking dependencies.

I will be using [XUnit](https://xunit.net/) which is one of the most used testing frameworks for .NET as well as
[FakeItEasy](https://fakeiteasy.github.io/) for mocking.

The API will be the weather forecast template with the addition of a service layer which is what we will be testing. Let's get started!

# Coding

## Creating the project

I will be creating a solution with 2 projects, one being the API and the other one being the one for testing.

We start by creating a folder for the solution:

```bash
mkdir TestingAPI
cd TestingAPI
dotnet new sln
```

We can now create the API project and add it to our solution:

```bash
dotnet new webapi -n src
dotnet sln add src/src.csproj
```

Similarly for our test project:

```bash
dotnet new xunit -n test
dotnet sln add test/test.csproj
```

Running `dotnet run --project src` should spin up the server and sure enough, visiting `https://localhost:5001/weatherforecast`
returns us the expected responce.

## Creating the service

I will create a `Services` folder and inside it add 2 files: a service interface and its implementation

```cs
// IMyDependency.cs
using System.Threading.Tasks;

namespace src.Services
{
    public interface IMyDependency
    {
        Task<string> GetDataFromDatabaseAsync();
    }
}
```

```cs
// MyDependency.cs
using System.Threading.Tasks;

namespace src.Services
{
    public class MyDependency: IMyDependency
    {
        public Task<string> GetDataFromDatabaseAsync()
        {
            return Task.FromResult("Hello From MyDependency!");
        }
    }
}
```

Let's head to our controller and make use of the service we just created there so we can make sure it works:

```cs
// WeatherForecastController.cs
// ...
private readonly ILogger<WeatherForecastController> _logger;
private readonly IMyDependency _dependency;

public WeatherForecastController(ILogger<WeatherForecastController> logger, IMyDependency dependency)
{
    _logger = logger;
    _dependency = dependency;
}
// ...

[HttpGet]
public async Task<IEnumerable<WeatherForecast>> Get()
{
    _logger.LogInformation(await _dependency.GetDataFromDatabaseAsync());
    
    // No changes below this
    var rng = new Random();
    return Enumerable.Range(1, 5).Select(index => new WeatherForecast
    {
        Date = DateTime.Now.AddDays(index),
        TemperatureC = rng.Next(-20, 55),
        Summary = Summaries[rng.Next(Summaries.Length)]
    })
    .ToArray();
}
```

Lastly we head to `Startup.cs` to register the implementation

```cs
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddScoped<IMyDependency, MyDependency>();
    // ...
}
```

If we now run the app and hit the endpoint we should see `Hello From MyDependency!` logged in the console.

## Writing our tests

Let's navigate to our test project and write our first test

```cs
// UnitTest1.cs
using System.Threading.Tasks;
using FakeItEasy;
using src.Services;
using Xunit;

namespace test
{
    public class UnitTest1
    {
        [Fact]
        public async Task Test1()
        {
            var myDependency = new MyDependency();
            Assert.Equal("Hello From MyDependency!", await myDependency.GetDataFromDatabaseAsync());
        }
    }
}
```

Here I changed the return type from `void` to `async Task` since the method we want to test is async. Running the test with
`dotnet test` passes but this is not what we want.

In a normal project this method could require a database connection that we probably do not want to make use of in our tests for various reasons.
This is where mocking comes into play; we can provide a fake implementation to our service methods. It might not be as apparent here why this could
be useful so let me explain.

Usually the way I like to structure my apps is to split them into 3 layers

- Controllers: handle http requests, call service layer
- Services: business logic, call repository layer
- Repositories: Handle database queries

Coming from a Spring Boot background, my terminology might be a bit different than what is normally used for .NET projects but the idea is the same;
split your logic into layers and use dependency injection to interact between them.

The most important layer to test is the service layer since that's where all the actual "programming" is. In order to test that I would have to mock
my repository interface and have it return arbitrary fake data without actually using the database. You can imagine how bad of an idea it would be
if someone was to test creations, updates or deletions while using the actual database...

There are some other options such as using a different, in memory database for testing but we will not be covering that in this post.

So back to our test, how do we mock the dependency?

```cs
// UnitTest1.cs
using System.Threading.Tasks;
using FakeItEasy;
using src.Services;
using Xunit;

namespace test
{
    public class UnitTest1
    {
        [Fact]
        public async Task Test1()
        {
            var myDependency = new MyDependency();
            Assert.Equal("Hello From MyDependency!", await myDependency.GetDataFromDatabaseAsync());
        }
        
        [Fact]
        public async Task Test2()
        {
            var myDependency = A.Fake<IMyDependency>();
            A.CallTo(() => myDependency.GetDataFromDatabaseAsync()).Returns(Task.FromResult("Hello from mocked"));
            
            Assert.Equal("Hello from mocked", await myDependency.GetDataFromDatabaseAsync());
        }
    }
}
```

Using the `FakeItEasy` package we define an instance of the `IMyDependency` interface using `A.Fake`. This right now does nothing;
we have to explicitly define what happens when one of the interface methods gets called, we do that with `A.CallTo`  which accepts a lambda
of the method in question. I am using `Task.FromResult` because the method is async. If we run the test we can see that it passes which means that
we successfully changed the "implementation" of our dependency. Again, this is what would normally be a repository and a database call changed to
hard coded data, similar to what would be returned from said database call.

<!-- TODO: Add codedoc -->