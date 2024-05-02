const express = require('express');
const app = express();
// const port = 3000;
const PORT = process.env.PORT || 8080
const path = require('path');
const axios = require('axios');
const { start } = require('repl');
const { setServers } = require('dns');
const { MongoClient, ServerApiVersion } = require('mongodb');
const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
const { watch } = require('fs');
// app.use(express.static('browser'));
app.use(express.static('public'));
app.use(express.json());

const uri = "mongodb+srv://brian7149:brian0329@stocksearchhw3.zcnjngt.mongodb.net/?retryWrites=true&w=majority&appName=StockSearchHW3";
// const uri = "mongodb+srv://brian7149:brian0329@stocksearchhw3.zcnjngt.mongodb.net/StockAppIOS?retryWrites=true&w=majority&appName=StockSearchHW3";

mongoose.connect(uri)
  .then(() => console.log('MongoDB connected...'))
  .catch(err => console.error('Could not connect to MongoDB', err));

const Schema = mongoose.Schema;

const watchlistSchema = new Schema({
  symbol: { type: String, unique: true},
  companyName: String,
});

watchlistSchema.plugin(uniqueValidator)
const Watchlist  = mongoose.model('Watchlist', watchlistSchema);

const portfolioSchema = new Schema({
    symbol: {
        type: String,
        required: true,
        uppercase: true
    },
    companyName: {
        type: String,
        required: true
    },
    quantity:{
        type: Number,
        required: true,
        min: 0
    },
    totalCost: {
        type: Number,
        required: true,
        min: 0
      },
    averageCost: {
        type: Number,
        required: true,
    }

    });

const Portfolio = mongoose.model('Portfolio', portfolioSchema);

const WalletSchema = new mongoose.Schema({
    balance: {
      type: Number,
      required: true
    }
  });
const Wallet = mongoose.model('Wallet', WalletSchema);
  
  // Initialize or find the wallet in the database
  const initializeWallet = async () => {
    try {
      let wallet = await Wallet.findOne();
      if (!wallet) {
        console.log('No wallet found. Creating a new one with default balance.');
        wallet = new Wallet({ balance: 25000 }); // Default balance
        await wallet.save();
        console.log('Wallet created with balance:', wallet.balance);
      } else {
        console.log('Wallet found with balance:', wallet.balance);
        // Optional: Update the balance if needed
        wallet.balance = 25000;
        await wallet.save();
      }
    } catch (error) {
      console.error('Error initializing the wallet:', error);
    }
  };

  app.get('/api/wallet', async (req, res) => {
    try {
      const wallet = await Wallet.findOne();
      res.json(wallet);
    } catch (error) {
      res.status(500).send('Error fetching wallet balance');
    }
  });


  app.patch('/api/wallet', async (req, res) => {
    try {
        const { change } = req.body;
        // Assuming there's a Wallet model or a specific way to fetch/update the wallet balance
        // Here's a pseudo code
        let wallet = await Wallet.findOne(); // Fetch the current wallet
        if (!wallet) {
            return res.status(404).send('Wallet not found');
        }

        // Update the balance
        wallet.balance += change;
        await wallet.save();

        res.json(wallet);
    } catch (error) {
        console.error('Error updating wallet balance:', error);
        res.status(500).send('Error updating wallet balance');
    }
});
  
  // Initialize wallet when server starts
  initializeWallet();
  




app.post('/api/portfolio', async (req, res) => {
    const { symbol, companyName, quantity, totalCost } = req.body;

    try {
        let portfolioEntry = await Portfolio.findOne({ symbol: symbol.toUpperCase() });

        if (portfolioEntry) {
            console.log('Updating existing stock in portfolio for : ', symbol);
            
            const newTotalQuantity = portfolioEntry.quantity + quantity;
            const newTotalCost = portfolioEntry.totalCost + totalCost;
            const newAverageCost = newTotalCost / newTotalQuantity;

            console.log('New total quantity: ', newTotalQuantity);
            console.log('New total cost: ', newTotalCost);
            console.log('New average cost: ', newAverageCost);

            portfolioEntry = await Portfolio.findOneAndUpdate({symbol}, {
                $set: {
                    quantity: newTotalQuantity,
                    totalCost: newTotalCost,
                    averageCost: newAverageCost
                }
            }, {new: true}) //ensures the updated document is returned.

        } else{
            console.log('Adding new stock to portfolio for : ', symbol);
            console.log('Quantity: ', quantity);
            console.log('Total Cost: ', totalCost);
            console.log('Average Cost: ', totalCost / quantity);

            portfolioEntry = new Portfolio({
                symbol,
                companyName,
                quantity,
                totalCost,
                averageCost: totalCost / quantity
            });

            await portfolioEntry.save();
        }

        res.json(portfolioEntry);

    } catch (error) {
        res.status(500).send('Error adding stock to portfolio');
    }
});

app.get('/api/portfolio', async (req, res) => {
    try {
      const portfolioItems = await Portfolio.find();
      res.send(portfolioItems);
    } catch (error) {
      res.status(500).send({ message: 'Error fetching portfolio', error: error });
    }
});

app.get('/api/portfolio/check/:symbol', async (req, res) => {
    try {
        const { symbol } = req.params;
        const stockInPortfolio = await Portfolio.findOne({ symbol: symbol });
        console.log('Checking stock in portfolio:', symbol);
        console.log('Stock in portfolio:', stockInPortfolio);
        res.send(!!stockInPortfolio); // Convert to boolean and send back
    } catch (error) {
        res.status(500).send('Error checking stock in portfolio');

    }
});

app.post('/api/portfolio/sell', async (req, res) => {
    const { symbol, companyName,quantity, totalCost } = req.body;

    try {
        let portfolioEntry = await Portfolio.findOne({ symbol: symbol.toUpperCase() });
        if (portfolioEntry) {
            if (portfolioEntry.quantity < quantity) {
                return res.status(400).send({ message: 'Not enough shares to sell' });
            }

            console.log('Selling stock from portfolio for : ', symbol);
            const newTotalQuantity = portfolioEntry.quantity - quantity;
            // const totalSellValue = quantity * sellPrice;
            const newTotalCost = portfolioEntry.totalCost - totalCost;

            console.log('New total quantity: ', newTotalQuantity);
            // console.log('totalSellValue: ', totalSellValue);
            console.log('New total cost: ', newTotalCost);
            console.log('New average cost: ', newTotalCost / newTotalQuantity);



            if (newTotalQuantity === 0) {
                await Portfolio.findOneAndDelete({ symbol: symbol.toUpperCase() });
                portfolioEntry.quantity = 0;
                portfolioEntry.totalCost = 0;
            }else{
                portfolioEntry = await Portfolio.findOneAndUpdate({symbol}, {
                    $set: {
                        quantity: newTotalQuantity,
                        totalCost: newTotalCost,
                        averageCost: newTotalCost / newTotalQuantity
                    }
                }, {new: true}) //ensures the updated document is returned.
            }

            res.json(portfolioEntry);
        } else {
            res.status(404).send({ message: 'Stock not found in portfolio' });
        }
    } catch (error) {
      res.status(500).send({ message: 'Error removing item from portfolio', error: error });
    }
});

app.get('/api/portfolio/quantity/:symbol', async (req, res) => {
    const { symbol } = req.params;

    try {
        const portfolioEntry = await Portfolio.findOne({ symbol: symbol.toUpperCase() });
        if (portfolioEntry) {
            res.json({ quantity: portfolioEntry.quantity });
        } else {
            res.status(404).send('Stock not found in portfolio');
        }
    } catch (error) {
        res.status(500).send('Error fetching stock quantity');
    }
});


app.post('/api/watchlist', async (req, res) => {
    const { symbol, companyName } = req.body;
    try {
        const existingStock = await Watchlist.findOne({ symbol});
        if (existingStock) {
            return res.status(400).send('Stock already in watchlist');
        }
        //if not exist, add to watchlist
        const newSTock = new Watchlist({ symbol, companyName });
        await newSTock.save();
        res.send(newSTock);
    } catch (error) {
        if (error.code === 11000) {
            res.status(400).send('Stock already in watchlist');
        }
        else{
            res.status(500).send('Error adding stock to watchlist');
        }
    }
});

app.get('/api/watchlist', async (req, res) => {
    try {
        const watchlist = await Watchlist.find();
        res.send(watchlist);
    } catch (error) {
        res.status(500).send('Error fetching watchlist');
    }
});

app.delete('/api/watchlist/:symbol', async (req, res) => {
    try {
        const { symbol } = req.params;
        const deletedStock = await Watchlist.findOneAndDelete({ symbol: symbol.toUpperCase() });
        if (!deletedStock) {
            return res.status(404).send('Stock not found');
        }
        res.send({ message: 'Stock removed from watchlist', deletedStock});
    } catch (error) {
        res.status(500).send('Error removing stock from watchlist');
    } 
});

app.get('/api/watchlist/check/:symbol', async (req, res) => {
    try {
        const { symbol } = req.params;
        const stockInWatchlist = await Watchlist.findOne({ symbol: symbol });
        console.log('Checking stock in watchlist:', symbol);
        console.log('Stock in watchlist:', stockInWatchlist);
        res.send(!!stockInWatchlist); // Convert to boolean and send back
    } catch (error) {
        res.status(500).send('Error checking stock in watchlist');
    }
});

// Add a route for the api call to finnhub
app.get('/api/stock/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg'; // Replace with your actual API key
    const url = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${apiKey}`;

    try {
        const response = await axios.get(url);
        console.log("Stock Data for symbol:", symbol);
        console.log(response.data.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching stock data');
    }
});


app.get('/api/autocomplete/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg'; // Ensure you secure your API key, possibly using environment variables
    const url = `https://finnhub.io/api/v1/search?q=${symbol}&token=${apiKey}`;

    try {
        const response = await axios.get(url);
        const filteredResults = response.data.result
            .filter(item => !item.symbol.includes('.')) // Assuming you still want to filter out items containing a '.'
            .map(item => ({
                symbol: item.symbol, 
                description: item.description  // Assumes the API response has a 'description' field
            }));

        res.json(filteredResults);  // Send the cleaned up results array directly
        console.log("Autocomplete Data for symbol:", symbol, filteredResults);
    } catch (error) {
        console.error("Error fetching autocomplete data:", error);
        res.status(500).send('Error fetching autocomplete data');
    }
});

// Add a route for the api call to profile
app.get('/api/profile/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg'; // Replace with your actual API key
    const url = `https://finnhub.io/api/v1/stock/profile2?symbol=${symbol}&token=${apiKey}`;
  
    try {
        const response = await axios.get(url);
        console.log("Profile Data for symbol:", symbol);
        console.log(response.data.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching profile data');
    }
  });

// Add a route for the api call to peers
app.get('/api/peers/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg'; // Replace with your actual API key
    const url = `https://finnhub.io/api/v1/stock/peers?symbol=${symbol}&token=${apiKey}`;
  
    try {
        const response = await axios.get(url);
        console.log("Peers Data for symbol:", symbol);
        // console.log(response.data);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching peers data');
    }
  });

// Add a route for the api call to news
app.get('/api/news/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg'; // Replace with your actual API key
    
    const today = new Date();
    const startDate = new Date(today);
    startDate.setDate(today.getDate() - 30);

    const formatDate = (date) => {
        let month = '' + (date.getMonth() + 1),
            day = '' + date.getDate(),
            year = date.getFullYear();
      
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
      
        return [year, month, day].join('-');
      }
      
    const from = formatDate(startDate);
    const to = formatDate(today);
    
    console.log("Loading news for symbol:", symbol)
    console.log("Start Date:", from); // 30 days before today
    console.log("End Date:", to); // Today
    
    const url = `https://finnhub.io/api/v1/company-news?symbol=${symbol}&from=${from}&to=${to}&token=${apiKey}`;
    try {
        const response = await axios.get(url);
        // console.log(response.data);
        const filteredNews = response.data.filter(item => 
            item.category && 
            item.datetime && 
            item.headline && 
            item.id && 
            item.image &&
            item.related && 
            item.source && 
            item.summary && 
            item.url
        );
        // console.log(response.data.length);
        console.log(filteredNews.length);
        // const itemsFilteredOut = response.data.length - filteredNews.length;
        res.json(filteredNews.slice(0,20));

    } catch (error) {
        res.status(500).send('Error fetching newws data');
    }
  });

//Add a route for the api call to summary chart
// app.get('/api/summarychart/:symbol', async (req, res) => {
//     const symbol = req.params.symbol;
//     const apiKey = 'HpFCPlsv7oxta6ThiFEwPwi9UPRnoWPK';

//     const endDate = new Date();
//     const startDate = new Date();
//     startDate.setDate(endDate.getDate() - 1);

//     // Format dates to YYYY-MM-DD
//     const formatDate = (date) => {
//         const year = date.getFullYear();
//         const month = ('0' + (date.getMonth() + 1)).slice(-2);
//         const day = ('0' + date.getDate()).slice(-2);
//         return `${year}-${month}-${day}`;
//     };

//     const from = formatDate(startDate);
//     const to = formatDate(endDate);
//     console.log("Loading summary chart data for symbol:", symbol);
//     console.log("start date:", from);
//     console.log("end date:", to);

//     const url = `https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/hour/${from}/${to}?apiKey=${apiKey}`;
//     try {
//         const response = await axios.get(url);
//         console.log(response.data.length);
//         res.json(response.data);
//     } catch (error) {
//         res.status(500).send('Error fetching summary chart data');
//     }
// });

app.get('/api/summarychart/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'HpFCPlsv7oxta6ThiFEwPwi9UPRnoWPK';

    let endDate = new Date();
    const currentHour = endDate.getHours();
    const isWeekend = endDate.getDay() === 0 || endDate.getDay() === 6;
    const isAfterHours = currentHour < 4 || currentHour > 13; // Assuming Eastern Time trading hours for simplicity

    // Market is closed if it's the weekend or if it's currently after hours
    const marketClosed = isWeekend || isAfterHours;

    if (marketClosed) {
        if (isWeekend) {
            // If it's Sunday, go back to the previous Friday
            if (endDate.getDay() === 0) {
                endDate.setDate(endDate.getDate() - 2);
            }
            // If it's Saturday, also go back to the previous Friday
            if (endDate.getDay() === 6) {
                endDate.setDate(endDate.getDate() - 1);
            }
        } else if (isAfterHours) {
            // If it's after hours, keep the same day but note that data will be up to the close
        }
    } else {
        // If the market is open, adjust endDate to yesterday for the start of the period
        endDate.setDate(endDate.getDate() - 1); 
    }

    let startDate = new Date(endDate);
    startDate.setDate(endDate.getDate() - 1); // Fetch data from the day before the last trading day

    const formatDate = (date) => {
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}-${month}-${day}`;
    };

    const from = formatDate(startDate);
    const to = formatDate(endDate);

    console.log("Loading summary chart data for symbol:", symbol, "From:", from, "To:", to);

    const url = `https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/hour/${from}/${to}?apiKey=${apiKey}`;
    try {
        const response = await axios.get(url);
        if(response.data && response.data.results && response.data.results.length > 0) {
            res.json(response.data);
        } else {
            res.status(404).json({message: "No data available for the requested period, market might have been closed."});
        }
    } catch (error) {
        console.error('Error fetching summary chart data:', error);
        res.status(500).send('Error fetching summary chart data');
    }
});


//Add a route for the api call to Historical chart
app.get('/api/historicalchart/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'HpFCPlsv7oxta6ThiFEwPwi9UPRnoWPK';

    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - 730);

    // Format dates to YYYY-MM-DD
    const formatDate = (date) => {
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}-${month}-${day}`;
    };

    const from = formatDate(startDate);
    const to = formatDate(endDate);
    console.log("Loading historical chart data for symbol:", symbol);
    console.log("start date:", from);
    console.log("end date:", to);

    const url = `https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/day/${from}/${to}?apiKey=${apiKey}`;
    try {
        const response = await axios.get(url);
        console.log("Number of data points received:", response.data.results.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching historical chart data');
    }
});

//Add a route for the api call to insider sentiment
app.get('/api/insider/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg';
    const url = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${symbol}&token=${apiKey}`;

    try {
        const response = await axios.get(url);
        console.log("Insider Sentiment Data for symbol:", symbol);
        console.log(response.data.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching insider sentiment data');
    }
});

//Add a route for the api call to recommendation trends
app.get('/api/recommendation/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg';
    const url = `https://finnhub.io/api/v1/stock/recommendation?symbol=${symbol}&token=${apiKey}`;

    try {
        const response = await axios.get(url);
        console.log("Recommendation Trends Data for symbol:", symbol);
        console.log(response.data.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching recommendation trends data');
    }
});

//Add a route for the api call to earnings
app.get('/api/earnings/:symbol', async (req, res) => {
    const symbol = req.params.symbol;
    const apiKey = 'cn9uq59r01qjv5ip1fc0cn9uq59r01qjv5ip1fcg';
    const url = `https://finnhub.io/api/v1/stock/earnings?symbol=${symbol}&token=${apiKey}`;

    try {
        const response = await axios.get(url);
        console.log("Earnings Data for symbol:", symbol);
        console.log(response.data.length);
        res.json(response.data);
    } catch (error) {
        res.status(500).send('Error fetching earnings data');
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
