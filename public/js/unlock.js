// expects
// 		uid in currentScript[data-uid]
// 		currentScript[data-paid]
// set up unlock link UI (on click from .data-unlock-create)
// generate unlocks including validation context

// (() => {
// 	const qs = (s,o=document) => o.querySelector(s), qsa = (s,o=document) => o.querySelectorAll(s)
// 	const UNLOCK_BASEURL = new URL(document.currentScript.src).origin
// 	const code = new URLSearchParams(location.search).get('_unlock')
// 	const pid = location.origin + location.pathname
// 	const uid = qs('body').getAttribute('data-ghost-uid')
// 	let tu = null;

// 	const get_jwks = async () => {
// 		return await (await fetch(`/members/.well-known/jwks.json`)).json()
// 	}

// 	const get_token = async () => {
// 		return await (await fetch(`/members/api/session`)).text()
// 	}

// 	const try_unlock = async (code, pid) => {
// 		return await (await fetch(`${UNLOCK_BASEURL}/unlock/try?code=${code}&pid=${pid}`)).json()
// 	}

// 	const get_status = async (uid, pid) => {
// 		return await (await fetch(`${UNLOCK_BASEURL}/unlock/status?uid=${uid}&pid=${pid}`)).json()
// 	}

// 	const unlock_content = () => {
// 		const hr = qs("hr")
// 		const gate = qs(".gh-post-upgrade-cta")

// 		// if this is a post, there's an <hr> and a paygate, and not an unlock, hide the nodes in between
// 		if (qs('body.post-template') && !!gate && !!hr) {
// 			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {	e.style.display = "initial" })
// 			hr.style.display = 'none'
// 		}
// 	}

// 	const lock_content = () => {
// 		const hr = qs("hr")
// 		const gate = qs(".gh-post-upgrade-cta")

// 		if (!!hr) hr.style.display = 'none'

// 		if (qs('body.post-template') && !!gate && !!hr) {
// 			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {	e.style.display = "none" })
// 			hr.style.visibility = "hidden"
// 		}
// 	}

// 	(async () => {
// 		const is_subscriber = ('true' == qs('body').getAttribute('data-ghost-paid'))
// 		let is_unlock = false
// 		let jwks, token, status

// 		if (!!code) {
// 			tu = await try_unlock(code, pid)
// 			is_unlock = tu.unlocked
// 		}

// 		if (!is_unlock) {
// 			lock_content()
// 		} else {

// 		}

// 		Promise.all([get_jwks(), get_token(), get_status(uid, pid)]).then(v => {
// 			[jwks, token, status] = v

// 			qs('.unlock-remaining-count').innerHTML = status.remaining
// 			qs('.unlock-quota-count').innerHTML = status.quota

// 			let mode = 'ready'
// 			if (!!tu && tu.unlocked) {
// 				mode = 'is-unlock'
// 				unlock_content()
// 			} else if (!is_subscriber) {
// 				mode = 'not-subscribed'
// 			} else if (status.code) {
// 				mode = 'already-unlocked'
// 			} else if (0 == status.remaining) {
// 				mode = 'none-remaining'
// 			}
// 			qs('body').classList.add(`mode-${mode}`)

// 			// refresh token as needed
// 			if (!!token) {
// 				const parseJWT = t => { return JSON.parse(atob(t.split('.')[1])) }
// 				const jwt = parseJWT(token)
// 				setInterval(() => {	get_token().then(v => { token = v }) }, (jwt.exp - jwt.iat) * 1000)
// 			}
// 		})

// 		qsa('.unlock-create').forEach(el => {
// 			el.addEventListener("click", ev => {
// 				fetch(`${UNLOCK_BASEURL}/unlock`, {
// 					method: 'POST',
// 					headers: {
// 						'Accept': 'application/json',
// 						'Content-Type': 'application/json'
// 					},
// 					body: JSON.stringify({
// 						uid: uid,
// 						pid: pid,
// 						token: token,
// 						jwks: jwks
// 					})
// 				}).then(r => r.json()).then(j => {
// 					qs('.unlock-left-count').innerHTML = j.remaining
// 					el.innerHTML = "Share URL copied"
// 					console.log(j)
// 				})
// 			})
// 		})

// 		qsa('.unlock-copy').forEach(el => {
// 			el.addEventListener("click", ev => {
// 				navigator.clipboard.writeText(`${document.location.origin}${document.location.pathname}?_unlock=${status.code}`)
// 				el.classList.add('clicked')
// 			})
// 		})
// 	})();

// 	(() => {
// 		let s = document.createElement('script')
// 		s.onload = () => { MicroModal.init() }
// 		s.src = 'https://unpkg.com/micromodal@0.4.10/dist/micromodal.min.js'
// 		document.head.appendChild(s)
// 	})();

// })();

////

(() => {
	const cs = document.currentScript
	const UNLOCK_BASEURL = new URL(cs.src).origin
	const qs = (s,o=document) => o.querySelector(s), qsa = (s,o=document) => o.querySelectorAll(s)
	const body = qs('body')
	const urlParams = new URLSearchParams(location.search)

	const STATE = {
		code: urlParams.get('_unlock'),
		pid: location.origin + location.pathname,
		uid: cs.getAttribute('data-uid'),
		isSubscriber: cs.getAttribute('data-paid') === 'true',
		jwks: null,
		token: null,
		status: null,
		unlockTry: null
	};

	const API = {
		getJwks: () => fetch('/members/.well-known/jwks.json').then(r => r.json()),
		getToken: () => fetch('/members/api/session').then(r => r.text()),
		tryUnlock: (code, pid) => fetch(`${UNLOCK_BASEURL}/unlock/try?code=${code}&pid=${pid}`).then(r => r.json()),
		getStatus: (uid, pid) => fetch(`${UNLOCK_BASEURL}/unlock/status?uid=${uid}&pid=${pid}`).then(r => r.json()),
		createUnlock: (data) => fetch(`${UNLOCK_BASEURL}/unlock`, {
			method: 'POST',
			headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
			body: JSON.stringify(data)
		}).then(r => r.json())
	};

	const DOM = {
		unlockContent: () => {
			const hr = qs("hr");
			const gate = qs(".gh-post-upgrade-cta");
			if (body.classList.contains('post-template') && gate && hr) {
				qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach(e => e.style.display = "initial");
				hr.style.display = 'none';
			}
		},
		lockContent: () => {
			const hr = qs("hr")
			const gate = qs(".gh-post-upgrade-cta")
			if (hr) hr.style.display = 'none'
			if (body.classList.contains('post-template') && gate && hr) {
				qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach(e => e.style.display = "none")
				hr.style.visibility = "hidden"
			}
		},
		updateUI: () => {
			qs('.unlock-remaining-count').innerHTML = STATE.status.remaining
			qs('.unlock-quota-count').innerHTML = STATE.status.quota

			let mode = 'ready'
			if (STATE.unlockTry && STATE.unlockTry.unlocked) {
				mode = 'is-unlock'
				DOM.unlockContent();
			} else if (!STATE.isSubscriber) {
				mode = 'not-subscribed'
			} else if (STATE.status.code) {
				mode = 'already-unlocked'
			} else if (STATE.status.remaining === 0) {
				mode = 'none-remaining'
			}
			body.classList.add(`mode-${mode}`)
		},
		setupEventListeners: () => {
			qsa('.unlock-create').forEach(el => {
				el.addEventListener("click", async () => {
					const result = await API.createUnlock({
						uid: STATE.uid,
						pid: STATE.pid,
						token: STATE.token,
						jwks: STATE.jwks
					})
					qs('.unlock-left-count').innerHTML = result.remaining
					el.innerHTML = "Share URL copied"
					console.log(result)
				});
			});

			qsa('.unlock-copy').forEach(el => {
				el.addEventListener("click", () => {
					navigator.clipboard.writeText(`${location.origin}${location.pathname}?_unlock=${STATE.status.code}`);
					el.classList.add('clicked');
				});
			});
		}
	};

	const init = async () => {
		if (STATE.code) {
			STATE.unlockTry = await API.tryUnlock(STATE.code, STATE.pid);
		}

		if (!STATE.unlockTry || !STATE.unlockTry.unlocked) {
			DOM.lockContent();
		}

		[STATE.jwks, STATE.token, STATE.status] = await Promise.all([
			API.getJwks(),
			API.getToken(),
			API.getStatus(STATE.uid, STATE.pid)
		]);

		DOM.updateUI();
		DOM.setupEventListeners();

		if (STATE.token) {
			const jwt = JSON.parse(atob(STATE.token.split('.')[1]));
			setInterval(async () => {
				STATE.token = await API.getToken();
			}, (jwt.exp - jwt.iat) * 1000);
		}
	};

	init();

	// Load MicroModal
	const script = document.createElement('script');
	script.onload = () => MicroModal.init();
	script.src = 'https://unpkg.com/micromodal@0.4.10/dist/micromodal.min.js';
	document.head.appendChild(script);
})();
