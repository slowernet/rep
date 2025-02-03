module User
	def self.can_create?(uid)
		remaining(uid) > 0
	end

	def self.has_created_unexpired?(uid, pid)
		uu = Unlock.find(uid: uid, pid: pid).to_a
		return false if uu.empty?
		return false if uu.all? { |u| u.expired? }
	end

	def self.remaining(uid)
		d = Time.now.utc.to_date
		first_of_month_ts = (d - d.mday + 1).to_time.to_i
		used = Unlock.sorted_find(:created_at, uid: uid).between(first_of_month_ts, Time.now.utc.to_i).size
		quota(uid) - used
	end

	def self.quota(uid)
		ENV['UNLOCK_QUOTA_PER_MONTH'].to_i
	end
end

class Unlock < Ohm::Model
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Sorted

	attribute :code
	attribute :pid
	attribute :uid
	counter :uses

	index :code
	index :pid
	index :uid
	sorted :created_at, group_by: :uid

	def expired?
		(Time.now.utc.to_i - created_at.to_i) > (ENV['UNLOCK_TTL_DAYS'].to_i * 86400)
	end

	def before_create
		self.code = [*('a'..'z')].shuffle[0,12].join
	end

	def self.create(atts = {})
		if User.can_create?(atts[:uid]) && !User.has_created_unexpired?(atts[:uid], atts[:pid])
			super(atts.except(:code))
		end
	end

	def self.unlocked?(pid, code)
		return false unless u = Unlock.find(pid: pid, code: code).first
		return false if u.expired?
		u.incr(:uses)
		true
	end
end
