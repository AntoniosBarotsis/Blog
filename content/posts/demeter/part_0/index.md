---
author: "Antonios Barotsis"
title: "Project Demeter: Part 0"
description: "The beginning of my new project."
tags: ["Project Demeter"]
categories: ["No Code", "Project Demeter"]
# cover:
#     image: "images/elastic.png"
date: 2021-11-05T17:20:51+01:00
draft: false
---

# What is Project Demeter

This is my latest passion past-time toy project that I will be working on for some time. You can read some details about it
[here](https://github.com/AntoniosBarotsis/Demeter) but long story short: it will be a food ordering service minus the payment bit.

And since I posted the repository, I should note that I have already changed my mind for some of the stuff mentioned there
(mainly that I will be using Postgres instead of SQLite and that I will definitely use RabbitMQ) so don't take everything I said
there word for word as this is still pretty early in development.

# Why

I think it will be a great learning experience for me (if I actually push myself to finish it).

There are so many things that I want to make use of and it feels pretty overwhelming at the moment but I'm sure that will improve
once I start actually working on it. So far the only thing that I have figured out is how to use [PostGIS](https://postgis.net/)
(which is a Postgres plugin that allows you to work with spatial data) to make queries about stuff's locations.

# My Progress

I figured that would be a good starting point considering that one of the main features I want this service to have is making radial distance
queries around your location for near by restaurants. The SQL itself is not hard, I just have to figure out how to convert that to something EF Core
understands and am set for that. Other than that, the only thing that I have at the moment is a basic project structure with no actual code in it.
I will be probably working on figuring out what my models should look like today and after that's done I'll see what follows.

Part of the reason why I'm writing this is because it is actually pretty decent motivation for me to keep going but also because I feel like this
would be very interesting for anyone trying to start a new project to read through once I'm finished.

I think that that's about it for now so see you all in part 1 hopefully soon.
