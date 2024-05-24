// check & trigger unlock
// expects uid in body[data-uid]
// set up unlock link UI (on click from [data-unlock-create][data-member-id='{{@member.uuid}}]')
// generate unlocks including validation context

(() => {
	const doc = document, qs = (s,o=doc) => o.querySelector(s), qsa = (s,o=doc) => o.querySelectorAll(s)

	const BASEURL = new URL(document.currentScript.src).origin;
	let PROMISES = [];
	const uid = qs('body').getAttribute('data-ghost-uid')
	const pid = location.origin + location.pathname;
	let ghost_token = null;
	let ghost_jwks = null;

	// check _unlock
	const get_token = async () => {
		ghost_token = await (await fetch(`/members/api/session`)).text()
	}
	PROMISES.push(get_token());

	PROMISES.push((async () => {
		ghost_jwks = await (await fetch(`/members/.well-known/jwks.json`)).json()
	})());

	(async () => {
		let j = await (await fetch(`${BASEURL}/unlock/status?uid=${uid}&pid=${pid}`)).json()
		qs('.unlock-left-count').innerHTML = j.remaining
	})();

	(() => {
		let s = document.createElement('script')
		s.onload = () => { MicroModal.init() }
		s.src = 'https://unpkg.com/micromodal@0.4.10/dist/micromodal.min.js'
		document.head.appendChild(s)
	})();

	(() => {
		const hr = qs("hr")
		const gate = qs(".gh-post-upgrade-cta")
		const is_paywalled = !!gate
		let is_unlocked = false

		if (c = new URLSearchParams(location.search).get('_unlock')) {
			fetch(`${BASEURL}/unlock/try?code=${c}&pid=${pid}`).then(r => r.json()).then(j => {
				if (j.unlocked) {
console.log(j)
					is_unlocked = true
				}
			})
		}

		// if this is a post, there's an <hr> and a paygate, and not an unlock, hide the nodes in between
		if (is_paywalled && !is_unlocked && qs('body.post-template') && hr && gate) {
			qsa("hr ~ :not(.gh-post-upgrade-cta)").forEach((e) => {
				e.style.display = "none"
			})
			hr.style.display = "none"
		}

		if (is_paywalled) {
			qs('.gh-article .gh-article-share-control').style.display = 'flex'
		}
	})();

	(async () => {
		await Promise.all(PROMISES)
		if (!ghost_jwks && !ghost_token) return

		qsa('[data-unlock-create][data-member-id]').forEach(el => {
			el.addEventListener("click", ev => {
				fetch(`${BASEURL}/unlock`, {
					method: 'POST',
					headers: {
						'Accept': 'application/json',
						'Content-Type': 'application/json'
					},
					body: JSON.stringify({
						uid: uid,
						pid: pid,
						token: ghost_token,
						jwks: ghost_jwks
					})
				}).then(r => r.json()).then(j => {
					qs('.unlock-left-count').innerHTML = j.remaining
					el.innerHTML = "Share URL copied"
					console.log(j)
				})
			})
		})

		// refresh token as needed
		const parseJWT = t => { return JSON.parse(atob(t.split('.')[1])) }
		const jwt = parseJWT(ghost_token)
		setInterval(() => { get_token() }, (jwt.exp - jwt.iat) * 1000)
	})();
})();
