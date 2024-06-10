# This repository contains the iOS-Part to my solution for the 5th Scholarship of Check24 ["GenDev Betting Challenge"](https://github.com/check24-scholarships/check24-betting-challenge)

<div align="center">
  <a href="https://testflight.apple.com/join/oIDNwtUT">
    <img width="300" alt="Screenshot 2024-06-10 at 14 32 44" src="https://github.com/leomino/gd-solution-ios/assets/45589096/eb5647e3-c099-41e9-a126-7d899182578f">
  </a>
</div>

<hr />

Videolink to the recording of the Apps functionalities: https://youtu.be/eFOUTrsBFQ0

Test via testflight: https://testflight.apple.com/join/oIDNwtUT

Repository to the Serverside of this challange: https://github.com/leomino/gd-solution-api

This challenge was very enjoyable, and I experienced a significant learning curve. I decided to create a mobile app using SwiftUI to improve my skills in that area, especially 
since I transitioned from iOS development to web technologies a few months ago. I have had one year of experience in SwiftUI.
All other used technologies like Bun, Hono, Drizzle, Supabase and Redis were new to me.

## Authentication
Even though it wasn't required, I implemented JWT authentication using Firestore. This allowed me to design my API endpoints in a way that I preferred. I could justify this
choice by noting that if this project were to go live, this approach would save considerable development time. I also wanted to learn how to build custom JWT authentication.

## Database
I chose Supabase as the database because of its generous free tier and built-in real-time functionality. Supabase had been on my "to-try" list for a long time, so I was glad
to finally experiment with it. I specifically opted not to use Supabase's authentication service, instead choosing Firestore, to avoid relying entirely on a single service provider.

<img width="1018" alt="Screenshot 2024-06-24 at 10 21 58" src="https://github.com/leomino/gd-solution-ios/assets/45589096/f8d77ea3-d110-4972-b384-6cb15a1c1eff">

## Leaderboard generation
To efficiently generate leaderboards for up to 2 million users, I use Redis with `SortedSets` to store usernames alongside their respective scores for each community.
The server first retrieves all communities joined by the requesting user from supabase. It then creates Promises to generate the leaderboards for each community from redis, resolving them
concurrently.
By using the `ZRANGE WITHSCORES` command, this allows for leaderboard generation in O(log(n) + m) time, where `n` is the total number of community members and `m` is the number of members retrieved.

## Leaderboard previews
To meet the requirement that every preview must consist of exactly seven entries (or less if the community has fewer members), including the top three, the last place, the users
before and after the current user as well as the current user, I wrote a simple algorithm, checking for the following three cases:

<img width="1090" alt="Screenshot 2024-06-24 at 10 55 17" src="https://github.com/leomino/gd-solution-ios/assets/45589096/1cbc98b2-560a-4060-85b3-52c8a4962464">

To retrieve the necessary ranges from the leaderboard efficiently I use `ZRANGEWITHSCORES` command, which retrieves each chunk in O(log(n) + m), where `n` is the total number of
community members and `m` is the number of members retrieved (always between one and six, so neglectable). To make it even more efficient, all necessary ranges are retrieved in a single
redis request using `multi` execution.
This algorithm is written in the server: [src/leaderboard/index.ts:generateLeaderboard(...)](https://github.com/leomino/gd-solution-api/blob/main/src/leaderboards/index.ts).

## Real time updates:
I implemented real-time updates in the dashboard for matches that are currently being played or are about to start in the `TournamentDashboard` with the `MatchesViewModel`.
This is currently the only area with real-time updates. While this functionality can also be added to the MatchesView, I aim to minimize channel throughput by filtering the channel
to listen only to specific rows—those matches that are actually being played, rather than all matches.

## Point and Rank calculation
Updating a `MatchResult` through the `AdminDashboard` triggers the following operation for that result if the `MatchResult.finalized` property is set to true:
The server retrieves all user predictions for bets placed on that match. It then creates Promises for each prediction to request Redis to increment the points for those users according to the
specified ruleset, resolving them concurrently.
This process is executed in O(log n) time using the Redis `ZINCRBY` command.

## State management
Although I have had good experiences with the TCA library, I decided not to use it for this project. I wanted to see how far I could get without relying on any extra libraries.
Instead, I heavily used Combine and Publishers to handle the app state. To manage data across all views without injecting a top-level object, I used callback functions.
For example, when placing a bet in the `PredictionView`, the callback function onUpsert is called to carry the upserted data back to the `TournamentDashboardView`.
This approach allows the new data to be used to update the state without needing to re-call the server unnecessarily. My approach minimizes network traffic and at the same time reduces View-re-rendering.

## Pinning users feature
Unfortunately, I didn't have enough time to implement the pinning functionality for other users. Implementing this feature isn't difficult; I would create another table called
"communities_pinned_users" or something similar, which would store the following structure: (currentUsername, pinnedUser, communityId). Left swiping on a list can be handled using 
SwiftUI's "swipeActions" modifier, which provides the client-side functionality. When pinning a user, it should send a request to the server to upsert a new entry in the aforementioned table.
The server would also need to provide a DELETE endpoint to remove pinned users.
To include pinned users in the leaderboard generations, I would use the `ZREVRANK WITHSCORES` command to retrieve the rank and scores for the pinned entries.
This could be done in O(log(n)) time.

## Possible Optimizations
- Messaging Queue Service: Implementing a messaging queue service like RabbitMQ or ActiveMQ could significantly improve performance. By offloading prediction upsertings and pinning
  actions to a messaging queue, the server can handle these tasks asynchronously. This approach allows the server to send immediate success responses to clients, enhancing the perceived
  performance during high-demand situations.
- Database Indexes: I did not have enough time to thoroughly analyze where to use indexes in the database. Adding appropriate indices, such as those used to check if a community or a user exists, could improve query performance for all depending operations.
- Load Balancing: Distributing the traffic across multiple server instances can prevent any single server from becoming a bottleneck when a lot of users perform requests at the same time.
- I would want to add more previews to my swiftui views not only covering all states "success", "loading", "failure" but also edge cases like when a user chose a very long username or has a very long surname etc.
- SwiftLint should definetly be added to this project as well
- Tests covering the crucial functionality
