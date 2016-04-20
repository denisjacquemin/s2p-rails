class ImportStudentCSV
  include CSVImporter

  model Student
  column :firstname, as: [ /first.?name/i, /pr(é|e)nom/i ], to: ->(firstname) { firstname.humanize }, required: true
  column :lastname,  as: [ /last.?name/i, "nom" ], to: ->(lastname) { lastname.humanize }, required: true
  column :level,  as: [ /ann(é|e)/i]
  column :classroom, as: [/classe/i]
  column :code, as: [/code/i]
  #column :email, as: [/e.?mail/i, "courriel"], to: ->(email) { email.downcase }

  identifier :code

  when_invalid :skip

end
