module Code
  def compute_code(school_key, student_key)
    #logger.debug(")))))))))) key: #{key}")
    begin
      custom_hash_alphabet = 'abcdefghijkmnopqrstuvwxyz23456789' # https://www.grc.com/ppp.htm
      hash = compute_hash(school_key, student_key, custom_hash_alphabet)
    rescue Exception => e
      logger.debug "compute_code error: e.inspect"
    end
    # while !self.class.by_code(prefix + hash).empty? do
    #   @key = "#{rand(9999)}" + @key  # add nothing to the key to generate a different code
    #   hash = compute_hash(@key, custom_hash_alphabet)
    # end
    return hash
  end

  def shake_name(firstname, lastname)
    first_even = firstname.split("").select.with_index { |_, i| i.even? }
    first_odd = firstname.split("").select.with_index { |_, i| i.odd? }
    last_even = lastname.split("").select.with_index { |_, i| i.even? }
    last_odd = lastname.split("").select.with_index { |_, i| i.odd? }

    first_even + last_even + first_odd + last_odd
  end

  private
    def compute_hash(school_key, student_key, hash_alphabet)
      begin
        hashids = Hashids.new(Rails.application.secrets.salt_hashids, 0, hash_alphabet)
        #logger.debug "[compute_hash] key: #{key}"
        #logger.debug "[compute_hash] key.unpacked: #{key.unpack('H*')[0]}"
        #logger.debug "[compute_hash] hashids generated: #{hashids.encode_hex(key.unpack('H*')[0])}"
        #logger.debug "[compute_hash] hash returned: #{hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)}"
        schoolHash = hashids.encode(school_key)
        generatedHash = hashids.encode_hex(student_key.unpack('H*')[0]) + hash_alphabet[(student_key.length % hash_alphabet.length)]
      rescue Exception => e
        logger.debug "compute_hash error: e.inspect"
      end
      [schoolHash,generatedHash]

    end
end
