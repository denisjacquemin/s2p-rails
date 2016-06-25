module Code extend ActiveSupport::Concern

    def compute_code(prefix, key)
      custom_hash_alphabet = 'abcdefghijkmnopqrstuvwxyz23456789' # https://www.grc.com/ppp.htm

      hashids = Hashids.new(Rails.application.secrets.salt_hashids, 7, custom_hash_alphabet)
      hash = hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
      while !Student.by_code(hash).empty? do
        key = key + "a" # add nothing to the key to generate a different code
        hash = hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
      end
      self.code = prefix + hash
    end


end
