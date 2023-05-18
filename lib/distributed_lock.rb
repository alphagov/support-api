require "redis"
require "redis-lock"

class DistributedLock
  LIFETIME = (10 * 60) # seconds

  def initialize(lock_name)
    @full_lock_name = ActiveRecord::Base.sanitize_sql("support-api:#{lock_name}")
  end

  def lock
    Redis.new.lock(@full_lock_name, life: LIFETIME) do
      Rails.logger.debug("Successfully got a lock. Running...")
      yield
    end
  rescue Redis::Lock::LockNotAcquired => e
    Rails.logger.debug("Failed to get lock for #{@full_lock_name} (#{e.message}). Another process probably got there first.")
  end
end
