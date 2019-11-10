#How To

## Restore locally a dump from heroku 
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U denisjacquemin -d s2p_development '/Users/denisjacquemin/Documents/Konecto App/Backups/...'


Extract Saint Vincent from Bellefontaine

bellefontaine_school_id = 89
saint_vincent_school_id = 203

all_student_bellefontaine_group_id = Group.where(internal_id: 'all_students', school_id: 89).pluck(:id).first # 414904
all_student_saint_vincent = Group.where(internal_id: 'all_students', school_id: 203).pluck(:id).first # 419942

groups = Group.find(415192, 415190, 415189, 415150, 415191, 415193, 415179, 415141, 415181, 415182, 415938, 419941, 415924)
students = Student.by_groups([415192, 415190, 415189, 415150, 415191, 415193, 415179, 415141, 415181, 415182, 415938, 419941,415924]).count

# retirer all_student_bellefontaine des students
students.each { |student| student.groups.delete(414904); student.save }

# ajouter all_student_saint_vincent aux students
students.each { |student| student.groups.push(419942); student.save }

# changer le school_id de groups et students
students.each { |student| student.school_id = 203; student.save }
groups.each { |group| group.school_id = 203; group.save }
