function renderMonthlyChart(symbol, data) {
    console.log('renderMonthlyChart', symbol);
    
    // Load the dataset
    console.log('data', data);
    
    // split the data set into ohlc and volume
    const ohlc = [],
    volume = [],
    dataLength = data.length;
    
    for (let i = 0; i < dataLength; i += 1) {
        ohlc.push([
            data[i].t, // the date
            data[i].o, // open
            data[i].h, // high
            data[i].l, // low
            data[i].c // close
        ]);
        
        volume.push([
            data[i].t, // the date
            data[i].v // the volume
        ]);
    }
    
    // create the chart
    Highcharts.stockChart('container', {
        
        //    rangeSelector: {
        //    selected: 1
        //    },
    rangeSelector: {
    enabled: true,
    selected: 2,
    buttons: [{
    type: 'month',
    count: 1,
    text: '1m'
    }, {
    type: 'month',
    count: 3,
    text: '3m'
    }, {
    type: 'month',
    count: 6,
    text: '6m'
    }, {
    type: 'year',
    count: 1,
    text: '1y'
    }, {
    type: 'all',
    text: 'All'
    }],
    inputEnabled: true,
    },
    navigator: {
    enabled: true,
    },
    scrollbar: {
    enabled: true // Enables the scrollbar
    },
        
    title: {
    text: `${symbol} Historical Data`
    },
        
    subtitle: {
    text: 'With SMA and Volume by Price technical indicators'
    },
        
    yAxis: [{
    startOnTick: false,
    endOnTick: false,
    labels: {
    align: 'right',
    x: -3
    },
    title: {
    text: 'OHLC'
    },
    height: '60%',
    lineWidth: 2,
    resize: {
    enabled: true
    }
    }, {
    labels: {
    align: 'right',
    x: -3
    },
    title: {
    text: 'Volume'
    },
    top: '65%',
    height: '35%',
    offset: 0,
    lineWidth: 2
    }],
        
    tooltip: {
    split: true
    },
        
    plotOptions: {
    series: {
    dataGrouping: {
    units: [
            [
                'day', // unit name
                [1] // allowed multiples
            ]
            ]
    }
    }
    },
        
    series: [{
    type: 'candlestick',
    name: symbol,
    id: 'aapl',
    zIndex: 2,
    data: ohlc
    }, {
    type: 'column',
    name: 'Volume',
    id: 'volume',
    data: volume,
    yAxis: 1
    }, {
    type: 'vbp',
    linkedTo: 'aapl',
    params: {
    volumeSeriesID: 'volume'
    },
    dataLabels: {
    enabled: false
    },
    zoneLines: {
    enabled: false
    }
    }, {
    type: 'sma',
    linkedTo: 'aapl',
    zIndex: 1,
    marker: {
    enabled: false
    }
    }]
    });
}
