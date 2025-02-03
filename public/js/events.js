(() => {
	const EVENT_QUEUE_BUFFER_LENGTH = 2

	const STATE = {
		event_queue: []
	}

	const API = {
		send: d => { fetch('/events', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(d)
		}).then(r => r.json())},

		beacon: (url, params = {}) => {
			const fd = Object.keys(params).reduce((fd, k) => {
				fd.append(k, params[k])
				return fd
			}, new FormData())
			navigator.sendBeacon(url, fd)
		}
	}

	const init = async () => {
		window.addEventListener('click', ev => {
			console.log(ev)
			STATE.event_queue.push({ type: 'click', loc: [ev.pageX, ev.pageY] })
			if (STATE.event_queue.length >= EVENT_QUEUE_BUFFER_LENGTH) {
				API.send(STATE.event_queue)
				STATE.event_queue = []
			}
  		})
	}

	init()
})();
