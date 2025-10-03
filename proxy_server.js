const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const PORT = 3002;
const API_KEY = 'AIzaSyCgoC5_2Ap1P1qJptgZvq8vKaa3JEgBVqc';

app.use(cors());
app.use(express.json());

// Geocoding endpoint
app.get('/api/geocode', async (req, res) => {
  try {
    const { address } = req.query;
    const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&components=country:US&key=${API_KEY}`;

    const response = await fetch(url);
    const data = await response.json();

    res.json(data);
  } catch (error) {
    console.error('Geocoding error:', error);
    res.status(500).json({ error: 'Failed to geocode address' });
  }
});

// Places search endpoint
app.get('/api/places/nearbysearch', async (req, res) => {
  try {
    const { location, radius, type, opennow, minprice, maxprice } = req.query;

    let url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location}&radius=${radius}&type=${type}&key=${API_KEY}`;

    if (opennow) url += `&opennow=${opennow}`;
    if (minprice) url += `&minprice=${minprice}`;
    if (maxprice) url += `&maxprice=${maxprice}`;

    const response = await fetch(url);
    const data = await response.json();

    res.json(data);
  } catch (error) {
    console.error('Places search error:', error);
    res.status(500).json({ error: 'Failed to search places' });
  }
});

// Places text search endpoint for cuisine filtering
app.get('/api/places/textsearch', async (req, res) => {
  try {
    const { query, location, radius, opennow, minprice, maxprice } = req.query;

    let url = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)}&key=${API_KEY}`;

    if (location) url += `&location=${location}`;
    if (radius) url += `&radius=${radius}`;
    if (opennow) url += `&opennow=${opennow}`;
    if (minprice) url += `&minprice=${minprice}`;
    if (maxprice) url += `&maxprice=${maxprice}`;

    const response = await fetch(url);
    const data = await response.json();

    res.json(data);
  } catch (error) {
    console.error('Places text search error:', error);
    res.status(500).json({ error: 'Failed to search places by text' });
  }
});

// Places details endpoint
app.get('/api/places/details', async (req, res) => {
  try {
    const { place_id, fields } = req.query;
    const url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${place_id}&fields=${fields}&key=${API_KEY}`;

    const response = await fetch(url);
    const data = await response.json();

    res.json(data);
  } catch (error) {
    console.error('Places details error:', error);
    res.status(500).json({ error: 'Failed to get place details' });
  }
});

app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
});