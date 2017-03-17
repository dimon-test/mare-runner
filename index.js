/* eslint-env node */

const compression = require('compression');
const express = require('express');
const http = require('http');
const libpath = require('path');
const Bridge = require('./server/src/bridge').Bridge;
const packageJson = require('./server/package.json');
const WebApp = require('./server/src/webapp').WebApp;
const createProxyServer = require('./web/lib/create-proxy-server').default;
const historyApiFallback = require('./web/lib/history-api-fallback').default;
const stripCookieDomain = require('./web/lib/strip-cookie-domain').default;

// your config

// create web-server, the server host the Chrome DevTools Frontend html files
const webServerConfig = {
    host: '127.0.0.1',
    port: 8001,
};

// the server implement Chrome Debugger Protocol for Lua
const apiServerConfig = {
    storage: {
        database: `${__dirname}/dbdata/`,
    },
    session: {
        expire: 30,
    },
    frontend: {
        host: '127.0.0.1',
        port: 9223,
    },
    backend: {
        host: '127.0.0.1',
        port: 8083,
    },
};

// create the servers
const apiServerUrl = `http://${apiServerConfig.frontend.host}:${apiServerConfig.frontend.port}/`;
const webServerUrl = `http://${webServerConfig.host}:${webServerConfig.port}/`;
const luaServerUrl = `socket://${apiServerConfig.backend.host}:${apiServerConfig.backend.port}`;

const apiServer = new Bridge(apiServerConfig);
apiServer.mount(new WebApp(packageJson));

const webServerApp = express();
const webServer = http.createServer(webServerApp);
const apiServerProxy = createProxyServer(apiServerUrl, stripCookieDomain);
webServerApp.use('/api/', apiServerProxy.web);
webServer.on('upgrade', apiServerProxy.ws);
webServerApp.use(compression());
const root = `${__dirname}/web/webroot/`;
const index = 'index.html';
const option = {index, fallthrough: true};
const fallback = libpath.resolve(root, index);
webServerApp.use(express.static(root, option));
webServerApp.use(historyApiFallback(fallback));

console.info('=== Mare servers started === \n');
console.info(`Server for Lua debugger to attach:\n  ${luaServerUrl}\n`);
console.info(`Server implement Chrome Debugger Protocol:\n  ${apiServerUrl}\n`);
console.info(`Server access Chrome DevTools Frontend:\n  ${webServerUrl}\n`);

// start the servers
apiServer.start();
webServer.listen(webServerConfig.port, webServerConfig.host, (error) => {
    if (error) {
        console.error(error);
    }
});

// log and error handler
console.log = () => {};
process.on('unhandledRejection', (reason) => {
    console.error(reason.stack);
});
