function renderRecommendationChart(symbol, data) {
    let periods = [];
    let strongBuy = [];
    let buy = [];
    let hold = [];
    let sell = [];
    let strongSell = [];
    for (let i = 0; i < data.length; i += 1) {
        
        periods.push(data[i].period);
        strongBuy.push(data[i].strongBuy);
        buy.push(data[i].buy);
        hold.push(data[i].hold);
        sell.push(data[i].sell);
        strongSell.push(data[i].strongSell);
    }
    Highcharts.chart('container', {
        title : {
            text: `${symbol} Recommendation Trends`,
        },

        chart : {
            type: 'column',
        },

        xAxis: {
            categories: periods,
        },

        yAxis: {
            title: {
                text: "Analysis",
            },
            stackLabels: {
                enabled: true,
            }
        },

        tooltip: {
            format: '<b>{key}</b><br/>{series.name}: {y}<br/>' + 'Total: {point.stackTotal}',
        },

        plotOptions: {
            column: {
                stacking: 'normal',
            },
            series: {
                enabled: true,
                inside: true,
            },
        },

        series: [{
            name: 'Strong Buy',
            data: strongBuy,
        }, {
            name: 'Buy',
            data: buy,
        }, {
            name: 'Hold',
            data: hold,
        }, {
            name: 'Sell',
            data: sell,
        }, {
            name: 'Strong Sell',
            data: strongSell,
        }],

    });
}
