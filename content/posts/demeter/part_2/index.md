---
author: "Antonios Barotsis"
title: "Project Demeter: Part 2"
description: "The early stages"
tags: ["Project Demeter"]
categories: ["No Code", "Project Demeter"]
date: 2021-12-24T08:59:03+02:00
draft: false
---

It's been sometime since my last post but I just now got to work on the project again.

# Progress since last time

The bulk of the additions since last time concern authentication;

- Added `Login` and `Refresh` endpoints. I'm not sure if the concept of refresh tokens were there
  last time but they are there now. The idea is that you have the normal JSON Web Token which
  expires 10 minutes after you create it (reminder to self to check if I handle timezones properly
  at some point) but the user also gets a refresh token on login which expires 6 months later,
  this way whatever client interacts with the app won't have to ask the user for his credentials
  since it can just keep using and refreshing the token.
- The database now also stores `Orders` and `MenuItems`.
- I realized my caching had a small bug where `User.PastOrders` would not get populated after
  parsing the results from the cache entry even though the data was in the returned JSON string.
  This got my stuck for an afternoon. I tried a few different things like adding empty
  constructors to the `User` class,  adding a constructor that takes the `MenuItems` as input and
  annotating it with `[JsonConstructor]` but none of these worked. Turns out I'd forgotten to add
  a setter to the `MenuItems` attribute... I had another bug with the refresh token being
  considered invalid if the token was expired and it expiring a few minutes off of when it should
  be but those were more like "code wrong" instead of an elaborate, complicated issue where turns
  out you just forgot a setter.
- Most of these were added last time but since I didn't mention this before; I made a few
  Powershell scripts for things like starting or watching the app, applying migrations etc.
  While those do obviously work with the `dotnet` CLI (which is what the scripts use as well)
  you had to keep adding the `project` flag to point the CLI to the correct project which got
  tedious quite fast and is the only reason why I bothered making these, you're welcome.
- I learned about this pretty handy feature of C# which is extension methods. Basically,
  you create a static method that ends up being used as a method of another class without
  needing to create a whole different class that inherits from the one you want to add the method
  to or having to put the class instance inside the method which just looks weird. I used this
  for having all my `Include` statements for the `User` class; because `User` is a very decently
  nested class, I have to make a few unions everytime I make a database call and instead of
  putting the same unions in all my `User` queries I made an extension method for the `User`
  `DbSet` so that all those unions are in one place. Using it is very easy as instead of
  doing `context.Users` I do `context.Users.BuildUser.Result` where `BuildUser` is my extension
  method's name. As you may notice, it is an async method which is not necessary for this to work
  but I also use it to calculate and populate some fields that are not mapped to the database such
  as the price of an order (which is the sum of all the items in that order). This was overall a
  very useful feature with way too many applications and I was completely unaware of it. I will
  definitely be finding many uses for it in the future.
- Not as exciting but finally got around making an endpoint that returns your own user now that
  authentication works. I just use the user id that I store in the token to make a `findOne`
  database query.
- Lastly, because I also took some time to test *most* stuff, I realized that the Authentication
  service was a bit too complicated and hard to test so I decided to move some of the code to a
  separate "Token" service. Honestly, the biggest perk of testing for me is how it forces you
  to rethink your code quality. Most of the times I end up doing quite a bit of manual testing
  before I write my tests and thus I hardly ever actually discover bugs through my testing
  (which may or may not be a bad thing) but the refactoring I end up doing pretty often is always
  cool.

# The next steps

Not entirely sure when I'll be working on this again (hopefully soon!) but here's the plan for next
time.

- Extend the cache for the `findOne` user endpoint and whichever new entities I end up adding
- I want to look into a few potential refactorings including where the cache logic is at the
  moment; right not cache lookups happen in the services but I feel like it makes more sense to
  move those to the repositories since it is still a data access operation and the service should
  not care about where the data comes from as long as it's there.
- I want to look into potential exceptions that I'd want to add. One example of this would be
  invalid user credentials (empty names or other stuff like that) and just generally things
  that could go wrong with user input. With this I also want to take a look at my response codes
  and change them where needed.
- I think I'll try to work on items before the next time and I really want to have a paginated
  output. I'm thinking of having a `getAll` endpoint that will give you all items from a restaurant
  but in pages. You should be able to change the page size (with some limitations of course) and
  select what page number you want returned. A really cool thing to add here would be to have
  products presorted in the database but I am not sure if

  - that is possible
  - or efficient
  
  I will definitely try looking into this though. Adding to this, I'll start looking into indices
  since I do want to have the output of this sorted in some way.
- I still haven't tested `tokenService` so there's that. Some of the stuff in there seemed rather
  hard to test (at least compared to other stuff I had to test before) *which is also why I moved
  it out of the authentication service*.
- I need to add DTOs. So far, only users have one and it most likely will have to be changed.

# Closing

Thank you for reading once again! The repo can be found [here](https://github.com/AntoniosBarotsis/Demeter).
I am glad that I am still working on this albeit at a pretty slow pace. I often do not have that
much energy to spend on this after university work unfortunately but as we say in Greece,
"rather slow than never". Till next time.