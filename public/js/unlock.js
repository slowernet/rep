// expects
// 		uid in body[data-ghost-uid]
// 		body[data-ghost-paid]
// set up unlock link UI (on click from .data-unlock-create)
// generate unlocks including validation context

(() => {
	const qs = (s,o=document) => o.querySelector(s), qsa = (s,o=document) => o.querySelectorAll(s)
	const UNLOCK_BASEURL = new URL(document.currentScript.src).origin
	const code = new URLSearchParams(location.search).get('_unlock')
	const pid = location.origin + location.pathname
	const uid = qs('body').getAttribute('data-ghost-uid')
	let tu = null;

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

	const unlock_content = () => {
		const hr = qs("hr")
		const gate = qs(".gh-post-upgrade-cta")

		// if this is a post, there's an <hr> and a paygate, and not an unlock, hide the nodes in between
		if (qs('body.post-template') && !!gate && !!hr) {
			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {	e.style.display = "initial" })
			hr.style.display = 'none'
		}
	}

	const lock_content = () => {
		const hr = qs("hr")
		const gate = qs(".gh-post-upgrade-cta")

		if (!!hr) hr.style.display = 'none'

		if (qs('body.post-template') && !!gate && !!hr) {
			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {	e.style.display = "none" })
			hr.style.visibility = "hidden"
		}
	}

	(async () => {
		const is_subscriber = ('true' == qs('body').getAttribute('data-ghost-paid'))
		let is_unlock = false
		let jwks, token, status

		if (!!code) {
			tu = await try_unlock(code, pid)
			is_unlock = tu.unlocked
		}

		if (!is_unlock) {
			lock_content()
		} else {

		}

		Promise.all([get_jwks(), get_token(), get_status(uid, pid)]).then(v => {
			[jwks, token, status] = v

			qs('.unlock-remaining-count').innerHTML = status.remaining
			qs('.unlock-quota-count').innerHTML = status.quota

			let mode = 'ready'
			if (!!tu && tu.unlocked) {
				mode = 'is-unlock'
				unlock_content()
			} else if (!is_subscriber) {
				mode = 'not-subscribed'
			} else if (status.code) {
				mode = 'already-unlocked'
			} else if (0 == status.remaining) {
				mode = 'none-remaining'
			}
			qs('body').classList.add(`mode-${mode}`)

			// refresh token as needed
			if (!!token) {
				const parseJWT = t => { return JSON.parse(atob(t.split('.')[1])) }
				const jwt = parseJWT(token)
				setInterval(() => {	get_token().then(v => { token = v }) }, (jwt.exp - jwt.iat) * 1000)
			}
		})

		qsa('.unlock-create').forEach(el => {
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

		qsa('.unlock-copy').forEach(el => {
			el.addEventListener("click", ev => {
				navigator.clipboard.writeText(`${document.location.origin}${document.location.pathname}?_unlock=${status.code}`)
				el.classList.add('clicked')
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
