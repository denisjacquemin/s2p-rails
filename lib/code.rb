module Code
  def compute_code(prefix, key)
    @key = key
    #logger.debug(")))))))))) key: #{key}")
    custom_hash_alphabet = 'abcdefghijkmnopqrstuvwxyz23456789' # https://www.grc.com/ppp.htm
    hash = compute_hash(@key, custom_hash_alphabet)
    # while !self.class.by_code(prefix + hash).empty? do
    #   @key = "#{rand(9999)}" + @key  # add nothing to the key to generate a different code
    #   hash = compute_hash(@key, custom_hash_alphabet)
    # end
    return hash
  end

  private
    def compute_hash(key, hash_alphabet)
      hashids = Hashids.new(Rails.application.secrets.salt_hashids, 6, hash_alphabet)
      #logger.debug "[compute_hash] key: #{key}"
      #logger.debug "[compute_hash] key.unpacked: #{key.unpack('H*')[0]}"
      #logger.debug "[compute_hash] hashids generated: #{hashids.encode_hex(key.unpack('H*')[0])}"
      #logger.debug "[compute_hash] hash returned: #{hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)}"

      generatedHash = hashids.encode_hex(key.unpack('H*')[0]) + hash_alphabet[(key.length % hash_alphabet.length)]
      #generatedHash.last(6)
    end
end
