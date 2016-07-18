I got this small database from a colleague working in a video-game company. Videogame companies are interested in selling games that create revenue within short time scales. Usually there is the option of downloading a free demo version of the game for the user to test it. It is very important to keep track of the activity of the user in order to retrieve information such as:
- Is the user investing on the game after the expiration time of the free demo?
- Is the investment related with the time the user spends on the game?
- Can we predict or estimate a trend in the behavior- Is the money invested on publicity (i.e. free demos, advertisings, ...) linked with the revenue?

The retrieved data allows me to study trends such as the involvement of the player (in terms of number of game sessions) and amount of money he/she spends on the game; i.e.: is the involvement a good predictor of spending? It also allows me to study the distribution of in-app purchases as a function of time since the moment the user created the profile.

I access the data through SQL queries using both the RSQLite and sqldf packages, study the relation between several variables such as the country that produces the most revenues and plot several distributions such as the geographic distribution of players, or the money invested per country or per app as well as their revenue.
