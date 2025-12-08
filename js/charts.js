/**
 * Charts Module - Weight tracking visualization
 * Using Chart.js-like API (we'll implement a simple canvas-based chart)
 */

const Charts = {
    // Draw weight chart
    drawWeightChart(canvasId, weights) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.parentElement.clientWidth;
        const height = 400;
        
        canvas.width = width;
        canvas.height = height;

        if (weights.length === 0) {
            this.drawEmptyChart(ctx, width, height);
            return;
        }

        // Prepare data
        const data = weights.map(w => ({
            date: new Date(w.date),
            weight: w.weight
        }));

        // Calculate bounds
        const minWeight = Math.min(...data.map(d => d.weight)) - 2;
        const maxWeight = Math.max(...data.map(d => d.weight)) + 2;
        const weightRange = maxWeight - minWeight;

        // Chart dimensions
        const padding = { top: 40, right: 40, bottom: 60, left: 60 };
        const chartWidth = width - padding.left - padding.right;
        const chartHeight = height - padding.top - padding.bottom;

        // Clear canvas
        ctx.clearRect(0, 0, width, height);

        // Draw background
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, width, height);

        // Draw grid
        this.drawGrid(ctx, padding, chartWidth, chartHeight, minWeight, maxWeight);

        // Draw axes
        this.drawAxes(ctx, padding, chartWidth, chartHeight);

        // Draw Y-axis labels (weight)
        this.drawYAxisLabels(ctx, padding, chartHeight, minWeight, maxWeight);

        // Draw X-axis labels (dates)
        this.drawXAxisLabels(ctx, padding, chartWidth, chartHeight, data);

        // Draw line
        this.drawLine(ctx, padding, chartWidth, chartHeight, data, minWeight, weightRange);

        // Draw points
        this.drawPoints(ctx, padding, chartWidth, chartHeight, data, minWeight, weightRange);

        // Draw title
        this.drawTitle(ctx, width, 'Andamento Peso');
    },

    drawEmptyChart(ctx, width, height) {
        ctx.fillStyle = '#F0F0F0';
        ctx.fillRect(0, 0, width, height);
        
        ctx.fillStyle = '#999999';
        ctx.font = '16px Arial';
        ctx.textAlign = 'center';
        ctx.fillText('Nessun dato disponibile', width / 2, height / 2);
    },

    drawGrid(ctx, padding, chartWidth, chartHeight, minWeight, maxWeight) {
        ctx.strokeStyle = '#E0E0E0';
        ctx.lineWidth = 1;

        // Horizontal lines
        const numHorizontalLines = 5;
        for (let i = 0; i <= numHorizontalLines; i++) {
            const y = padding.top + (chartHeight / numHorizontalLines) * i;
            ctx.beginPath();
            ctx.moveTo(padding.left, y);
            ctx.lineTo(padding.left + chartWidth, y);
            ctx.stroke();
        }

        // Vertical lines (optional, for each data point)
        ctx.strokeStyle = '#F0F0F0';
    },

    drawAxes(ctx, padding, chartWidth, chartHeight) {
        ctx.strokeStyle = '#333333';
        ctx.lineWidth = 2;

        // Y-axis
        ctx.beginPath();
        ctx.moveTo(padding.left, padding.top);
        ctx.lineTo(padding.left, padding.top + chartHeight);
        ctx.stroke();

        // X-axis
        ctx.beginPath();
        ctx.moveTo(padding.left, padding.top + chartHeight);
        ctx.lineTo(padding.left + chartWidth, padding.top + chartHeight);
        ctx.stroke();
    },

    drawYAxisLabels(ctx, padding, chartHeight, minWeight, maxWeight) {
        ctx.fillStyle = '#666666';
        ctx.font = '12px Arial';
        ctx.textAlign = 'right';
        ctx.textBaseline = 'middle';

        const numLabels = 5;
        for (let i = 0; i <= numLabels; i++) {
            const weight = maxWeight - (maxWeight - minWeight) * (i / numLabels);
            const y = padding.top + (chartHeight / numLabels) * i;
            ctx.fillText(weight.toFixed(1) + ' kg', padding.left - 10, y);
        }
    },

    drawXAxisLabels(ctx, padding, chartWidth, chartHeight, data) {
        ctx.fillStyle = '#666666';
        ctx.font = '12px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';

        const numLabels = Math.min(data.length, 7);
        const step = Math.floor(data.length / numLabels) || 1;

        for (let i = 0; i < data.length; i += step) {
            const x = padding.left + (chartWidth / (data.length - 1)) * i;
            const date = data[i].date;
            const label = date.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit' });
            
            ctx.save();
            ctx.translate(x, padding.top + chartHeight + 10);
            ctx.rotate(-Math.PI / 4);
            ctx.fillText(label, 0, 0);
            ctx.restore();
        }
    },

    drawLine(ctx, padding, chartWidth, chartHeight, data, minWeight, weightRange) {
        if (data.length < 2) return;

        ctx.strokeStyle = '#006994';
        ctx.lineWidth = 3;
        ctx.lineJoin = 'round';
        ctx.lineCap = 'round';

        ctx.beginPath();

        for (let i = 0; i < data.length; i++) {
            const x = padding.left + (chartWidth / (data.length - 1)) * i;
            const normalizedWeight = (data[i].weight - minWeight) / weightRange;
            const y = padding.top + chartHeight - (normalizedWeight * chartHeight);

            if (i === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }

        ctx.stroke();
    },

    drawPoints(ctx, padding, chartWidth, chartHeight, data, minWeight, weightRange) {
        for (let i = 0; i < data.length; i++) {
            const x = padding.left + (chartWidth / (data.length - 1)) * i;
            const normalizedWeight = (data[i].weight - minWeight) / weightRange;
            const y = padding.top + chartHeight - (normalizedWeight * chartHeight);

            // Outer circle
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.arc(x, y, 6, 0, Math.PI * 2);
            ctx.fill();

            // Inner circle
            ctx.fillStyle = '#006994';
            ctx.beginPath();
            ctx.arc(x, y, 4, 0, Math.PI * 2);
            ctx.fill();

            // Highlight first and last points
            if (i === 0 || i === data.length - 1) {
                ctx.strokeStyle = '#D4735E';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(x, y, 7, 0, Math.PI * 2);
                ctx.stroke();

                // Add label
                ctx.fillStyle = '#D4735E';
                ctx.font = 'bold 12px Arial';
                ctx.textAlign = 'center';
                ctx.textBaseline = i === 0 ? 'bottom' : 'top';
                ctx.fillText(data[i].weight.toFixed(1) + ' kg', x, i === 0 ? y - 12 : y + 12);
            }
        }
    },

    drawTitle(ctx, width, title) {
        ctx.fillStyle = '#006994';
        ctx.font = 'bold 18px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        ctx.fillText(title, width / 2, 10);
    },

    // Update chart on window resize
    setupResponsiveChart(canvasId, weights) {
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                this.drawWeightChart(canvasId, weights);
            }, 250);
        });
    }
};
