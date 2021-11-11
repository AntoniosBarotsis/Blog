---
author: "Antonios Barotsis"
title: "Project Demeter: Part 1"
description: "The early stages"
tags: ["Project Demeter"]
categories: ["No Code", "Project Demeter"]
# cover:
#     image: "images/elastic.png"
date: 2021-11-11T16:37:08+01:00
draft: false
---

# Progress since last time

When I made the first blog post, I basically just had an empty project with not much code in it. At the time of writing this, I still don't have an insane
amount of progress done but there's definitely a lot more things going on.

Here's some of the "big" stuff that have been added:

- Added a PSQL database container

  I decided to use a Postgres database because of the [PostGIS](https://postgis.net/) plugin which will allow me to work with geolocation data later on.
  Right now, there's not a whole lot going on in the database; I've only added the `User` and `Order` fields because I wanted to implement authentication.
  The next model that should get added soon will probably be the `Owner` and after that I think I'll rethink the rest of my models and eventually add those
  all together. I also created a class that applies any pending migrations to the database and clears + seeds it every time the server runs. The latter
  will of course not be around when the app is complete but for now it is very handy for manual testing. You can find the class 
  [here](https://github.com/AntoniosBarotsis/Demeter/blob/master/src/Infrastructure/Data/DatabaseSeeder.cs) if you want to see how that works but in
  essence it is nothing more than one hard coded user with one past order with no items (did not want to also add items this soon for testing).

- Added a Redis database container

  I've been thinking of using a cache for a while in my project but was limited by the fact that I couldn't run more than one container when hosting
  my apps as stated earlier so was pretty excited for this to say the least. I came up with a weird (perhaps overcomplicated way) of setting the
  key values using enums, idea being that I don't randomly make a small typo and end up getting cache misses when I shouldn't be. The general cache service
  can be found [here](https://github.com/AntoniosBarotsis/Demeter/blob/master/src/Infrastructure/Data/Redis/RedisCacheService.cs) and an example usage
  for users is [here](https://github.com/AntoniosBarotsis/Demeter/blob/master/src/Domain/Services/UserService.cs).

- Used a bunch of libraries that I've wanted to glue together for some time, namely:
  - Automapper
  - MediatR with CQRS
  - Serilog

  Automapper is extremely useful and will definitely be using it in probably all my future projects. In my last "big" project which was Gromceri
  (*haven't talked much about it and have also not finished + kind of abandoned but might get back to that at some point, you can read some stuff
  about it [here](https://twitter.com/gromceri)*) I was using function expressions which had the advantage of being chainable with my LINQ queries
  (and thus looking cool) but looking back, that was not such a clean looking solution and I also do not think that it was that great of an idea to
  convert entities to their DTOs right after a query.

  MediatR and CQRS are both pretty cool and I can kind of see why they would be useful in very big, complicated projects but I feel like they are
  way too verbose for a one man project. However, that being said they do help keep the overall flow cleaner by separating the layers which is why
  I will rethink whether I want to stick to MediatR at the end of this project's development when I'll have a better idea of it.

  Yes I've been wanted to use loggers properly in an actual project for some time. This will definitely get more interesting once I add Elasticsearch
  and Kibana to the project but even now it is cool. I also want to add error handling middleware which will definitely leverage the logger.

- Finally did some proper testing!

  If you visit the project you'll see that I've added Codecov to it to force myself to test more. At the moment I have only been testing my Domain
  which is where the models and their Services live and I'm not sure if I will also test my other 2 layers.

  One thing that I want to admit is that testing definitely forces you to write cleaner code. I really appreciate dependency injection and an overall
  separation of functionality a lot more after having sank quite some time into testing my code.

  A few very helpful libraries I used for my tests are:

  - [Autofixture](https://autofixture.github.io/)

    This is such a great tool and I wish I learnt about it earlier. TLDR: It is used to instantiate your classes with random data. The great thing about it
    is that, well, you don't have to type everything out yourself which except for being time saving, saves you the errors when your classes change
    and can also help in discovering errors with your logic given specific input (since it is random).

    What I really like about it is that you can also control the values of specific attributes while everything else is random. For example, one thing
    I did in some of my tests is have a predefined order price and I wanted the menu items themselves to have random data but that given price, this is
    very easy to do with this package!
  
  - [NSubstitute](https://nsubstitute.github.io/)
    
    NSubstitute is used for mocking, that's it. It has a very clean syntax that really works for me and it just works. I don't think I'll be switching that
    for a different mocking library any time soon.
  
  - [FluentAssertions](https://fluentassertions.com/introduction)

    Similarly, Fluent Assertions have a very neat syntax for assertions that just works nicely. Also coming from Java's JUnit, testing for exceptions
    finally has syntax you can memorize.

- Added JWT Role based authentication

  It is not the first time I implemented JWT in a project but was very glad that it took me about an hour instead of a few weeks like last time.
  I borrowed much of the configuration for stuff like password strength and what not from that previous implementation but reworked both the classes
  associated with authentication themselves and their position in the project. I also feel like I added enough self explanatory exception messages
  for when stuff fails. I also added roles to the authentication scheme (which I think work but I haven't added owners yet so can't be certain).
  This was a lot easier than I thought it was gonna be. The only interesting thing about this is that I used an enum for the role which I found out how to
  store as a string to the database (and in the response DTO) instead of an int. 

  Something that wasn't great was how the `userManager` class from the Identity package does not have a relevant interface which meant I couldn't really
  test it so I instead made my own interface with the methods that I am going to need and made the implementation use an instance of `userManager` which
  has the same effect but makes it testable.

Something that doesn't really fit anywhere else is that I did a bit more research on RabbitMQ and found out that what I probably want to use is the RPC
functionality it offers which *I think* will require another project running. If that is the case I will probably make a very simple, one endpoint
separate API project that I can run from the docker compose file. Since I don't actually want to do something more with it other than make it wait for a bit
as if it is processing the payment or whatever and then return "payment successful" this should work fine. I am not entire sure how this will work yet
(does the code wait for the remote call to be completed or does it receive a notification?) but that should be one of the very last things that I will add
to the project so it is not really something to worry about at the moment.

# The next steps

I believe that I will be toning down the amount of work that I put into the project for a little while because of some irl issues and university + work
being a thing. I also don't have an exact plan of what to do next but here's some of the stuff that I will work on for the next post

- Add more models to the database
- Use redis for most if not all endpoints
- Add a refresh token for the JWT
- Make a `login` and `refresh` endpoint
- Have a user endpoint that returns data only for the user making the request
- Add Elasticsearch and Kibana (?)

# Closing

As always, thanks for reading! The repo can be found [here](https://github.com/AntoniosBarotsis/Demeter). I am really proud of the progress of the project
so far and I am just hoping that I can get back to being productive on it after I deal with everything else going on in my life right now