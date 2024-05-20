try {
	const el = document.getElementById('__lcp')
	const is_chrome = navigator.userAgent.indexOf("Chrome") > -1

	new PerformanceObserver(list => {
		const timing = window.performance.timing
		if (is_chrome) {
			const ttfb = (timing.responseStart - timing.requestStart).toFixed()
			const last = list.getEntries()[list.getEntries().length - 1]
			const lcp = (last.renderTime || last.loadTime).toFixed()
			el.innerHTML = `<span class="light-silver">lcp</span> ${lcp} <span class="light-silver">ttfb</span> ${ttfb}`
		} else {
			list.getEntriesByType('paint').forEach(({name, startTime}) => {
				if ('first-contentful-paint' == name) {
					const ttfb = (timing.responseStart - timing.requestStart).toFixed()
					el.innerHTML = `<span class="light-silver">fcp</span> ${startTime.toFixed()} <span class="light-silver">ttfb</span> ${ttfb}`
				}
			})
		}
	}).observe({
		type: is_chrome ? 'largest-contentful-paint' : 'paint',
		buffered: true
	})
} catch(e) { console.log(e) }
