require "./app/helpers/helpers"

class UnlockApp < Roda
	plugin :halt
	plugin :json_parser

	include Helpers

	route do |r|
		response['Content-Type'] = 'application/json'

		r.get 'all' do
			halt('uid missing') if (uid = request.params['uid']).nil?
			Unlock.find({ uid: uid }).to_a.map do |u|
				a = u.attributes.merge(id: u.id, expired: u.expired?, uses: u.uses)
			end.to_json
		end

		halt('pid missing') if (pid = request.params['pid']).nil? || pid.empty?
		pid = hash12(pid)

		r.get 'status' do
			halt('uid missing') if (uid = request.params['uid']).nil?
			u = Unlock.find({ uid: uid, pid: pid }).first
			{ code: u&.code, remaining: User.remaining(uid) }.to_json
		end

		r.get 'try' do
			halt('code missing') if (code = request.params['code']).nil? || code.empty?
			{ unlocked: Unlock.unlocked?(pid, code) }.to_json
		end

		r.post do
			# limitation: uid cannot create a second code for pid, even after first expires
			halt('uid missing') if (uid = request.params['uid']).nil?
			halt('duplicate') if Unlock.find({ uid: uid, pid: pid }).first
			halt('token missing') if (token = request.params['token']).nil?
			halt('jwks missing') if (jwks = request.params['jwks']).nil?
			pk = JWT::JWK::Set.new(jwks).first.public_key
			JWT.decode(token, pk, true, algorithms: 'RS512') rescue	halt('token invalid')

			u = Unlock.create({ uid: uid, pid: pid })
			{ code: u.code, remaining: User.remaining(uid) }.to_json
		end
	end
end
