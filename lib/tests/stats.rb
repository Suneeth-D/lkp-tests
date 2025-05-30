#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(File.dirname(File.dirname(File.realpath($PROGRAM_NAME))))

require "#{LKP_SRC}/lib/log"
require "#{LKP_SRC}/lib/string"

module LKP
  class Stats
    def initialize
      @stats = {}
    end

    def key?(test_case)
      @stats.key? self.class.normalize(test_case)
    end

    def add(test_case, test_result, overwrite: false)
      test_case = self.class.normalize(test_case)
      raise "#{test_case} has already existed" if !overwrite && key?(test_case)

      test_result = self.class.normalize(test_result.to_s.tr('.', '_').downcase) if test_result.instance_of?(String) || test_result.instance_of?(Symbol)

      @stats[test_case] = test_result
    end

    # mapping: { 'ok' => 'pass', 'not_ok' => 'fail' }
    def dump(mapping = {})
      @stats.each do |k, v|
        v = mapping[v.to_s] || v

        if v.instance_of?(String) || v.instance_of?(Symbol)
          puts "#{k}.#{v}: 1"
        else
          puts "#{k}: #{v}"
        end
      end
    end

    def method_missing(sym, *args, &block)
      @stats.send(sym, *args, &block)
    end

    # def exit(warn)
    #   log_warn warn if warn
    #   exit 1
    # end

    # def validate_duplication(hash, key)
    #   self.exit "#{key} has already existed" if hash.key? key
    # end

    class << self
      def normalize(test_case)
        test_case.to_s
                 .strip
                 .gsub(/[\s,"_\[\]():]+/, '_')
                 .remove(/(^_+|_+$)/)
                 .gsub(/_{2,}/, '_') # replace continuous _ to single _
                 .gsub(/\.{4,}/, '.') # replace more than .... to single .
      end
    end
  end
end
