# Raid Helper Integration

A full-stack solution for managing WoW Classic raid schedules using Raid-Helper API integration with a web interface and in-game addon.

## Project Components

### 1. Web Interface (Express + Node.js)
A web application that fetches raid events from Raid-Helper API and displays them in an organized format.

### 2. WoW Classic Addon
An in-game addon that displays upcoming raids with a minimap button and management interface.

## Features

### Web Interface
- Fetch raid events using Raid-Helper API key
- Display events grouped by player name
- Handle unmatched raid names with options to:
  - Remove from results
  - Associate with known raids
  - Create custom raid names
- Copy raid lists to clipboard with one click
- Responsive UI with clean design

### WoW Addon
- Minimap button with tooltip showing upcoming raids
- Main tracker window with time-sorted raid display
- Import raid data directly from website
- Delete individual raids with one click
- Countdown timers showing days/hours until each raid
- Persistent raid storage per character

## Installation

### Web Interface

1. Clone the repository:
```bash
git clone https://github.com/yourusername/raid-helper-website.git
cd raid-helper-website
```

2. Install dependencies:
```bash
npm install
```

3. (Optional) Configure environment variables:
```bash
cp .env.example .env
# Edit .env to customize PORT and HOST
```

Available environment variables:
- `PORT` - Server port (default: 3000)
- `HOST` - IP address to bind to (default: localhost, use 0.0.0.0 for external access)

4. Start the server:
```bash
npm start
```

5. Open your browser and navigate to:
```
http://localhost:3000
```

### WoW Classic Addon

1. Copy the `raidTracker` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\`
   - Mac: `/Applications/World of Warcraft/_classic_/Interface/AddOns/`

2. Restart WoW or reload UI with `/reload`

3. Open the tracker with `/rt` or `/raidtracker`

## Usage

### Getting Raid Data

1. **Get your Raid-Helper API key** from [raid-helper.dev](https://raid-helper.dev)

2. **In the web interface:**
   - Enter your API key
   - Handle any unmatched raids
   - Click on a player name to copy their raid schedule

3. **In WoW:**
   - Type `/rt` to open the tracker
   - Click "Import" button
   - Paste the copied raid data
   - Click "Import"

### Managing Raids

**Web Interface:**
- Click character names to copy their entire raid schedule
- Associate unmatched raids with known raid names or create custom names

**WoW Addon:**
- View all raids sorted by time in the main window
- Hover minimap button to see next 5 upcoming raids
- Click "X" next to any raid to delete it
- Raids automatically removed when they're in the past

## API Endpoint

The web server exposes one endpoint:

**POST** `/api/events`
```json
{
  "apiKey": "your-raid-helper-api-key"
}
```

Response includes:
- Event data with titles, timestamps, and player names
- List of unmatched raid names
- List of known raid names

## Known Raid Names

The following raids are recognized by default:
- Molten Core
- Onyxia
- BWL (Blackwing Lair)
- ZG (Zul'Gurub)
- AQ20 (Ruins of Ahn'Qiraj)

## File Structure

```
raid-helper-website/
├── server.js              # Express server
├── package.json           # Node.js dependencies
├── .env.example           # Environment variables template
├── public/
│   └── index.html        # Web interface
├── raidTracker/          # WoW Addon
│   ├── raidTracker.toc   # Addon metadata
│   └── raidTracker.lua   # Main addon code
└── README.md
```

## Development

### Web Server
The server runs on `localhost:3000` by default. You can customize this using environment variables:
- `PORT` - Change the server port (default: 3000)
- `HOST` - Change the bind address (default: localhost, use 0.0.0.0 for external connections)

### Addon Development
- Addon uses `SavedVariablesPerCharacter` to store raid data
- Data stored in `RaidDB` table
- Slash commands: `/raidtracker` or `/rt`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

ISC

## Credits

- Raid data provided by [Raid-Helper](https://raid-helper.dev)

## Support

For issues or questions, please open an issue on GitHub.
