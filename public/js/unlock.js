// data-unlock-create data-member-id='{{@member.uuid}}'

(() => {
	const BASEURL = new URL(document.currentScript.src).origin;
	let PROMISES = [];
	let ghost_token = null;
	let ghost_jwks = null;
	const pid = location.origin + location.pathname

	// check _unlock
	if (c = new URLSearchParams(location.search).get('_unlock')) {
		fetch(`${BASEURL}/unlock/try?code=${c}&pid=${pid}`).then(r => r.json()).then(j => {
			if (j.unlocked) {
				// unlock content
			}
		})
	}

	let s = document.createElement('script')
	s.onload = () => { MicroModal.init() }
	s.src = 'https://unpkg.com/micromodal@0.4.10/dist/micromodal.min.js'
	document.head.appendChild(s)

	const get_token = async () => {	ghost_token = await (await fetch('/members/api/session')).text() }
	PROMISES.push(get_token());

	PROMISES.push((async () => {
		ghost_jwks = await (await fetch('/members/.well-known/jwks.json')).json()
	})());

	(async () => {
		await Promise.all(PROMISES)

		document.querySelectorAll('[data-unlock-create]').forEach(el => {
			el.addEventListener("click", ev => {
				fetch(`${BASEURL}/unlock`, {
					method: 'POST',
					headers: {
						'Accept': 'application/json',
						'Content-Type': 'application/json'
					},
					body: JSON.stringify({
						uid: el.getAttribute('data-member-id'),
						pid: pid,
						token: ghost_token,
						jwks: ghost_jwks
					})
				}).then(r => r.json()).then(j => {
					console.log(j)
				})
			})
		})

		// refresh token as needed
		const parseJWT = t => { return JSON.parse(atob(t.split('.')[1])) }
		const jwt = parseJWT(ghost_token)
		setInterval(() => { get_token() }, (jwt.exp - jwt.iat) * 1000)

		// insert an unlock button
		// const n = document.createRange().createContextualFragment("<button data-unlock-create data-member-id='{{@member.uuid}}'>ok</button>");
		// document.body.appendChild(n)
	})();
})();
