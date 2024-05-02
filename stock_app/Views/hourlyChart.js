function updateChartData(symbol, data) {
    var chart = Highcharts.chart('container', {
        title : {
            text: `${symbol} Hourly Price Variation`,
            style: {
                color: '#888888'
            }
        },

        time: {
            timezone: 'America/Los_Angeles'
        },

        xAxis: {
            type: 'datetime',
            crosshair: true,
        },

        yAxis: {
            opposite: true,
            title: {
                text: null,
            },
        },

        plotOptions: {
            line: {
                marker: {
                    enabled: false,
                },
                color: '#0fa028',
            },
        },

        series: [{
            name: symbol,
            data: data,
            showInLegend: false,
        }],
        //        series: [{
//            data: data
//        }]
    });
}
