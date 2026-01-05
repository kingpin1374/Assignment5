const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 3000;

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true })); 
app.use(express.json());


app.get('/', (req, res) => {
    res.render('index', { result: null });
});

app.post('/submit', async (req, res) => {
    const { name, email } = req.body;

    try {

        const response = await axios.post('http://backend-host:8000/process', {
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
