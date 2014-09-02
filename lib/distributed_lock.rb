require 'redis'
require 'redis-lock'
require 'redis_client'

class DistributedLock
  LIFETIME = (10 * 60) # seconds

  def initialize(lock_name)
    @lock_name = lock_name
  end

  def lock
    redis.lock("support-api:#{Rails.env}:#{@lock_name}", life: LIFETIME) do
      Rails.logger.debug('Successfully got a lock. Running...')
      yield
    end
  rescue Redis::Lock::LockNotAcquired => e
    Rails.logger.debug("Failed to get lock for #{@lock_name} (#{e.message}). Another process probably got there first.")
  end

private
  def redis
    RedisClient.instance.connection
  end
end
