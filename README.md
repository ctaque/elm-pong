### The Elm source code is wrapped with a TypeScript React app (Create React App) for Ecmascript features

To run the game locally, you need to install the dependencies then start the game :

```
npm i

npm start
```

To save The scores, you need to install and configure a PostGrest webserver and create a .env file at project root containing these environment variables :
```
REACT_APP_GOOD_API_URL=http://localhost:5433
REACT_APP_JWT_SECRET=any_secret
```
