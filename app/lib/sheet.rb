module Sheet
  def self.test
    "ok"
  end

  def self.validate_file(file)
    return { isValid: false, reason: :nil, error_message: 'Aucun fichier à importer' } if file.nil?

    mimemagic = MimeMagic.by_path(file.tempfile.path)

    # if (mimemagic.type != "text/csv" and mimemagic.type != "application/vnd.ms-excel" and mimemagic.type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    if mimemagic.type != "text/csv"
      return { isValid: false, reason: :mime, error_message: 'Format de fichier invalide, enregistrez votre fichier au format CSV' }
    end

    return { isValid: true }
  end

  def self.RooFormat(file)
    mimemagic = MimeMagic.by_path(file.tempfile.path)

    format = :none
    if mimemagic.type == "text/csv"
      format = :csv
    elsif mimemagic.type == "application/vnd.ms-excel"
      format = :xls
    elsif mimemagic.type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      format = :xlsx
    end
    return format
    # begin
    #   Roo::Spreadsheet.open(file.tempfile.path, extension: :csv)
    #   format = :csv
    # rescue
    #   begin
    #     Roo::Spreadsheet.open(file.tempfile.path, extension: :xlsx)
    #     format = :xlsx
    #   rescue
    #     begin
    #       Roo::Spreadsheet.open(file.tempfile.path, extension: :xls)
    #       format = :xls
    #     rescue
    #       format = :none
    #     end
    #   end
    # end
    # format
  end

  def self.encoding(file)
    # MacRoman (excel mac) cp1252 (superset de ISO-8859-1 compatible avec le sigle euro) utf-8
    encoding = 'utf-8'
    begin
      lines = CSV.read(file.tempfile.path, :encoding => encoding)
    rescue ArgumentError
      encoding = 'cp1252'
    end
    return encoding
  end

end
