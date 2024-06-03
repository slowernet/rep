// check & trigger unlock
// expects uid in body[data-uid]
// set up unlock link UI (on click from [data-unlock-create][data-member-id='{{@member.uuid}}]')
// generate unlocks including validation context

// .mode-already-gifted
// .mode-not-subscribed
// .mode-ready
// .mode-none-remaining

(() => {
	const doc = document, qs = (s,o=doc) => o.querySelector(s), qsa = (s,o=doc) => o.querySelectorAll(s)
	const UNLOCK_BASEURL = new URL(document.currentScript.src).origin

	const get_jwks = async () => {
		return await (await fetch(`/members/.well-known/jwks.json`)).json()
	}

	const get_token = async () => {
		return await (await fetch(`/members/api/session`)).text()
	}

	const try_unlock = async (code, pid) => {
		return await (await fetch(`${UNLOCK_BASEURL}/unlock/try?code=${code}&pid=${pid}`)).json()
	}

	const get_status = async (uid, pid) => {
		return await (await fetch(`${UNLOCK_BASEURL}/unlock/status?uid=${uid}&pid=${pid}`)).json()
	}

	(() => {
		const hr = qs("hr")
		const gate = qs(".gh-post-upgrade-cta")
		const is_paywalled = !!gate
		let is_unlocked = false

		// check unlock code if present

		// XXX need promise for is_unlocked here
		// if this is a post, there's an <hr> and a paygate, and not an unlock, hide the nodes in between
		if (is_paywalled && !is_unlocked && qs('body.post-template') && hr && gate) {
			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {
				e.style.display = "none"
			})
			hr.style.display = "none"
		}

		// if (is_paywalled) {
			qs('.gh-article .gh-article-share-control').style.display = 'flex'
		// }
	})();

	(async () => {
		const pid = location.origin + location.pathname
		const uid = qs('body').getAttribute('data-ghost-uid')
		const code = new URLSearchParams(location.search).get('_unlock')
		let jwks, token, tu, status

		Promise.all([get_jwks(), get_token(), try_unlock(code, pid), get_status(uid, pid)]).then(v => {
			[jwks, token, tu, status] = v

			qs('.unlock-remaining-count').innerHTML = status.remaining

			// refresh token as needed
			const parseJWT = t => { return JSON.parse(atob(t.split('.')[1])) }
			const jwt = parseJWT(token)
			setInterval(() => {	get_token().then(v => { token = v }) }, (jwt.exp - jwt.iat) * 1000)
		})

		qsa('[data-unlock-create][data-member-id]').forEach(el => {
			el.addEventListener("click", ev => {
				fetch(`${UNLOCK_BASEURL}/unlock`, {
					method: 'POST',
					headers: {
						'Accept': 'application/json',
						'Content-Type': 'application/json'
					},
					body: JSON.stringify({
						uid: uid,
						pid: pid,
						token: token,
						jwks: jwks
					})
				}).then(r => r.json()).then(j => {
					qs('.unlock-left-count').innerHTML = j.remaining
					el.innerHTML = "Share URL copied"
					console.log(j)
				})
			})
		})
	})();

	(() => {
		let s = document.createElement('script')
		s.onload = () => { MicroModal.init() }
		s.src = 'https://unpkg.com/micromodal@0.4.10/dist/micromodal.min.js'
		document.head.appendChild(s)
	})();

})();
