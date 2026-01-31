const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true })); 
app.use(express.json());


app.get('/', (req, res) => {
    res.render('index', { result: null });
});

app.post('/submit', async (req, res) => {
    const { name, email } = req.body;

    try {

        const response = await axios.post(`${BACKEND_URL}/process`, {
            name: name,
            email: email
        });

        res.render('index', { result: response.data.message });
    } catch (error) {
        console.error(error);
        res.render('index', { result: "Error: Could not reach Flask backend." });
    }
});

app.listen(PORT, () => {
    console.log(`Frontend server running on http://localhost:${PORT}`);
});
