class ImportStudentCSV
  include CSVImporter

  model Student

  column :firstname, as: [ /first.?name/i, /pr(é|e)nom/i ], required: true
  column :lastname,  as: [ /last.?name/i, "nom" ], required: true
  column :level,  as: [ /ann(é|e)/i]
  column :classroom, as: [/classe/i]
  #column :email, as: [/e.?mail/i, "courriel"]

end
