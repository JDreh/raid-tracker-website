const express = require('express');
const axios = require('axios');
const path = require('path');
const http = require('http');
const https = require('https');
const fs = require('fs');
require('dotenv').config();

const app = express();
const HOST = process.env.HOST || 'localhost';

app.use(express.json());
app.use('/raidhelper', express.static('public'));

app.post('/raidhelper/api/events', async (req, res) => {
  try {
    const { apiKey } = req.body;

    if (!apiKey) {
      return res.status(400).json({ error: 'API key is required' });
    }

    const raidHelperUrl = `https://raid-helper.dev/api/v3/users/${apiKey}/events`;

    const response = await axios.get(raidHelperUrl);

    const KNOWN_RAIDS = ['Molten Core', 'Onyxia', 'BWL', 'ZG', 'AQ20'];
    const eventsData = [];
    const unmatchedRaids = new Set();
    const events = response.data;

    // Process each event and collect all event entries
    if (Array.isArray(events)) {
      events.forEach(event => {
        const title = event.title || 'N/A';
        const startTime = event.startTime || 'N/A';
        const signUps = event.signUps || [];

        // Check if this raid is known
        if (!KNOWN_RAIDS.includes(title)) {
          unmatchedRaids.add(title);
        }

        signUps.forEach(signUp => {
          const name = signUp.name || 'Unknown';

          eventsData.push({
            title: title,
            startTime: startTime,
            playerName: name,
            isKnownRaid: KNOWN_RAIDS.includes(title)
          });
        });
      });
    }

    res.json({
      eventsData: eventsData,
      unmatchedRaids: Array.from(unmatchedRaids),
      knownRaids: KNOWN_RAIDS
    });
  } catch (error) {
    if (error.response) {
      res.status(error.response.status).json({
        error: 'Raid-Helper API error',
        message: error.response.data
      });
    } else {
      res.status(500).json({
        error: 'Server error',
        message: error.message
      });
    }
  }
});

// Determine ports based on whether PORT is specified
let httpPort, httpsPort;
if (process.env.PORT) {
  // If PORT is specified, use it for both (typically only one will run)
  httpPort = parseInt(process.env.PORT);
  httpsPort = parseInt(process.env.PORT);
} else {
  // If PORT is not specified, use default ports
  httpPort = 80;
  httpsPort = 443;
}

// Start HTTP server
const httpServer = http.createServer(app);
httpServer.listen(httpPort, HOST, () => {
  console.log(`HTTP Server is running on http://${HOST}:${httpPort}`);
});

// Start HTTPS server if SSL certificates are configured
const sslCertPath = process.env.SSL_CERT_PATH;
const sslKeyPath = process.env.SSL_KEY_PATH;

if (sslCertPath && sslKeyPath) {
  try {
    // Check if certificate files exist
    if (fs.existsSync(sslCertPath) && fs.existsSync(sslKeyPath)) {
      const httpsOptions = {
        cert: fs.readFileSync(sslCertPath),
        key: fs.readFileSync(sslKeyPath)
      };

      const httpsServer = https.createServer(httpsOptions, app);
      httpsServer.listen(httpsPort, HOST, () => {
        console.log(`HTTPS Server is running on https://${HOST}:${httpsPort}`);
      });
    } else {
      console.warn('SSL certificate files not found. HTTPS server not started.');
      console.warn(`Cert path: ${sslCertPath}`);
      console.warn(`Key path: ${sslKeyPath}`);
    }
  } catch (error) {
    console.error('Error starting HTTPS server:', error.message);
    console.warn('HTTPS server not started. Only HTTP is available.');
  }
} else {
  console.log('SSL certificate paths not configured. Only HTTP server started.');
  console.log('To enable HTTPS, set SSL_CERT_PATH and SSL_KEY_PATH in .env file.');
}
