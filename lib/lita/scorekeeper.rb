require "lita"
require "lita/scorekeeper/version"

module Lita
  module Handlers
    class Scorekeeper < Handler
      route(/^([-_A-Za-z0-9]+)\+\+$/,
            :scoreup,
            help: { "<name>++" => "Increments name." })

      route(/^([-_A-Za-z0-9]+)--$/,
            :scoredown,
            help: { "<name>--" => "Decrements name." })

      route(/^score(?:keeper)?\s+([-_A-Za-z0-9]+)$/,
            :scoreshow,
            help: { "scorekeeper <name>++" => "Increments name." })

      def scoreup(response)
        name = response.matches[0][0]
        current = redis.get(name).to_i rescue 0
        current += 1
        redis.set(name, current.to_s)
        response.reply "Incremented #{name}: (#{current} pts)"
      rescue => e
        response.reply "Failure: #{e.message}"
      end

      def scoredown(response)
        name = response.matches[0][0]
        current = redis.get(name).to_i rescue 0
        current -= 1
        redis.set(name, [current, 0].max.to_s)
        response.reply "Decremented #{name}: (#{current} pts)"
      rescue => e
        response.reply "Failure: #{e.message}"
      end

      def scoreshow(response)
        name = response.matches[0][0]
        current = redis.get(name).to_i rescue nil

        if current
          response.reply "Current score of #{name}: #{current} pts"
        else
          response.reply "#{name} have no score now."
        end
      rescue => e
        response.reply "Failure: #{e.message}"
      end
    end

    Lita.register_handler(Scorekeeper)
  end
end
