# This repository contains the iOS-Part to my solution for the 5th Scholarship of Check24 ["GenDev Betting Challenge"](https://github.com/check24-scholarships/check24-betting-challenge) (Accepted)

Videolink to the recording of the Apps functionalities: https://youtu.be/eFOUTrsBFQ0

Repository to the Serverside of this challange: https://github.com/leomino/gd-solution-api

This challenge was very enjoyable, and I experienced a significant learning curve. I decided to create a mobile app using SwiftUI to improve my skills in that area. I have had one year of experience in SwiftUI.
All other used technologies like Bun, Hono, Drizzle, Supabase and Redis were new to me.

<img width="1062" alt="Screenshot 2024-07-08 at 00 09 47" src="https://github.com/leomino/gd-solution-ios/assets/45589096/fa7cb659-7a31-4ee0-bb60-9c2dea4aab68">

## Authentication
I implemented JWT authentication using Firestore. This allowed me to design my API endpoints in a way that I preferred, including giving users roles (like the admin role for the admin dashboard).

## Leaderboard generation
To efficiently generate leaderboards for up to 2 million users, the app uses Redis with `SortedSets` to store usernames alongside their respective scores for each community.
The server first retrieves all communities joined by the requesting user from supabase. Then creates Promises to generate the leaderboards for each community from redis, resolving them concurrently.
By using the `ZRANGE WITHSCORES` command, this allows for leaderboard generation in O(log(n) + m) time, where `n` is the total number of community members and `m` is the number of members retrieved.

## Leaderboard previews
To meet the requirement that every preview must consist of exactly seven entries (or less if the community has fewer members), including the top three, the last place, the users
before and after the current user as well as the current user, I wrote a simple algorithm, checking for the following three cases:

<img width="1090" alt="Screenshot 2024-06-24 at 10 55 17" src="https://github.com/leomino/gd-solution-ios/assets/45589096/1cbc98b2-560a-4060-85b3-52c8a4962464">

To retrieve the necessary ranges from the leaderboard efficiently I use `ZRANGEWITHSCORES` command, which retrieves each chunk in O(log(n) + m), where `n` is the total number of
community members and `m` is the number of members retrieved (always between one and six, so neglectable). To make it even more efficient, all necessary ranges are retrieved in a single
redis request using `multi` execution.
This algorithm is written in the server: [src/leaderboard/index.ts:generateLeaderboard(...)](https://github.com/leomino/gd-solution-api/blob/main/src/leaderboards/index.ts).

## Database
I chose Supabase as the database because of its generous free tier and built-in real-time functionality. Supabase had been on my "to-try" list for a long time, so I was glad
to finally experiment with it. I specifically opted not to use Supabase's authentication service, instead choosing Firestore, to avoid relying entirely on a single service provider.

<img width="1018" alt="Screenshot 2024-06-24 at 10 21 58" src="https://github.com/leomino/gd-solution-ios/assets/45589096/f8d77ea3-d110-4972-b384-6cb15a1c1eff">

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

## Possible Optimizations
- Messaging Queue Service: Implementing a messaging queue service like RabbitMQ or ActiveMQ could significantly improve performance. By offloading prediction upsertings and pinning
  actions to a messaging queue, the server can handle these tasks asynchronously. This approach allows the server to send immediate success responses to clients, enhancing the perceived
  performance during high-demand situations.
- Database Indexes: I did not have enough time to thoroughly analyze where to use indexes in the database. Adding appropriate indices, such as those used to check if a community or a user exists, could improve query performance for all depending operations.
- Load Balancing: Distributing the traffic across multiple server instances can prevent any single server from becoming a bottleneck when a lot of users perform requests at the same time.
- I would want to add more previews to my swiftui views not only covering all states "success", "loading", "failure" but also edge cases like when a user chose a very long username or has a very long surname etc.
- SwiftLint should definetly be added to this project as well
- Tests covering the crucial functionality
