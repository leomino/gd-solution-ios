# This repository contains the iOS-Part to my solution for the 5th Scholarship of Check24 "CHECK24 GenDev Betting Challenge"

Videolink to the recording of the Apps functionalities: https://youtu.be/eFOUTrsBFQ0
Repository to the Serverside of this challange: https://github.com/leomino/gd-solution-api

This challenge was very enjoyable, and I experienced a significant learning curve. I decided to create a mobile app using SwiftUI to improve my skills in that area, especially 
since I transitioned from iOS development to web technologies a few months ago. I have had one year of experience in SwiftUI.
All other used frameworks like Hono, Drizzle and Supabase were new to me.

## Authentication
Even though it wasn't required, I implemented JWT authentication using Firestore. This allowed me to design my API endpoints in a way that I preferred. I could justify this
choice by noting that if this project were to go live, this approach would save considerable development time. I also wanted to learn how to build custom JWT authentication.

## Database
I chose Supabase as the database because of its generous free tier and built-in real-time functionality. Supabase had been on my "to-try" list for a long time, so I was glad
to finally experiment with it. I specifically opted not to use Supabase's authentication service, instead choosing Firestore, to avoid relying entirely on a single service provider.
Additionally, Supabase allows me, as an admin, to update game results through its dashboard without needing to restart any services or manually change the code.
<img width="1234" alt="Screenshot 2024-06-02 at 14 57 03" src="https://github.com/leomino/gd-solution-ios/assets/45589096/3599031a-fd83-4dcf-b458-9e7802bf2264">

## Real time updates: 
I implemented real-time updates in the dashboard for matches that are currently being played or are about to start in the `TournamentDashboard` with the `MatchesViewModel`. This is currently the only area with real-time updates. While this functionality can also be added to the MatchesView, I aim to minimize channel throughput by filtering the channel to listen only to specific rows—those matches that are
actually being played, rather than all matches.

## Point and Rank calculation
One database function is triggered by updating the "finalized = true" column in MatchResults. This function calculates the points for each user and updates the User table accordingly.
After updating the points, it calls another function that resets the positions for each user in each community.
That second function is also called by the trigger when inserting a new member into a community in order to re-calculate the positions.

## Pagination of the leaderboards
Implementing leaderboard pagination on the server was straightforward, but it was a bit tricky in SwiftUI. I added this functionality to the `LeaderboardView`.
The leaderboard entries are split if the positions are not consecutive (e.g., 1, 2, 6,... would be split into two parts: 1, 2 and 6,...).
After splitting, it's easy to calculate the offset and limit based on the last element of the previous chunk and the first element of the next chunk.

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

## Possible Optimizations
- Messaging Queue Service: Implementing a messaging queue service like RabbitMQ or ActiveMQ could significantly improve performance. By offloading prediction upsertings and pinning
  actions to a messaging queue, the server can handle these tasks asynchronously. This approach allows the server to send immediate success responses to clients, enhancing the perceived
  performance during high-demand situations.
- Database Indexes: I did not have enough time to thoroughly analyze where to use indexes in the database. Adding appropriate indices, such as those for leaderboard creation, could improve query performance.
  Evaluating and implementing these indices could lead to more efficient data retrieval and overall better database performance.
- Load Balancing: Distributing the traffic across multiple server instances can prevent any single server from becoming a bottleneck when a lot of users perform requests at the same time.
- Position calculation is currently being done by the database. This could be a potential bottleneck especially when users join new communities. I would want to find another way for this,
  maybe batch processing or tra to figure out which rows are affected and skip those that are not.
- I would want to add more previews to my swiftui views not only covering all states "success", "loading", "failure" but also edge cases like when a user chose a very long username or has a very long surname etc.
- SwiftLint should definetly be added to this project as well
- Tests covering the crucial functionality
