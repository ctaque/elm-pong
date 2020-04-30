import React from 'react';
import ReactDOM from 'react-dom';
import Main from './Elm/Main.elm';
import Elm from 'react-elm-components';
import './index.css';
import * as serviceWorker from './serviceWorker';

const flags = {
	windowWidth: window.innerWidth,
	windowHeight: window.innerHeight,
    apiUrl: process.env.REACT_APP_API_URL,
    jwtSecret: process.env.REACT_APP_JWT_SECRET
};
ReactDOM.render(
  <React.StrictMode>
      <Elm src={Main.Elm.Elm.Main} flags={flags} />
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
