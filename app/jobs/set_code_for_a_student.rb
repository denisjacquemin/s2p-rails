class SetCodeForAStudentJob < ApplicationJob
  queue_as :default

  def perform(student_id)
    @student = Student.find student_id
    unless @student.nil?
      
      @student.code = compute_code('s', "#{@student.school_id}#{@student.firstname}#{@student.lastname}")
      begin
        @student.save
      rescue ActiveRecord::RecordNotUnique
        @student.code = compute_code('s', "#{rand(9999)} #{@student.school_id}#{@student.firstname}#{@student.lastname}")
        retry
      end
    end
  end

  def compute_code(prefix, key)
    @key = key
    custom_hash_alphabet = 'abcdefghijkmnopqrstuvwxyz23456789' # https://www.grc.com/ppp.htm
    hash = compute_hash(@key, custom_hash_alphabet)
    # while !self.class.by_code(prefix + hash).empty? do
    #   @key = "#{rand(9999)}" + @key  # add nothing to the key to generate a different code
    #   hash = compute_hash(@key, custom_hash_alphabet)
    # end
    return prefix + hash
  end

  private
  def compute_hash(key, hash_alphabet)
    hashids = Hashids.new(Rails.application.secrets.salt_hashids, 7, hash_alphabet)
    hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
  end
end
