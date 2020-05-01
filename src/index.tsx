import React from 'react';
import ReactDOM from 'react-dom';
import Main from './Elm/Main.elm';
import Elm from 'react-elm-components';
import './index.css';
import * as serviceWorker from './serviceWorker';
import JWT from 'jsonwebtoken';

const getToken = () => JWT.sign({
    "role": "web_anon",
    "exp": Math.round(
        (new Date().getTime() + 60 * 1000 /* milliseconds */) / 1000
        /* seconds */) // 1 min
}, process.env.REACT_APP_JWT_SECRET || '');

const Component = (props: {}) => {

    const flags = {
        windowWidth: window.innerWidth,
        windowHeight: window.innerHeight,
        apiUrl: process.env.REACT_APP_API_URL,
        jwtToken: getToken()
    };
    return (
        <React.StrictMode>
            <Elm src={Main.Elm.Elm.Main} flags={flags} ports={setupPorts} />
        </React.StrictMode>
    );
};

function setupPorts(ports: any) {
    window.setInterval(() => {
        ports.getJwt.send(getToken());
    }, 10000);
}

ReactDOM.render(
    <Component />,
    document.getElementById('root')
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
