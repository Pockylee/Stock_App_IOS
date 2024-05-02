function renderEPSChart(symbol, data) {
    let actuals = [];
    let estimates = [];
    let surprises = {};
    for (let i = 0; i < data.length; i += 1) {
        actuals.push([data[i].period, data[i].actual]);
        estimates.push([data[i].period, data[i].estimate]);
        surprises[data[i].period] = data[i].surprise.toFixed(2);
    }
    Highcharts.chart('container', {
        title : {
            text: "Historical EPS Surprises",
        },

        chart : {
            type: 'spline',
            events: {
                load: function() {
                    Highcharts.addEvent(this.tooltip, 'headerFormatter', function(e) {
                        if (!e.isFooter) {
                            let surprise = surprises[e.labelConfig.key];
                            e.text = `${e.labelConfig.key}<br/>Surprise: ${surprise}<br/>`;
                            return false;
                        }
                        return true;
                    })
                },
            },
        },

        xAxis: {
            type: "category",
            labels: {
                useHTML: true,
                formatter: function() {
                    return `<p>${this.value}<br/>Surprise: ${surprises[this.value]}</p>`
                },
            },
        },

        yAxis: {
            title: {
                text: "Quarterly EPS",
            },
        },

        tooltip: {
            shared: true,
        },

        series: [
            {
                name: 'Actual',
                data: actuals,
            },
            {
                name: 'Estimate',
                data: estimates,
            },
        ],
    });
}
