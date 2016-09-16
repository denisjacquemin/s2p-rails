module Code extend ActiveSupport::Concern

    def compute_code(prefix, key)
      @key = key
      custom_hash_alphabet = 'abcdefghijkmnopqrstuvwxyz23456789' # https://www.grc.com/ppp.htm
      hash = compute_hash(@key, custom_hash_alphabet)
      while !Student.by_code(prefix + hash).empty? do
        @key = "#{rand(9999)}" + @key  # add nothing to the key to generate a different code
        hash = compute_hash(@key, custom_hash_alphabet)
      end
      self.code = prefix + hash
    end

    private
    def compute_hash(key, hash_alphabet)
      hashids = Hashids.new(Rails.application.secrets.salt_hashids, 7, hash_alphabet)
      hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
    end

end
